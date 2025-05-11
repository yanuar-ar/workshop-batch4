// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract Reksadana is ERC20 {
    // errors
    error ZeroAmount();
    error InsufficientShares();

    // events
    event Deposit(address user, uint256 amount, uint256 shares);
    event Withdraw(address user, uint256 shares, uint256 amount);

    address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    // tokens
    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address wbtc = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;

    address baseFeed = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3;
    address wbtcFeed = 0x6ce185860a4963106506C203335A2910413708e9;
    address wethFeed = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    constructor() ERC20("Reksadana", "RKS") {}

    function totalAsset() public returns (uint256) {
        // ambil harga usdc dalam usd
        (, int256 usdcPrice,,,) = IAggregatorV3(baseFeed).latestRoundData();

        // hitung harga wbtc dalam usdc
        (, int256 wbtcPrice,,,) = IAggregatorV3(wbtcFeed).latestRoundData();
        uint256 wbtcPriceInUsd = uint256(wbtcPrice) * 1e6 / uint256(usdcPrice);

        // hitung harga weth dalam usd
        (, int256 wethPrice,,,) = IAggregatorV3(wethFeed).latestRoundData();
        uint256 wethPriceInUsd = uint256(wethPrice) * 1e6 / uint256(usdcPrice);

        uint256 totalWethAsset = IERC20(weth).balanceOf(address(this)) * wethPriceInUsd / 1e18;
        uint256 totalWbtcAsset = IERC20(wbtc).balanceOf(address(this)) * wbtcPriceInUsd / 1e8;

        return totalWbtcAsset + totalWethAsset;
    }

    function deposit(uint256 amount) public {
        if (amount == 0) revert ZeroAmount();

        uint256 totalAsset = totalAsset();
        uint256 totalShares = totalSupply();

        uint256 shares = 0;
        if (totalShares == 0) {
            shares = amount;
        } else {
            shares = amount * totalShares / totalAsset;
        }

        IERC20(usdc).transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, shares);

        // swap
        uint256 amountIn = amount / 2;

        // swap usdc ke weth
        IERC20(usdc).approve(uniswapRouter, amountIn);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: usdc,
            tokenOut: weth,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        ISwapRouter(uniswapRouter).exactInputSingle(params);

        // swap usdc ke wbtc
        IERC20(usdc).approve(uniswapRouter, amountIn);
        params = ISwapRouter.ExactInputSingleParams({
            tokenIn: usdc,
            tokenOut: wbtc,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        ISwapRouter(uniswapRouter).exactInputSingle(params);

        emit Deposit(msg.sender, amount, shares);
    }

    function withdraw(uint256 shares) public {
        if (shares == 0) revert ZeroAmount();
        // shares tidak boleh lebih dari yang dimiliki user
        if (shares > balanceOf(msg.sender)) revert InsufficientShares();

        uint256 totalShares = totalSupply();
        uint256 PROPORTION_SCALED = 1e18;

        // hitung proporsi
        uint256 proportion = (shares * PROPORTION_SCALED) / totalShares;

        uint256 amountWbtc = IERC20(wbtc).balanceOf(address(this)) * proportion / PROPORTION_SCALED;
        uint256 amountWeth = IERC20(weth).balanceOf(address(this)) * proportion / PROPORTION_SCALED;

        _burn(msg.sender, shares);

        // swap wbtc ke usdc
        IERC20(wbtc).approve(uniswapRouter, amountWbtc);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: wbtc,
            tokenOut: usdc,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountWbtc,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        ISwapRouter(uniswapRouter).exactInputSingle(params);

        // swap weth ke usdc
        IERC20(weth).approve(uniswapRouter, amountWeth);
        params = ISwapRouter.ExactInputSingleParams({
            tokenIn: weth,
            tokenOut: usdc,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountWeth,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        ISwapRouter(uniswapRouter).exactInputSingle(params);

        uint256 amountUsdc = IERC20(usdc).balanceOf(address(this));
        IERC20(usdc).transfer(msg.sender, amountUsdc);

        emit Withdraw(msg.sender, shares, amountUsdc);
    }
}
