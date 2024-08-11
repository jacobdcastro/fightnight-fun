// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../lib/forge-std/src/Script.sol";
import "../src/FightNightTokenFactory.sol";
import "../src/CCIPProgrammableTokenTransfers.sol";


contract DeployOnBase is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address sourceBridge = vm.envAddress("BASE_SEPOLIA_CCIPBRIDGE_ADDRESS");
        address destinationBridge = vm.envAddress("CCIP_DESTINATION");

        address uniswapRouter = vm.envAddress("BASE_SEPOLIA_UNISWAPV3ROUTER_ADDRESS");
        address usdcAddress = vm.envAddress("BASE_SEPOLIA_USDC_ADDRESS");
        address nativeAddress = vm.envAddress("BASE_SEPOLIA_WETH9_ADDRESS");
        address pythAddress = vm.envAddress("BASE_SEPOLIA_PYTH_ADDRESS");
        bytes32 pythFeedId = vm.envBytes32("PYTH_ETHUSDC_FEED");

        vm.startBroadcast(deployerPrivateKey);

        FightNightTokenFactory fntf = new FightNightTokenFactory(
            sourceBridge, 
            destinationBridge,
            uniswapRouter,
            usdcAddress,
            nativeAddress,
            pythAddress,
            pythFeedId
        );

        fntf.createToken("test token", "FNTEST");

        vm.stopBroadcast();
    }
}

contract DeployOnOP is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address sourceBridge = vm.envAddress("OP_SEPOLIA_CCIPBRIDGE_ADDRESS");
        address destinationBridge = vm.envAddress("CCIP_DESTINATION");

        address uniswapRouter = vm.envAddress("OP_SEPOLIA_UNISWAPV3ROUTER_ADDRESS");
        address usdcAddress = vm.envAddress("OP_SEPOLIA_USDC_ADDRESS");
        address nativeAddress = vm.envAddress("OP_SEPOLIA_WETH9_ADDRESS");
        address pythAddress = vm.envAddress("OP_SEPOLIA_PYTH_ADDRESS");
        bytes32 pythFeedId = vm.envBytes32("PYTH_ETHUSDC_FEED");

        vm.startBroadcast(deployerPrivateKey);

        FightNightTokenFactory fntf = new FightNightTokenFactory(
            sourceBridge, 
            destinationBridge,
            uniswapRouter,
            usdcAddress,
            nativeAddress,
            pythAddress,
            pythFeedId
        );

        fntf.createToken("test token", "FNTEST");

        vm.stopBroadcast();
    }
}