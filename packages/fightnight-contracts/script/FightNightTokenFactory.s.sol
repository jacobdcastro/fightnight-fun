// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../lib/forge-std/src/Script.sol";
import "../src/FightNightTokenFactory.sol";
import "../src/CCIPPTT.sol";

/*
BASE SEPOLIA
- Uniswap router: 0xE592427A0AEce92De3Edee1F18E0157C05861564
- WETH9: 0x4200000000000000000000000000000000000006
- USDC: 0x036CbD53842c5426634e7929541eC2318f3dCF7e
- CHAIN ID: 84532

OPTIMISM TESTNET
- Uniswap router: 0xE592427A0AEce92De3Edee1F18E0157C05861564
- WETH9: 0x4200000000000000000000000000000000000006
- USDC: 0x5fd84259d66Cd46123540766Be93DFE6D43130D7
- CHAIN ID: 11155420


PYTH PRICE FEED ETH/USD
0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace
*/

/* contract DeployOnBase is Script {
    address public routerContract = 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93;
    address public linkContract = 0xE4aB69C077896252FAFBD49EFD26B5D171A32410;

    address public sourceBridge;
    address public destinationBridge;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ProgrammableTokenTransfers ccipppt = new ProgrammableTokenTransfers(routerContract, linkContract);
        FightNightTokenFactory fntf = new FightNightTokenFactory(sourceBridge, destinationBridge);

        fntf.createToken("test token", "FNTEST");

        vm.stopBroadcast();
    }
} */

/* contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address routerContract = ;
        address linkContract = ;

        ProgrammableTokenTransfers ccipppt = new ProgrammableTokenTransfers(routerContract, linkContract);
        FightNightTokenFactory fntf = new FightNightTokenFactory("NFT_tutorial", "TUT", "baseUri");

        vm.stopBroadcast();
    }
} */
