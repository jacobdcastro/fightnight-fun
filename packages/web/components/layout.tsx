import Header from './header'
import Footer from './footer'
import type { ReactNode } from 'react'
import { ThirdwebProvider, ConnectButton } from 'thirdweb/react'
import { createWallet, walletConnect } from 'thirdweb/wallets'
import { createThirdwebClient } from 'thirdweb'

const client = createThirdwebClient({
  clientId: 'YOUR_CLIENT_ID',
})

const wallets = [
  createWallet('io.metamask'),
  walletConnect(),
  createWallet('io.zerion.wallet'),
  createWallet('me.rainbow'),
]

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <ThirdwebProvider>
      <ConnectButton
        client={client}
        wallets={wallets}
        theme={'dark'}
        connectModal={{
          size: 'compact',
          welcomeScreen: {
            title: 'Connect to trade and play.',
          },
        }}
      />
      <Header />
      <main>{children}</main>
      <Footer />
    </ThirdwebProvider>
  )
}
