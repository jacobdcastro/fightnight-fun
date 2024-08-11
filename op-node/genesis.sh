#!/bin/bash

./bin/op-node genesis l2 \
  --deploy-config ../packages/contracts-bedrock/deploy-config/fightnight-fun.json \
  --l2-allocs ../packages/contracts-bedrock/deployments/allocs.json \
  --l1-deployments ../packages/contracts-bedrock/deployments/allocs.json \
  --outfile.l2 genesis.json \
  --outfile.rollup rollup.json \
  --l1-rpc $ETH_RPC_URL
