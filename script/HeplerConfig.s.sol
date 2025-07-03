// SPDX-License-Identifier: MIT

//deploy mocks on anvil chain
// keep track of the different pricefeed across diff chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // if we are on local chain deploy mocks
    // otherwise grap existing feeds from live networks

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig {
        address priceFeed;
    }
    constructor() {
        if (block.chainid == 11155111){
            activeNetworkConfig = sepoliaConfig();
        } else if (block.chainid == 1){
            activeNetworkConfig = mainnetConfig();
        } else {
            activeNetworkConfig = anvilConfig();
        }
    }

    function sepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepolia = NetworkConfig({
            priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepolia;

    }
    function mainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethereum = NetworkConfig({
            priceFeed : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethereum;

    }

    function anvilConfig() public  returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        
        vm.stopBroadcast();

        NetworkConfig memory anvil = NetworkConfig({priceFeed : address(mockPriceFeed)});
        return anvil;
    }
}