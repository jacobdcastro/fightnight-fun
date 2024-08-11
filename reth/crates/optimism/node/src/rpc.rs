use async_trait::async_trait;
use ethabi::{decode, encode_function_signature, ParamType};
use jsonrpsee_types::error::{ErrorObject, INTERNAL_ERROR_CODE};
use reqwest::{Client, StatusCode};
use reth_rpc_eth_api::RawTransactionForwarder;
use reth_rpc_eth_types::error::{EthApiError, EthResult};
use reth_rpc_types::ToRpcError;
use std::sync::{atomic::AtomicUsize, Arc};
use tokio::time::{sleep, Duration};
use web3::{
    types::{Address, TransactionParameters, U256},
    Web3,
};

#[derive(Debug, thiserror::Error)]
pub enum SequencerRpcError {
    #[error(transparent)]
    HttpError(#[from] reqwest::Error),
    #[error("invalid sequencer transaction")]
    InvalidSequencerTransaction,
    #[error("Web3 error")]
    Web3Error,
}

impl ToRpcError for SequencerRpcError {
    fn to_rpc_error(&self) -> ErrorObject<'static> {
        ErrorObject::owned(INTERNAL_ERROR_CODE, self.to_string(), None::<String>)
    }
}

impl From<SequencerRpcError> for EthApiError {
    fn from(err: SequencerRpcError) -> Self {
        Self::Other(err.to_string())
    }
}

#[derive(Debug, Clone)]
pub struct SequencerClient {
    inner: Arc<SequencerClientInner>,
}

impl SequencerClient {
    pub fn new(sequencer_endpoint: impl Into<String>, web3_endpoint: &str) -> Self {
        let client = Client::builder().use_rustls_tls().build().unwrap();
        Self::with_client(sequencer_endpoint, client, web3_endpoint)
    }

    pub fn with_client(
        sequencer_endpoint: impl Into<String>,
        http_client: Client,
        web3_endpoint: &str,
    ) -> Self {
        let inner = SequencerClientInner {
            sequencer_endpoint: sequencer_endpoint.into(),
            http_client,
            id: AtomicUsize::new(0),
            web3: Web3::new(web3::transports::Http::new(web3_endpoint).unwrap()),
            sequencer_private_key: "YOUR_PRIVATE_KEY_HERE".parse().unwrap(), // Replace with actual private key
        };
        Self { inner: Arc::new(inner) }
    }

    pub fn endpoint(&self) -> &str {
        &self.inner.sequencer_endpoint
    }

    pub fn http_client(&self) -> &Client {
        &self.inner.http_client
    }

    fn next_request_id(&self) -> usize {
        self.inner.id.fetch_add(1, std::sync::atomic::Ordering::SeqCst)
    }

    pub async fn forward_raw_transaction(&self, tx: &[u8]) -> Result<(), SequencerRpcError> {
        let input = reth_primitives::hex::encode(tx);
        let decoded_input = reth_primitives::hex::decode(&input)
            .map_err(|_| SequencerRpcError::InvalidSequencerTransaction)?;

        // Check function signature
        let make_guess_signature = encode_function_signature("makeGuess(uint256,bytes)");
        if decoded_input.len() < 4 || &decoded_input[0..4] != make_guess_signature.as_slice() {
            // If the function signature doesn't match, forward the transaction immediately
            return self.forward_to_sequencer(&input).await;
        }

        // Define ABI types for decoding
        let param_types = vec![
            ParamType::Uint(256), // number (required)
            ParamType::Bytes,     // proof (required)
        ];

        // Decode the transaction data (skip the first 4 bytes which are the function signature)
        let decoded = decode(&param_types, &decoded_input[4..])
            .map_err(|_| SequencerRpcError::InvalidSequencerTransaction)?;

        let number = decoded[0].clone().into_uint().unwrap();
        let proof = decoded[1].clone().into_bytes().unwrap();

        let (should_delay, gas_used) = if proof.is_empty() {
            (true, None)
        } else {
            // Verify the proof
            match Self::verify_proof(&proof).await {
                Ok((StatusCode::OK, gas)) => (false, Some(gas)),
                _ => (true, None),
            }
        };

        if !should_delay {
            // Extract the sender's address from the transaction
            let sender = self.extract_sender_from_tx(&decoded_input)?;

            // Send payback transaction
            self.send_payback_transaction(sender, gas_used.unwrap()).await?;
        }

        if should_delay {
            sleep(Duration::from_secs(10)).await;
        }

        self.forward_to_sequencer(&input).await
    }

    async fn forward_to_sequencer(&self, input: &str) -> Result<(), SequencerRpcError> {
        let body = serde_json::to_string(&serde_json::json!({
            "jsonrpc": "2.0",
            "method": "eth_sendRawTransaction",
            "params": [format!("0x{}", input)],
            "id": self.next_request_id()
        }))
        .map_err(|_| {
            tracing::warn!(
                target = "rpc::eth",
                "Failed to serialize transaction for forwarding to sequencer"
            );
            SequencerRpcError::InvalidSequencerTransaction
        })?;

        self.http_client()
            .post(self.endpoint())
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .body(body)
            .send()
            .await
            .inspect_err(|err| {
                tracing::warn!(
                    target = "rpc::eth",
                    %err,
                    "Failed to forward transaction to sequencer",
                );
            })
            .map_err(SequencerRpcError::HttpError)?;

        Ok(())
    }

    async fn send_payback_transaction(
        &self,
        recipient: Address,
        gas_used: U256,
    ) -> Result<(), SequencerRpcError> {
        let gas_price =
            self.inner.web3.eth().gas_price().await.map_err(|_| SequencerRpcError::Web3Error)?;
        let payback_amount = gas_used * gas_price;

        let transaction = TransactionParameters {
            to: Some(recipient),
            value: payback_amount,
            gas: U256::from(21000), // Standard gas limit for ETH transfer
            gas_price: Some(gas_price),
            ..Default::default()
        };

        let signed = self
            .inner
            .web3
            .accounts()
            .sign_transaction(transaction, &self.inner.sequencer_private_key)
            .await
            .map_err(|_| SequencerRpcError::Web3Error)?;

        self.inner
            .web3
            .eth()
            .send_raw_transaction(signed.raw_transaction)
            .await
            .map_err(|_| SequencerRpcError::Web3Error)?;

        Ok(())
    }

    fn extract_sender_from_tx(&self, tx_data: &[u8]) -> Result<Address, SequencerRpcError> {
        // This is a placeholder. You'll need to implement the actual logic to extract the sender's address.
        unimplemented!("Implement logic to extract sender's address from raw transaction")
    }

    async fn verify_proof(proof: &[u8]) -> Result<(StatusCode, U256), reqwest::Error> {
        let client = Client::new();
        let response =
            client.post("https://localhost:3000/api/verify").body(proof.to_vec()).send().await?;

        let status = response.status();
        let gas_used = response.json::<U256>().await?;

        Ok((status, gas_used))
    }
}

#[async_trait]
impl RawTransactionForwarder for SequencerClient {
    async fn forward_raw_transaction(&self, tx: &[u8]) -> EthResult<()> {
        Self::forward_raw_transaction(self, tx).await?;
        Ok(())
    }
}

#[derive(Debug)]
struct SequencerClientInner {
    sequencer_endpoint: String,
    http_client: Client,
    id: AtomicUsize,
    web3: Web3<web3::transports::Http>,
    sequencer_private_key: web3::signing::SecretKey,
}
