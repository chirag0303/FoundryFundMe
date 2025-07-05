// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import{DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {DepositFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // fake user
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SENDING_AMOUNT = 0.1 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        DepositFundMe deposit = new DepositFundMe();
        deposit.deopsitFundMe(address(fundMe));

        WithdrawFundMe withdraw = new WithdrawFundMe();
        withdraw.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }

}