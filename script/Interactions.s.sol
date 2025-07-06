// SPDX-License-Identifier: MIT

//Fund
//Withdraw

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract DepositFundMe is Script {
    uint256 constant AMOUNT = 0.01 ether;

    function deopsitFundMe(address recentlyDeployed) public{
        vm.startBroadcast();
        FundMe(payable(recentlyDeployed)).fund{value: AMOUNT}();
        vm.stopBroadcast();
        console.log("Funded contract with %s",AMOUNT);

    }
    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",block.chainid
        );
        vm.startBroadcast();
        deopsitFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address recentlyDeployed) public{
        vm.startBroadcast();
        FundMe(payable(recentlyDeployed)).withdraw();
        vm.stopBroadcast();

    }
    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",block.chainid
        );
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployment);
        vm.stopBroadcast();
    }

}