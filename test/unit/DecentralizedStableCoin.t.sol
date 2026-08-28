// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedStableCoinTest is Test {
    DecentralizedStableCoin dsc;
    address public owner = address(this);
    address public user = makeAddr("user");
    uint256 public constant AMOUNT = 100 ether;

    function setUp() public {
        dsc = new DecentralizedStableCoin(owner);
    }

    function testConstructorSetsNameSymbolAndOwner() public view {
        assertEq(dsc.name(), "DecentralizedStableCoin");
        assertEq(dsc.symbol(), "DSC");
        assertEq(dsc.owner(), owner);
    }

    function testMintRevertsIfNotOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        dsc.mint(user, AMOUNT);
    }

    function testMintRevertsIfToZeroAddress() public {
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__NotZeroAddress.selector);
        dsc.mint(address(0), AMOUNT);
    }

    function testMintRevertsIfAmountIsZero() public {
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.mint(owner, 0);
    }

    function testMintSucceeds() public {
        bool minted = dsc.mint(owner, AMOUNT);
        assertTrue(minted);
        assertEq(dsc.balanceOf(owner), AMOUNT);
        assertEq(dsc.totalSupply(), AMOUNT);
    }

    function testBurnRevertsIfNotOwner() public {
        dsc.mint(owner, AMOUNT);
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        dsc.burn(AMOUNT);
    }

    function testBurnRevertsIfAmountIsZero() public {
        dsc.mint(owner, AMOUNT);
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.burn(0);
    }

    function testBurnRevertsIfAmountExceedsBalance() public {
        dsc.mint(owner, AMOUNT);
        vm.expectRevert(DecentralizedStableCoin.DecentralizedStableCoin__BurnAmountExceedsBalance.selector);
        dsc.burn(AMOUNT + 1);
    }

    function testBurnSucceeds() public {
        dsc.mint(owner, AMOUNT);
        dsc.burn(AMOUNT / 2);
        assertEq(dsc.balanceOf(owner), AMOUNT / 2);
        assertEq(dsc.totalSupply(), AMOUNT / 2);
    }
}
