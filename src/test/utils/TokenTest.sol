// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "ds-test/test.sol";

import "../../Token.sol";
import "./Hevm.sol";

contract User {
    Token internal token;

    constructor(Token _token) {
        token = _token;
    }

    function mintTTT(address to, uint256 amount) public {
        token.mintTTT(to, amount);
    }

    function approve(address spender, uint256 amount) public {
        token.approve(spender, amount);
    }

    function transfer(address recipient, uint256 amount) public {
        token.transfer(recipient, amount);
    }
}

abstract contract TokenTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    // contracts
    Token internal token;
    User internal owner;
    User internal user;

    function setUp() public virtual {
        token = new Token();
        owner = new User(token);
        user = new User(token);
        token.transferOwnership(address(owner));
    }
}
