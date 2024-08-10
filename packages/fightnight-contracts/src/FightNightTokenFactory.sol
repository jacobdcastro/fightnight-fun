// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
pragma abicoder v2;

import {FightNightToken} from "./FightNightToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {ISwapRouter} from "./uni/ISwapRouter.sol";

// TODO: ensure same symbol/name can't be created
contract FightNightTokenFactory is Ownable {
    address[] public deployedTokens;

    uint256 public marketCap = 100;
    uint256 public marketCapTolerance = 10;
    uint256 public reserveRatio = 10;

    address public ccipBridge;
    ISwapRouter uniswapRouterl;

    address usdcAddress;
    address nativeAddress;
    address pythAddress;
    address pythFeedId;

    event TokenCreated(address indexed tokenAddress, address creator);
    event MarketCapSet(uint256 marketCap, uint256 marketCapTolerance);
    event ReserveRatioSet(uint256 reserveRatio);
    event ccipBridgeSet(address ccipBridge);

    constructor(address _ccipBridge,
                address _uniswapRouter,
                address _usdcAddress,
                address _nativeAddress,
                address _pythAddress,
                address _pythFeedId) {
        uniswapRouter = ISwapRouter(_uniswapRouter, _nativeAddress);
        usdcAddress = _usdcAddress;
        nativeAddress = _nativeAddress;
        pythAddress = _pythAddress;
        pythFeedId = _pythFeedId;
        ccipBridge = _ccipBridge;
    }

    function createToken(string memory name, string memory symbol) public returns (FightNightToken) {
        FightToken token = new FightNightToken(
            msg.sender,
            name, 
            symbol, 
            marketCap, 
            marketCapTolerance, 
            reserveRatio,
            ccipBridge,
            uniswapRouter,
            usdcAddress,
            nativeAddress,
            pythAddress,
            pythFeedId
        );

        address tokenAddress = address(token);

        deployedTokens.push(tokenAddress);

        emit TokenCreated(tokenAddress, msg.sender);
        return token;
    }

    function getDeployedTokens() public view returns (address[] memory) {
        return deployedTokens;
    }

    function setMarketCap(uint256 _marketCap, uint256 _marketCapTolerance) onlyOwner public  {
        marketCap = _marketCap;
        marketCapTolerance = _marketCapTolerance;

        emit MarketCapSet(_marketCap, _marketCapTolerance);
    }

    function setCCIPBridge(address _ccipBridge) onlyOwner public {
        ccipBridge = _ccipBridge;

        emit ccipBridgeSet(_ccipBridge);
    }

    function setReserveRatio(uint256 _reserveRatio) onlyOwner public {
        reserveRatio = _reserveRatio;

        emit ReserveRatioSet(_reserveRatio);
    }
}