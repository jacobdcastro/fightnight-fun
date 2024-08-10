// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../lib/forge-std/src/Script.sol";

contract deployOnSepolia is Script {
    address[] owners = [0x7d1c044792E428B47e1749068E4d918964F2C4B9, 0x9BE515CdEaf4a385eE16815d9979abFA914aF3Ed];
    address appBridge = 0x3604756f4806e3F8776835840850d5F0AF915704;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
    }
}
