// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "./game/IGame.sol";
import "./game/SampleGame.sol";

contract GameWarden {
    address[] owners;
    IGame[] games;
    mapping(uint256 => uint256) balancesByGame;

    modifier OnlyOwners() {
        bool isOwner = false;
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Only owners can call this function");
        _;
    }

    constructor(address[] memory _owners) {
        owners = _owners;
        games = new IGame[](0);
    }

    function createNewSampleGame(address reporter, address[] calldata _players) payable public OnlyOwners returns (address) {
        uint256 id = games.length;
        SampleGame game = new SampleGame(address(this), reporter, id);
        games.push(game);

        _startGame(id, _players, msg.value);
    }

    function _startGame(uint256 gameId, address[] calldata _players, uint256 gameBalance) internal OnlyOwners {
        balancesByGame[gameId] = gameBalance;
        games[gameId].start(_players);
    }

    function killGame(uint256 gameId) public OnlyOwners {
        games[gameId].forceStop();
    }

    function payoutPlayers(uint256 gameId) public OnlyOwners {
        if (games[gameId].isRunning()) {
            revert SampleGame.GameStillRunning();
        }

        address[] memory rankings = games[gameId].getRankings();
        uint256 gameBalance = balancesByGame[gameId];

        for (uint i = 0; i < rankings.length / 2; i++) {
            uint256 payout = gameBalance / (2**i);

            balancesByGame[gameId] -= payout;

            if (balancesByGame[gameId] > 0) {
                payable(rankings[i]).transfer(payout);
            } else if (balancesByGame[gameId] > 0) {
                payable(rankings[i]).transfer(balancesByGame[gameId]);
            } else {
                break;
            }
        }
    }
}