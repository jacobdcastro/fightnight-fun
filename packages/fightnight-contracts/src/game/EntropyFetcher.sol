// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IEntropyConsumer} from "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import {IEntropy} from "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";

contract EntropyFetcher is IEntropyConsumer {
    IEntropy entropy;
    address entropyProvider;
    uint256 public number;

    event NumberRequested(uint64 sequenceNumber);
    event NumberReceived(uint256 _number);

    constructor(address _entropyAddress) {
        entropy = IEntropy(_entropyAddress);
        entropyProvider = entropy.getDefaultProvider();
    }

    function requestNumber() external {}

    function entropyCallback(
        uint64 sequence,
        address provider,
        bytes32 randomNumber
    ) internal override {
        emit NumberReceived(uint256(randomNumber));
        number = uint256(randomNumber);
    }

    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

    function request(bytes32 userRandomNumber) external payable {
        uint128 requestFee = entropy.getFee(entropyProvider);
        if (msg.value < requestFee) revert("not enough fees");

        uint64 sequenceNumber = entropy.requestWithCallback{value: requestFee}(
            entropyProvider,
            userRandomNumber
        );

        // emit event
        emit NumberRequested(sequenceNumber);
    }
}
