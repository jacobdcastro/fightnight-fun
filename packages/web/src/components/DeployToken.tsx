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
    <section className='flex max-w-xl mx-auto flex-col p-8 gap-4 bg-lime-200 border-solid border-lime-600 border-4 justify-center items-center'>
      <h1 className='font-bold text-2xl'>Start a Fight</h1>

      {formState === 'IDLE' && (
        <form onSubmit={handleSubmit} className='flex flex-col gap-4 justify-center items-center'>
          <div className='flex flex-col justify-center items-center'>
            <h2>Selected Network</h2>
            <input type="text" value={chain?.name} className='text-center w-full' disabled />
          </div>

          <div className='flex flex-col justify-center items-center'>
            <h2>Choose a Game</h2>
            <select
              value={formData.gameType}
              className='text-center w-full'
              onChange={(e) =>
                setFormData({ ...formData, gameType: e.target.value })
              }
            >
                <option>
                  Random Rampage
                </option>
            </select>
          </div>

          <div className='flex flex-col justify-center items-center'>
            <h2>Fight Name</h2>
            <input
              type="text"
              placeholder="Fight Coin"
              className='text-center w-full'
              onChange={(e) =>
                setFormData({ ...formData, tokenName: e.target.value })
              }
            />
          </div>

          <div className='flex flex-col justify-center items-center'>
            <h2>Token Symbol</h2>
            <input
              type="text"
              placeholder="FIGHT"
              className='text-center w-full'
              onChange={(e) =>
                setFormData({ ...formData, tokenSymbol: e.target.value })
              }
            />
          </div>

          <button type="button" onClick={() => handleSubmit()} className='w-full bg-black text-white hover:bg-slate-700 py-[0.3em]'>
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
    </section>
  )
}
