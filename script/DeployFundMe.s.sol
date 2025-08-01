// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HeplerConfig.s.sol";
contract DeployFundMe is Script {
    function run() external returns (FundMe){
         
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // Sepolia ETH/USD Price Feed Address
        vm.stopBroadcast();
        return fundMe;
    }
}