//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Fund} from "../../src/Fund.sol";
import {DeployFund} from "../../script/DeployFund.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {FundFund, WithdrawFund} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    Fund public fund;
    HelperConfig public helperConfig;
    address public constant USER = address(1);
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STTARTING_BALANCE = 10 ether;
    uint256 constant GAS_ORICE = 1;

    function setUp() external {
        DeployFund deploy = new DeployFund();
        (fund, helperConfig) = deploy.run();
        vm.deal(USER, STTARTING_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundFund fundFund = new FundFund();
        fundFund.fundFund(address(fund));

        WithdrawFund withdrawFund = new WithdrawFund();
        withdrawFund.withdrawFund(address(fund));

        assert(address(fund).balance == 0);
    }
}
