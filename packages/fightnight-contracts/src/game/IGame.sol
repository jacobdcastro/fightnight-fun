// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

interface IGame {
    function start(address[] calldata players) external;
    function forceStop() external;
    function isRunning() external view returns (bool);
    function getRankings() external view returns (address[] memory);
    function getPlayers() external view returns (address[] memory);
    function getId() external view returns (uint256);
}