#!/bin/bash

source .env

forge script --chain $OP_SEPOLIA_CHAINID ./script/EntropyFetcher.s.sol:DeployEntropy --rpc-url $OP_SEPOLIA_RPC_URL --broadcast --verify --etherscan-api-key $OP_EXPLORER_API_KEY -vvvv --via-ir
