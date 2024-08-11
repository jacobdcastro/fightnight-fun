import { createThirdwebClient } from 'thirdweb'

const clientId = (process.env.NEXT_PUBLIC_THIRDWEB_CLIENT_ID || '') as string
// const secretKey = (process.env.NEXT_PUBLIC_THIRDWEB_CLIENT_ID || '') as string

export const client = createThirdwebClient({
  clientId,
})
