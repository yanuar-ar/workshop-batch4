// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimulationTest is Test {
    function setUp() public {
        vm.createSelectFork("https://base-mainnet.g.alchemy.com/v2/_la8rBjNfaXB9SJvQF2EsdBdsO-J1p1J", 29633558);
    }

    function test_Simulation() public {
        console.log(
            IERC20(0x4200000000000000000000000000000000000006).balanceOf(0xE9fDd7aB2C06cc0Cc1E5D6aAAb34E3DCDF6769B4)
        );
    }
}
