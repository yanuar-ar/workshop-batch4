// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    address public alice = makeAddr("Alice");
    address public bob = makeAddr("Bob");

    function setUp() public {
        token = new Token();
    }

    function test_Mint() public {
        token.mint(alice, 2000);
        assertEq(token.balanceOf(alice), 2000);
        console.log("balance of alice", token.balanceOf(alice));

        token.mint(bob, 3000);
        assertEq(token.balanceOf(bob), 3000);
        console.log("balance of bob", token.balanceOf(bob));
        token.mint(address(this), 1000);
        assertEq(token.balanceOf(address(this)), 1000);
        console.log("balance of this", token.balanceOf(address(this)));
    }
}
