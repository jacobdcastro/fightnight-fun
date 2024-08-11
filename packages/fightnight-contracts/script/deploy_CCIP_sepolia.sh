#!/bin/bash

source .env

forge script --chain $OP_SEPOLIA_CHAINID ./script/CCIPBridge.s.sol:DeployOnSepolia --rpc-url $ETH_SEPOLIA_RPC_URL  --etherscan-api-key $ETH_EXPLORER_API_KEY  --broadcast --verify -vvvv --via-ir
