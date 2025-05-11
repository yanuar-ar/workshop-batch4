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
}
