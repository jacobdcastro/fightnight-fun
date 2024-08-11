import type { NextApiRequest, NextApiResponse } from 'next'
import { VerificationLevel } from '@worldcoin/idkit-core'
import { verifyCloudProof } from '@worldcoin/idkit-core/backend'

export type VerifyReply = {
  success: boolean
  code?: string
  attribute?: string | null
  detail?: string
}

interface IVerifyRequest {
  proof: {
    nullifier_hash: string
    merkle_root: string
    proof: string
    verification_level: VerificationLevel
  }
  signal?: string
}

const app_id = process.env.NEXT_PUBLIC_WLD_APP_ID as `app_${string}`
const action = process.env.NEXT_PUBLIC_WLD_ACTION as string

const verify = async (
  proof: IVerifyRequest['proof'],
  signal?: string
): Promise<VerifyReply> => {
  console.log('Verifying proof:', proof)
  const verifyRes = await verifyCloudProof(proof, app_id, action, signal)
  if (verifyRes.success) {
    return { success: true }
  } else {
    return {
      success: false,
      code: verifyRes.code,
      attribute: verifyRes.attribute,
      detail: verifyRes.detail,
    }
  }
}

type ResponseData = {
  message: string
  result?: VerifyReply
}

export const handler = async (
  req: NextApiRequest,
  res: NextApiResponse<ResponseData>
) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method Not Allowed' })
  }
  try {
    const { proof, signal } = req.body as IVerifyRequest
    const result: VerifyReply = await verify(proof, signal)
    if (result.success) {
      res.status(200).json({ message: 'Proof is verified!', result })
    } else {
      res.status(400).json({ message: 'Proof verification failed', result })
    }
  } catch (error: any) {
    res.status(500).json({ message: error.message })
  }
}

export default handler
