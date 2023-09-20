//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Fund} from "../../src/Fund.sol";
import {DeployFund} from "../../script/DeployFund.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundTest is Test {
    Fund public fund;
    HelperConfig public helperConfig;
    address public constant USER = address(1);
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STTARTING_BALANCE = 10 ether;
    uint256 constant GAS_ORICE = 1;

    modifier funded() {
        vm.prank(USER);
        fund.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        DeployFund deployer = new DeployFund();
        (fund, helperConfig) = deployer.run();
        vm.deal(USER, STTARTING_BALANCE);
    }

    function testMinimunmUSDEqualToFive() public {
        assertEq(fund.MINIMUM_USD(), 5e18);
    }

    function testIfOwnerIsMsgSender() public {
        assertEq(fund.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fund.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsIfNotEnoughEth() public {
        vm.expectRevert(); // The next line should revert
        fund.fund();
    }

    function testFunctionUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fund.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fund.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fund.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fund.getOwner().balance;
        uint256 startingContractBalance = address(fund).balance;
        //Act
        vm.prank(fund.getOwner());
        fund.withdraw();
        //Assert
        uint256 endingOwnerBalance = fund.getOwner().balance;
        uint256 endingContractBalance = address(fund).balance;
        assertEq(endingContractBalance, 0);
        assertEq(
            startingOwnerBalance + startingContractBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (
            uint160 i = startingIndex;
            i < numberOfFunders + startingIndex;
            i++
        ) {
            hoax(address(i), STTARTING_BALANCE); // vm.prank and vm.deal combined to fund each address
            fund.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fund.getOwner().balance;
        uint256 startingContractBalance = address(fund).balance;
        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_ORICE);
        vm.startPrank(fund.getOwner());
        fund.withdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        //Assert
        assert(address(fund).balance == 0);
        assert(
            startingContractBalance + startingOwnerBalance ==
                fund.getOwner().balance
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                fund.getOwner().balance - startingOwnerBalance
        );
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (
            uint160 i = startingIndex;
            i < numberOfFunders + startingIndex;
            i++
        ) {
            hoax(address(i), STTARTING_BALANCE); // vm.prank and vm.deal combined to fund each address
            fund.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fund.getOwner().balance;
        uint256 startingContractBalance = address(fund).balance;
        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_ORICE);
        vm.startPrank(fund.getOwner());
        fund.cheaperWithdraw();
        vm.stopPrank();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
        //Assert
        assert(address(fund).balance == 0);
        assert(
            startingContractBalance + startingOwnerBalance ==
                fund.getOwner().balance
        );
        assert(
            (numberOfFunders + 1) * SEND_VALUE ==
                fund.getOwner().balance - startingOwnerBalance
        );
    }
}
