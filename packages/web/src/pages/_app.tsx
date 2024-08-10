import type { AppProps } from 'next/app'
import { createThirdwebClient } from 'thirdweb'
import { ThirdwebProvider, ConnectButton } from 'thirdweb/react'
import { createWallet, walletConnect } from 'thirdweb/wallets'
import {
  sepolia,
  baseSepolia,
  optimismSepolia,
  ChainOptions,
} from 'thirdweb/chains'
import '@/styles/globals.css'

const clientId = (process.env.NEXT_PUBLIC_THIRDWEB_CLIENT_ID || '') as string
// const secretKey = (process.env.NEXT_PUBLIC_THIRDWEB_CLIENT_ID || '') as string

const client = createThirdwebClient({
  clientId,
})

const modeSepolia: Readonly<
  ChainOptions & {
    rpc: string
  }
> = {
  id: 919,
  name: 'Mode Sepolia',
  rpc: 'https://mainnet.mode.network/',
}

const fightnightTestnet: Readonly<
  ChainOptions & {
    rpc: string
  }
> = {
  id: 88811888,
  name: 'Fightnight Testnet',
  rpc: 'http://localhost:8545/',
}

const chains = [
  sepolia,
  baseSepolia,
  optimismSepolia,
  modeSepolia,
  fightnightTestnet,
]

const wallets = [
  createWallet('io.metamask'),
  createWallet('com.coinbase.wallet'),
  walletConnect(),
  createWallet('io.zerion.wallet'),
  createWallet('me.rainbow'),
]

export default function App({ Component, pageProps }: AppProps) {
  return (
    <ThirdwebProvider>
      <ConnectButton
        client={client}
        wallets={wallets}
        chains={chains}
        theme={'dark'}
        connectModal={{
          size: 'wide',
          welcomeScreen: {
            title: 'Connect to trade and play.',
          },
        }}
      />
      <Component {...pageProps} />
    </ThirdwebProvider>
  )
}
