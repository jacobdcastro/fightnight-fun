import { fightTokenAbi } from '@/abis/fighttoken.abi'
import { chainOptions } from '@/utils/chain-options'
import { client } from '@/utils/client'
import { factoryContractsByChainId } from '@/utils/factory-contracts'
import { EvmPriceServiceConnection } from '@pythnetwork/pyth-evm-js'
import { useEffect, useMemo, useState } from 'react'
import { ContractOptions, getContract, hexToUint8Array, prepareContractCall, sendTransaction, stringToBytes, toBytes, toHex, toUnits, toWei } from 'thirdweb'
import { ChainOptions } from 'thirdweb/chains'
import {
  useActiveAccount,
  useActiveWallet,
  useActiveWalletChain,
  useReadContract,
} from 'thirdweb/react'

const DeployedToken = ({
  address,
  contract,
  chain,
}: {
  address: string
  contract: ContractOptions<[]>
  chain: Readonly<
    ChainOptions & {
      rpc: string
    }
  >
}) => {
  const tokenContract = getContract({
    client,
    chain,
    address,
    abi: fightTokenAbi
  })
  const nameResult = useReadContract({
    contract: tokenContract,
    method: 'function name() returns (string)',
    params: [],
  })
  const symbolResult = useReadContract({
    contract: tokenContract,
    method: 'function symbol() returns (string)',
    params: [],
  })
  const totalSupplyResult = useReadContract({
    contract: tokenContract,
    method: 'function totalSupply() public view returns (uint256)',
    params: [],
  })

  const account = useActiveAccount()
  const [purchaseAmount, setPurchaseAmount] = useState('0')
  const [txHash, setTxHash] = useState<string>()
  const [status, setStatus] = useState<'IDLE' | 'LOADING' | 'COMPLETE' | 'ERROR'>('IDLE')

  const handlePurchase = async (amount: number) => {
    try {
    if (!account) {
      throw new Error('Account not connected')
    }

    setStatus('LOADING')

    const connection = new EvmPriceServiceConnection(
      "https://hermes.pyth.network"
    );
    const priceIds = ["0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace"];
    const priceFeedUpdateData = await connection.getPriceFeedsUpdateData(
      priceIds
    );
    console.log(priceFeedUpdateData);

    const priceUpdate: readonly `0x${string}`[] = [`0x${amount}`]

    const transaction = prepareContractCall({
      contract: tokenContract,
      method: 'function mintToken() public payable returns (uint256)',
      params: [],
      value: BigInt(amount * 10**18),
    })

    const transactionHash = await sendTransaction({
      account: account,
      transaction: transaction,
    })

    setTxHash(transactionHash.transactionHash)

    console.log('purchasing', amount)

    setStatus('COMPLETE')
  } catch (error) {
      setStatus('ERROR')
      console.error(error)
    }
  }

  return (
    <div className='flex flex-col justify-center items-center gap-2 border-solid border-2 border-red-950 bg-red-200 p-8'>
      <div>
        <p>{nameResult.data}</p>
      <p>{symbolResult.data}</p>
      <p>{totalSupplyResult.data}</p>
        </div>

        {status === 'COMPLETE' && (
          <div>
            <p>Transaction Complete</p>
            <p>{txHash}</p>
            </div>)}
        {status === 'ERROR' && (
          <div>
            <p>Token bought, you're in!</p>
            </div>)}
        {status === 'IDLE' && (
        <form>
          <div>
            <label htmlFor='amount'>Amount</label>
            <input onChange={e => setPurchaseAmount(e.target.value)} value={`${purchaseAmount}`} type='string' id='amount' name='amount' />
          </div>

          <button type='submit' onClick={e => {
            e.preventDefault()
            handlePurchase(purchaseAmount)
          }}>Enter Fight</button>
        </form>
        )}
    </div>
  )
}

export const DeployedTokens = () => {
  const account = useActiveAccount()
  const wallet = useActiveWallet()
  const chain = useActiveWalletChain()
  const currentChain = useMemo(() => chain || chainOptions[0], [chain])
  const { data, isLoading } =  useReadContract({
      contract: getContract({
        client: client,
        chain: currentChain,
        address: factoryContractsByChainId[currentChain.id] as string,
      }),
      method: 'function getDeployedTokens() returns (address[])',
      params: [],
    })

  return (
    <section className='flex max-w-xl mx-auto flex-col p-8 gap-4 bg-lime-200 border-solid border-lime-600 border-4 justify-center items-center'>
      <h1  className='font-bold text-2xl'>Current Fights</h1>
      <ul>
        {(data?.toReversed() || []).map((token) => (
          <li key={token}>
            <DeployedToken
              address={token}
              contract={getContract({
                client,
                chain: currentChain,
                address: token,
              })}
              chain={currentChain}
            />
          </li>
        ))}
      </ul>
    </section>
  )
}
