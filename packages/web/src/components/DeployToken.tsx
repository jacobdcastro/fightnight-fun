// Component should include the following funcitonality on base, optimism, or mode:
// - create a new token
// - deposit (buy token)
// - withdraw (sell token) (non-functioning, just UI)
// - view current minted token balance
// - show confirmation when marketcap is reached, and CCIP bridging process is initiated
// - prompt user to change networks to appchain when marketcap is reached

import { useEffect, useState } from 'react'
import {  createThirdwebClient, getContract, prepareContractCall, sendTransaction } from 'thirdweb'
import { useActiveAccount, useActiveWallet, useActiveWalletChain } from 'thirdweb/react'
import { factoryContractsByChainId } from '@/utils/factory-contracts'
import { client } from '@/utils/client'


export const DeployToken = () => {
  const account = useActiveAccount()
  const wallet = useActiveWallet()
  const chain = useActiveWalletChain()

  const [formState, setFormState] = useState<'IDLE' | 'LOADING' | 'COMPLETE' | 'ERROR'>(
    'IDLE'
  )
  const [formData, setFormData] = useState({
    network: 'base',
    gameType: 'Random Rampage',
    tokenName: '',
    tokenSymbol: '',
  })
  const [contract, setContract] = useState<ReturnType<typeof getContract>>()
  const [txHash, setTxHash] = useState<string>()

  useEffect(() => {
    if (!chain) return

    setContract(getContract({
      client: client,
      chain: chain,
      address: factoryContractsByChainId[chain.id] as string,
    }))
  }, [chain])


  const handleSubmit = async () => {
    try {
      if (!contract) {
        throw new Error('Contract not loaded')
      }

      if (!account) {
        throw new Error('Account not connected')
      }

      const transaction = prepareContractCall({
        contract: contract,
        method: 'function createToken(string memory name, string memory symbol)',
        params: [formData.tokenName, formData.tokenSymbol],
      })

      const transactionHash = await sendTransaction({
        account: account,
        transaction: transaction,
      })

      setTxHash(transactionHash.transactionHash)
      setFormState('COMPLETE')
    } catch (error) {
      setFormState('ERROR')
      console.error(error)
    }
  }

  return (
    <section>
      <h1>Start a Fight</h1>

      {formState === 'IDLE' && (
        <form onSubmit={handleSubmit}>
          <div>
            <h2>Selected Network</h2>
            <input type="text" value={chain?.name} disabled />
          </div>

          <div>
            <h2>Choose a Game</h2>
            <select
              value={formData.gameType}
              onChange={(e) =>
                setFormData({ ...formData, gameType: e.target.value })
              }
            >
                <option>
                  Random Rampage
                </option>
            </select>
          </div>

          <div>
            <h2>Fight Name</h2>
            <input
              type="text"
              placeholder="Fight Coin"
              onChange={(e) =>
                setFormData({ ...formData, tokenName: e.target.value })
              }
            />
          </div>

          <div>
            <h2>Token Symbol</h2>
            <input
              type="text"
              placeholder="FIGHT"
              onChange={(e) =>
                setFormData({ ...formData, tokenSymbol: e.target.value })
              }
            />
          </div>

          <button type="button" onClick={() => handleSubmit()}>
            Create Fight
          </button>
        </form>
      )}

      {formState === 'LOADING' && <p>Preparing your event...</p>}

      {formState === 'COMPLETE' && (
        <div>
        <p>Your fight has been created!</p>
        <p>{txHash}</p>
        </div>
      )}

      {formState === 'ERROR' && (
        <p>Something went wrong. Let's refresh and start again.</p>
      )}

      <pre>{JSON.stringify(formData, null, 2)}</pre>
    </section>
  )
}
