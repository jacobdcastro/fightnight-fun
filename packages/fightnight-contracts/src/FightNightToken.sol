// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";
import {CCIPPTT} from "./CCIPPTT.sol";
import {ISwapRouter} from "./uni/ISwapRouter.sol";


contract FightNightToken is ERC20, Ownable {
    /* 
    Market cap variables 
    */
    uint256 marketCap;
    uint256 marketCapTolerance;
    bool isTradable = true;

    error ErrMarketCapInvalid(uint256 marketCap, uint256 marketCapTolerance);
    error ErrMarketCapExceeded(uint256 marketCap, uint256 marketCapTolerance, uint256 totalSupply, uint256 amount);
    error ErrMarketCapReached(uint256 marketCap, uint256 marketCapTolerance, uint256 totalSupply);

    event MarketCapReached(uint256 marketCap, uint256 marketCapTolerance, uint256 totalSupply);

    modifier whenTradable() {
        if (!isTradable) {
            revert ErrMarketCapReached(marketCap, marketCapTolerance, totalSupply());
        }
        _;
    }

    /* 
    Bonding curve variables 
    */
    uint256 public constant DECIMALS = 18**10;
    uint256 public reserveBalance = 10 * DECIMALS;
    uint256 public reserveRatio;

    event Mint(address to, uint256 amountMinted, uint256 amountDeposited);

    /* 
    Bridge variables
    */
    address public immutable ccipBridge;

    /* 
    Swap variables
    */
    bool hasSwapped = false;
    ISwapRouter public immutable swapRouter;
    address immutable usdcAddress;
    address immutable nativeAddress;

    IPyth pyth;
    address immutable pythAddress;
    address immutable pythFeedId;
    

    /* 
    
    Core logic 
    
    */
    constructor(
        address initialOwner, 
        string memory name_, 
        string memory symbol_, 
        uint256 marketCap_, 
        uint256 marketCapTolerance_,
        uint256 reserveRatio_,
        address _ccipBridge,
        ISwapRouter _uniswapRouter,
        address _usdcAddress,
        address _nativeAddress,
        address _pythAddress,
        address _pythFeedId
    ) ERC20(name_, symbol_) Ownable(initialOwner) {
        _checkValidMarketCap(marketCap_, marketCapTolerance_);
        marketCap = marketCap_;
        marketCapTolerance = marketCapTolerance_;
        reserveRatio = reserveRatio_;

        ccipBridge = _ccipBridge;

        swapRouter = _uniswapRouter;
        usdcAddress = _usdcAddress;
        nativeAddress = _nativeAddress;
        pyth = IPyth(_pythAddress);
        pythFeedId = _pythFeedId;
    }

    function mint(bytes[] calldata priceUpdate) whenTradable public payable returns (uint256) {
        uint256 deposit = msg.value;

        require(deposit > 0, "Deposit must be non-zero.");

        // Prime oracle
        _updatePrice(priceUpdate);

        uint256 purchasedAmount = _calculatePurchase(totalSupply(), reserveBalance, reserveRatio, deposit);
        _customMint(msg.sender, purchasedAmount);
        reserveBalance += deposit;

        emit Mint(msg.sender, purchasedAmount, deposit);
        return purchasedAmount;
    }

    function _update(address from, address to, uint256 value) whenTradable internal virtual override {
        _checkWithinMarketCap(value);

        super._update(from, to, value);

        if (totalSupply() > _marketCapLowerBound()) {
            emit MarketCapReached(marketCap, marketCapTolerance, totalSupply());
            isTradable = false;
            uint256 amount = _swapForUSDC();
            _bridgeFunds(amount);
        }
    }

    function _customMint(address account, uint256 value) internal returns (bytes32) {
        _checkWithinMarketCap(value);

        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }

        _update(address(0), account, value);
    }

    function _bridgeFunds(uint256 amount) internal {
        CCIPPTT ccip = CCIPPTT(ccipBridge);



        Client.EVM2AnyMessage message = ccip._buildCCIPMessage(
            _receiverAddress,
            "",
            usdcAddress,
            amount,
            nativeAddress
        );
        bytes32 messageId = ccip.sendMessagePayNative(message);
        return messageId;
        // bridge logic
    }

    /* 
    
    Swap logic

    */
    function _pullBasePrice() internal returns(PythStructs.Price memory) {
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceFeedId, 60);
        return price;
    }

    function _updatePrice(bytes[] calldata priceUpdate) internal {
        uint fee = pyth.getUpdateFee(priceUpdate);
        pyth.updatePriceFeeds{ value: fee }(priceUpdate);
    }

    function _swapForUSDC() internal returns (uint256) {
        PythStructs.Price memory price = _pullPrice();

        uint256 nativeBalance = balanceOf(address(this));
        uint256 amountOutIdeal = price.price * nativeBalance;
        uint256 amountOutMinimum = amountOutIdeal - (amountOutIdeal * 10 / 100);


        // TODO: fetch instead of hardcode
        uint256 poolFee = 3000;
        uint256 deadline = block.timestamp + 60 * 20;
        
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: nativeAddress,
                tokenOut: usdcAddress,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: nativeBalance,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut = swapRouter.exactInputSingle(params);

        return amountOut;
    }

    /* 

    Market Cap logic

    */
    function _checkValidMarketCap(uint256 _cap, uint256 _capTolerance) internal pure {
        if (_cap == 0 || _capTolerance == 0) {
            revert ErrMarketCapInvalid(_cap, _capTolerance);
        }
    }
    function _marketCapUpperBound() internal view returns (uint256) {
        return marketCap + ((marketCap * marketCapTolerance) / 100);
    }
    function _marketCapLowerBound() internal view returns (uint256) {
        return marketCap - ((marketCap * marketCapTolerance) / 100);
    }
    function _checkWithinMarketCap(uint256 _amount) internal view {
        if (_amount + totalSupply() > _marketCapUpperBound()) {
            revert ErrMarketCapExceeded(marketCap, marketCapTolerance, totalSupply(), _amount);
        }
    }

    /* 
    
    Bonding curve logic 

    */
    function _calculatePurchase(
        uint256 _totalSupply,
        uint256 _reserveBalance,
        uint256 _reserveRatio,
        uint256 _depositAmount
    )   internal
        pure
        returns (uint256)
    {
        uint256 newTotal = _totalSupply + _depositAmount;
        uint256 newPrice = (newTotal * newTotal / DECIMALS) * (newTotal / DECIMALS);

        return _sqrt(newPrice) * _reserveRatio - _reserveBalance;
    }

    function _calculateSale(
        uint256 _totalSupply,
        uint256 _reserveBalance,
        uint256 _reserveRatio,
        uint256 _sellAmount
    )   internal
        pure
        returns (uint256)
    {
        uint256 newTotal = _totalSupply - _sellAmount;
        uint256 newPrice = (newTotal * newTotal / DECIMALS) * (newTotal / DECIMALS);

        return _reserveBalance - _sqrt(newPrice) * _reserveRatio;
    }

    function _sqrt(
      uint256 x
    ) internal pure returns (uint256 y)
    {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = ((x / z) + z) / 2;
        }
    }
}