// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../../TicTacToken.sol";
import "../../NFT.sol";
import "../../Token.sol";
import "./Hevm.sol";

contract User is ERC721Holder {
    TicTacToken internal ttt;

    // is this the right way of doing it?
    // which way should be done so that the linter doesn't complain?
    // is this function inherited?
    receive() external payable {}

    function setTTT(address _ttt) public {
        ttt = TicTacToken(payable(_ttt));
    }

    function move(uint256 gameID, uint8 cellIndex) public {
        ttt.move(gameID, cellIndex);
    }

    function newGameAsX(uint amount) public returns (uint) {
        return ttt.newGameAsX{value: amount}();
    }

    function newGameAsO(uint amount) public returns (uint) {
        return ttt.newGameAsO{value: amount}();
    }

    function stakeAndJoin(uint gameId, uint amount) public {
        ttt.stakeAndJoin{value: amount}(gameId);
    }

    function claimStake(uint gameId) public {
        ttt.claimStake(gameId);
    }

    function recoverFees() public {
        ttt.recoverFees();
    }
}

abstract contract TicTacTokenTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    TicTacToken internal tttoken;
    User internal playerX;
    User internal playerO;
    User internal nonplayer;

    NFT internal nft;
    Token internal token;

    receive() external payable {}


    function setUp() public virtual {
        playerX = new User();
        playerO = new User();
        nonplayer = new User();

        nft = new NFT();
        token = new Token();
        tttoken = new TicTacToken(address(token), address(nft));

        nft.setTTT(ITicTacToken(address(tttoken)));
        nft.transferOwnership(address(tttoken));

        playerX.setTTT(address(tttoken));
        playerO.setTTT(address(tttoken));
        nonplayer.setTTT(address(tttoken));

        payable(address(playerX)).transfer(1 ether);
        payable(address(playerO)).transfer(1 ether);
        payable(address(nonplayer)).transfer(1 ether);
    }
}
