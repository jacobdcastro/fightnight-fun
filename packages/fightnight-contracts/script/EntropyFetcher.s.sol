// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../lib/forge-std/src/Script.sol";
import {EntropyFetcher} from "../src/game/EntropyFetcher.sol";


contract DeployEntropy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        EntropyFetcher ef = new EntropyFetcher(
            vm.envAddress("PYTH_ENTROPY_ADDRESS")
        );

        EntropyFetcher(ef).requestNumber();

        vm.stopBroadcast();
    }
}
