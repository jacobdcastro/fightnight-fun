// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../lib/forge-std/src/Script.sol";
import { ProgrammableTokenTransfers } from "../src/CCIPPTT.sol";

contract deployOnSepolia is Script {
    address[] owners = [0x7d1c044792E428B47e1749068E4d918964F2C4B9, 0x9BE515CdEaf4a385eE16815d9979abFA914aF3Ed];
    address appBridge = 0x3604756f4806e3F8776835840850d5F0AF915704;

    address sepoliaRouter = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address sepoliaLink = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address sepoliaWeth = 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ProgrammableTokenTransfers ccipppt = new ProgrammableTokenTransfers(sepoliaRouter, sepoliaLink, owners, appBridge);

        vm.stopBroadcast();
    }
}
