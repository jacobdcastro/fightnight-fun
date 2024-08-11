// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IGame} from "./IGame.sol";

contract SampleGame is IGame {
    string label = "Sample Game";
    address warden;
    address reporter;
    address[] players;
    address[] rankings;
    mapping(address => uint256) playerGuess;
    bool isLive;
    uint256 finalNumber;
    uint256 MAX_GUESS = 2**256 - 1;
    uint256 id;

    error GameAlreadyStarted();
    error GameStillRunning();

    event GameStarted();
    event GameEnded();
    event GuessMade(address player, uint256 guess);

    modifier OnlyWarden() {
        require(msg.sender == warden, "Only the warden can call this function");
        _;
    }

    modifier OnlyReporter() {
        require(msg.sender == reporter, "Only the reporter can call this function");
        _;
    }

    modifier OnlyPlayers() {
        bool isPlayer = false;
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                isPlayer = true;
                break;
            }
        }
        require(isPlayer, "Only players can call this function");
        _;
    }

    constructor(address _warden, address _reporter, uint256 _id) {
        warden = _warden;
        reporter = _reporter;
        id = _id;
    }

    function isRunning() public view returns (bool) {
        return isLive;
    }

    function getRankings() external view returns (address[] memory) {
        if (isLive) {
            revert GameStillRunning();
        }

        return rankings;
    }

    function start(address[] calldata _players) external OnlyWarden {
        if (isLive || players.length != 0) {
            revert GameAlreadyStarted();
        }

        players = _players;

        emit GameStarted();
        isLive = true;
    }

    function forceStop() external OnlyWarden {
        _endGame();
        emit GameEnded();
    }

    function makeGuess(uint256 guess) external OnlyPlayers {
        require(isLive, "Game is not live");
        require(playerGuess[msg.sender] == 0, "Player has already made a guess");

        playerGuess[msg.sender] = guess;
        emit GuessMade(msg.sender, guess);
    }

    function getId() external view returns (uint256) {
        return id;
    }

    // TODO: Change to Oracle call triggered by last guess or force stop
    function setFinalNumber(uint256 number) public OnlyReporter {
        if (isLive) {
            revert GameStillRunning();
        }

        finalNumber = number;
        _endGame();
    }

    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    function changeReporter(address newReporter) public OnlyWarden {
        reporter = newReporter;
    }

    function _endGame() internal {
        isLive = false;
        _populateRankings();
        emit GameEnded();
    }

    function _populateRankings() internal {
        require(!isLive, "Game is still running");
        require(rankings.length == 0, "Rankings already populated");
        require(finalNumber != 0, "Final number not set");

        address[] memory _rankings = new address[](players.length);
        uint256[] memory distances = new uint256[](players.length);

        for (uint i = 0; i < players.length; i++) {
            distances[i] = playerGuess[players[i]] > finalNumber ? playerGuess[players[i]] - finalNumber : finalNumber - playerGuess[players[i]];
        }

        for (uint i = 0; i < players.length; i++) {
            uint256 maxDistance = 0;
            uint256 maxIndex = 0;
            for (uint j = 0; j < players.length; j++) {
                if (distances[j] > maxDistance) {
                    maxDistance = distances[j];
                    maxIndex = j;
                }
            }
            _rankings[i] = players[maxIndex];
            distances[maxIndex] = 0;
        }

        rankings = _rankings;
    }
}