// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Price} from "../src/Price.sol";

contract PriceTest is Test {
    Price public price;

    function setUp() public {
        vm.createSelectFork("https://arb-mainnet.g.alchemy.com/v2/Ea4M-V84UObD22z2nNlwDD9qP8eqZuSI", 335104419);
        price = new Price();
    }

    function test_getPrice() public {
        uint256 price = price.getPrice();
        console.log("price", price);
    }
}
