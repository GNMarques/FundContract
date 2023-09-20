//SPDX-License-Identifier

pragma solidity ^0.8.18;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {Fund} from "../src/Fund.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract FundFund is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFund(address mostRecentDeployed) public {
        vm.startBroadcast();
        Fund(payable(mostRecentDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Contract Funded");
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "Fund",
            block.chainid
        );
        fundFund(mostRecentDeployed);
    }
}

contract WithdrawFund is Script {
    function withdrawFund(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        Fund(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Fund",
            block.chainid
        );
        withdrawFund(mostRecentlyDeployed);
    }
}
