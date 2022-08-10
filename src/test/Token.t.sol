// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./utils/TokenTest.sol";

contract TestToken is TokenTest {
    function testHasName() public {
        assertEq(token.name(), "Tic Tac Token (Genesis Block)");
    }

    function testHasSymbol() public {
        assertEq(token.symbol(), "TTT.0");
    }

    function testHasDecimals() public {
        assertEq(token.decimals(), 18);
    }

    function testInitialtotalSupplyIsZero() public {
        assertEq(token.totalSupply(), 0);
    }

    function testOwnerCanIncreaseTotalSupply() public {
        uint256 amountToIncrease = 10;

        assertEq(token.totalSupply(), 0);
        owner.mintTTT(address(owner), amountToIncrease);

        assertEq(token.totalSupply(), amountToIncrease);
    }

    function testFailNonownerCannotIncreateTotalSupply() public {
        uint256 amountToIncrease = 10;

        assertEq(token.totalSupply(), 0);
        user.mintTTT(address(user), amountToIncrease);
    }

    function testMintingIncreasesAccountBalance() public {
        uint256 amountToIncrease = 10;

        assertEq(token.balanceOf(address(owner)), 0);
        owner.mintTTT(address(owner), amountToIncrease);

        assertEq(token.balanceOf(address(owner)), amountToIncrease);
    }

    function testTransferringAmountIncreasesRecipientAccountBalance()
        public
    {
        uint256 amountToTransfer = 5;

        assertEq(token.balanceOf(address(user)), 0);
        owner.mintTTT(address(owner), 10);
        owner.transfer(address(user), amountToTransfer);

        assertEq(token.balanceOf(address(user)), amountToTransfer);
    }

    function testTransferByAThirdPartyContract() public {
        uint256 amountToTransfer = 5;

        assertEq(token.balanceOf(address(user)), 0);
        owner.mintTTT(address(owner), 10);
        owner.approve(address(this), amountToTransfer);
        token.transferFrom(address(owner), address(user), amountToTransfer);

        assertEq(token.balanceOf(address(user)), amountToTransfer);
    }
}
