import { chainOptions } from './chain-options'

export const factoryContractsByChainId: Record<
  (typeof chainOptions)[0]['id'],
  string
> = {
  [chainOptions[0].id]: '0x4c1845e9F562E3BE45FAA9AB1420D3C611e2D6B9', // sepolia
  [chainOptions[1].id]: '0x4c1845e9F562E3BE45FAA9AB1420D3C611e2D6B9', // base
  [chainOptions[2].id]: '0x4c1845e9F562E3BE45FAA9AB1420D3C611e2D6B9', // optimism
  [chainOptions[3].id]: '0x4c1845e9F562E3BE45FAA9AB1420D3C611e2D6B9', // mode
  [chainOptions[4].id]: '0x3fc2641d4d9389e30Ddd1e4826969227A9414eD8', // fightnight
}
