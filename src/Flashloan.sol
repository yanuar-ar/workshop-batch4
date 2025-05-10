// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IAave {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf)
        external;
}

// BALANCER
interface IFlashloan {
    function flashLoan(address recipient, address[] memory tokens, uint256[] memory amounts, bytes calldata userData)
        external;
}

contract Flashloan {
    address uniswapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address aave = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
    address balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    function loopingSupply(uint256 supplyAmount, uint256 borrowAmount) external {
        IERC20(weth).transferFrom(msg.sender, address(this), supplyAmount);

        address[] memory tokens = new address[](1);
        tokens[0] = usdc;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = borrowAmount;

        IFlashloan(balancerVault).flashLoan(address(this), tokens, amounts, abi.encode(supplyAmount, borrowAmount));
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory data
    ) external {
        // decode data
        (uint256 supplyAmount, uint256 borrowAmount) = abi.decode(data, (uint256, uint256));

        // approve ke uniswapRouter
        IERC20(usdc).approve(uniswapRouter, borrowAmount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: usdc,
            tokenOut: weth,
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: borrowAmount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // lakukan proses swap
        uint256 outputWeth = ISwapRouter(uniswapRouter).exactInputSingle(params);

        // supply ke aave
        uint256 totalEth = supplyAmount + outputWeth;

        // supply ke aave
        IERC20(weth).approve(aave, totalEth);
        IAave(aave).supply(weth, totalEth, address(this), 0);

        // borrow ke aave
        IAave(aave).borrow(usdc, borrowAmount, 2, 0, address(this));

        // bayar flashloan ke Balancer
        IERC20(usdc).transfer(balancerVault, borrowAmount);
    }
}
