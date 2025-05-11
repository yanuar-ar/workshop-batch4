// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Swap {
    address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    function swap(uint256 amountIn) external {
        // transfer dari user ke vault
        IERC20(weth).transferFrom(msg.sender, address(this), amountIn);

        // approve ke router Uniswap
        IERC20(weth).approve(uniswapRouter, amountIn);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: weth,
            tokenOut: usdc,
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        ISwapRouter(uniswapRouter).exactInputSingle(params);
    }
}
