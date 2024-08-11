#!/bin/bash

source .env

forge script --chain $BASE_SEPOLIA_CHAINID ./script/CCIPBridge.s.sol:DeployOnBase --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify --etherscan-api-key $BASE_EXPLORER_API_KEY -vvvv --via-ir
