// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import{DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // fake user
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SENDING_AMOUNT = 0.1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
        
    }

    function testMINIMUM_USD() public view{
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public view{
        console.log(msg.sender, fundMe.getOwner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersion() public view{
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testEnoughEth() public  {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesMappings() public {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SENDING_AMOUNT}();

        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, SENDING_AMOUNT);
    }

    function testFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: SENDING_AMOUNT}();

        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SENDING_AMOUNT}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded{

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw(); // this line should fail as USER is not the owner but expectRevert()expects it to fail So the test will pass
    }

    function testWithdrawSingleFunder() public funded {
        //arrange
        uint256 startingOwnerBal = fundMe.getOwner().balance;
        uint256 startingFundMeBal = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint256 endingOwnerBal = fundMe.getOwner().balance;
        uint256 endingFundMeBal = address(fundMe).balance;
        assertEq(endingFundMeBal,0);
        assertEq(startingFundMeBal + startingOwnerBal, endingOwnerBal);
    }

    function testWithdrawMultipleFunder() public funded {
        //assert
        uint160 totalFunders = 10;
        for(uint160 i=1; i<totalFunders; i++){
            hoax(address(i),STARTING_BALANCE); //hoax is combined of prank() and deal();
            fundMe.fund{value: SENDING_AMOUNT}();

            console.log(fundMe.getFunders(i));
        }

        uint256 startingOwnerBal = fundMe.getOwner().balance;
        uint256 startingFundMeBal = address(fundMe).balance;

        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBal + startingOwnerBal, fundMe.getOwner().balance);

    }

    function testWithdrawMultipleFunderCheaper() public funded {
        //assert
        uint160 totalFunders = 10;
        for(uint160 i=1; i<totalFunders; i++){
            hoax(address(i),STARTING_BALANCE); //hoax is combined of prank() and deal();
            fundMe.fund{value: SENDING_AMOUNT}();

            console.log(fundMe.getFunders(i));
        }

        uint256 startingOwnerBal = fundMe.getOwner().balance;
        uint256 startingFundMeBal = address(fundMe).balance;

        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawCheaper();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startingFundMeBal + startingOwnerBal, fundMe.getOwner().balance);

    }

}