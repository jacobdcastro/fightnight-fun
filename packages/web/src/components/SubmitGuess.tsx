'use client'
import { VerificationLevel, IDKitWidget, useIDKit } from '@worldcoin/idkit'
import type { ISuccessResult } from '@worldcoin/idkit'
import axios from 'axios'
import { VerifyReply } from '../pages/api/verify'
import { createThirdwebClient, eth_sendRawTransaction } from 'thirdweb'
import { getRpcClient } from 'thirdweb/rpc'
import { ethereum } from 'thirdweb/chains'
import { fightnightTestnet, thirdwebClient } from '@/pages/_app'

const rpcRequest = getRpcClient({
  client: thirdwebClient,
  chain: fightnightTestnet,
})

export default function Home() {
  const app_id = process.env.NEXT_PUBLIC_WLD_APP_ID as `app_${string}`
  const action = process.env.NEXT_PUBLIC_WLD_ACTION

  if (!app_id) {
    throw new Error('app_id is not set in environment variables!')
  }
  if (!action) {
    throw new Error('action is not set in environment variables!')
  }

  const { setOpen } = useIDKit()

  const onSuccess = (result: ISuccessResult) => {
    window.alert(
      'Successfully verified with World ID! Your nullifier hash is: ' +
        result.nullifier_hash
    )
  }

  const handleProof = async (result: ISuccessResult) => {
    console.log('Proof received from IDKit, sending to backend:\n', result)
    try {
      const { data, status } = await axios.post<VerifyReply>('/api/verify', {
        proof: {
          nullifier_hash: result.nullifier_hash,
          merkle_root: result.merkle_root,
          proof: result.proof,
          verification_level: VerificationLevel.Device,
        },
      })

      console.log('Successful response from backend:\n', JSON.stringify(data))
    } catch (error) {
      console.error(`Verification failed: ${error}`)
    }
  }

  return (
    <div>
      <div className="flex flex-col items-center justify-center align-middle h-screen">
        <p className="text-2xl mb-5">Submit Your Guess in the Game</p>
        <IDKitWidget
          action={action}
          app_id={app_id}
          handleVerify={handleProof}
          onSuccess={onSuccess}
          verification_level={VerificationLevel.Device}
        />
        <button
          className="border border-black rounded-md"
          onClick={() => setOpen(true)}
        >
          <div className="mx-3 my-1">Verify with World ID</div>
        </button>
      </div>
    </div>
  )
}
