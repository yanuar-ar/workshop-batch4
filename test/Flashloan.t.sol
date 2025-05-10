// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Flashloan} from "../src/Flashloan.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashloanTest is Test {
    Flashloan public flashloan;

    address weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address aWeth = 0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI", 335104419);
        flashloan = new Flashloan();
    }

    function test_loopingSupply() public {
        // mock 1 WETH
        deal(weth, address(this), 1e18);

        IERC20(weth).approve(address(flashloan), 1e18);

        // eksekusi looping sebesar supply 1 WETH dan borrow 2350 USDC
        flashloan.loopingSupply(1e18, 2350e6);

        assertGt(IERC20(aWeth).balanceOf(address(flashloan)), 1e18);
        console.log("aWeth balance", IERC20(aWeth).balanceOf(address(flashloan)));
    }
}
