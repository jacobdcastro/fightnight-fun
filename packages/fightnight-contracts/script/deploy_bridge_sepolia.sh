# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script --chain sepolia script/CCIPBridge.s.sol:MyScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
