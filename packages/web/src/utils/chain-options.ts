import {
  baseSepolia,
  ChainOptions,
  optimismSepolia,
  sepolia,
} from 'thirdweb/chains'

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

export const chainOptions = [
  sepolia,
  baseSepolia,
  optimismSepolia,
  modeSepolia,
  fightnightTestnet,
]
