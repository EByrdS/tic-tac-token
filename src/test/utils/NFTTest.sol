// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "ds-test/test.sol";

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "../../NFT.sol";
import "../../TicTacToken.sol";
import "../../Token.sol";
import "./Hevm.sol";

contract Player is ERC721Holder {
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

contract User is ERC721Holder {
    NFT internal nft;

    constructor(NFT _nft) {
        nft = _nft;
    }

    function mint(address to, uint256 tokenId) public {
        nft.mint(to, tokenId);
    }

    function setTTT(ITicTacToken ttt) public {
        nft.setTTT(ttt);
    }
}

abstract contract NFTTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);
    string internal constant EMPTY = "_";
    string internal constant X = "X";
    string internal constant O = "O";

    // contracts
    TicTacToken internal ttt;
    NFT internal nft;
    Token internal token;
    User internal admin;
    User internal playerX;
    User internal playerO;

    Player internal tttPlayerX;
    Player internal tttPlayerO;

    function setUp() public virtual {
        nft = new NFT();
        token = new Token();
        ttt = new TicTacToken(address(token), address(nft));
        nft.setTTT(ITicTacToken(address(ttt)));
        nft.transferOwnership(address(ttt));
        admin = new User(nft);
        playerX = new User(nft);
        playerO = new User(nft);
        tttPlayerX = new Player();
        tttPlayerO = new Player();
        tttPlayerX.setTTT(address(ttt));
        tttPlayerO.setTTT(address(ttt));

        payable(address(tttPlayerX)).transfer(1 ether);
        payable(address(tttPlayerO)).transfer(1 ether);
    }
}
