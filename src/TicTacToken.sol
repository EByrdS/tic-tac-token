// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IToken.sol";
import "./interfaces/INFT.sol";

error MyError(string, uint, uint, uint);

contract TicTacToken {
    event NewGame(
        uint256 indexed gameId,
        bool playerX,
        address playerAddress,
        uint256 initialStake
    );
    event Move(
        uint256 indexed gameId,
        bool playerO, 
        uint8 position
    );
    event Staked(
        uint256 indexed gameId, 
        bool playerX, 
        address playerAddress, 
        uint256 amount
    );
    event Won(
        uint256 indexed gameId,
        address playerAddress, 
        uint256 amount
    );

    struct Game {
        address playerX;
        address playerO;
        bytes1[9] boardInBytes;
        uint stake;
        address winner;
        bool turnO;
    }

    bytes1 internal constant xMark = 0x01;
    bytes1 internal constant oMark = 0x02;
    // bytes internal boardInBytes = new bytes(9);

    mapping(uint256 => Game) public games;
    mapping(uint256 => uint256) public gameIdByTokenId;

    uint256 internal nextGameID;

    IToken public immutable token;
    INFT public immutable nft;

    // bool internal turnO;

    // uint public stake;
    uint public collectedFees;
    // address public winner;

    address public owner;
    // address public playerX;
    // address public playerO;

    receive() external payable {}

    constructor(address _token, address _nft) {
        owner = msg.sender;
        token = IToken(_token);
        nft = INFT(_nft);
    }

    modifier minimumStake() {
        require(msg.value >= 1e6 gwei, "Must stake at least 1e6 gwei");
        require(msg.value <= 1 ether, "Must stake no more than 1 ether");
        _;
    }

    modifier gamesAvailable() {
        require(nextGameID < type(uint256).max, "No more games available!");
        _;
    }

    function _collectStake(Game storage game) internal returns(uint) {
        uint newFee = msg.value >> 3;
        uint newStake = msg.value - newFee;
        collectedFees += newFee;
        game.stake += newStake;

        return newStake;
    }

    function _rightStake(Game storage game) internal view {
        require(game.stake > 0, "Game is not initialized");
        require(msg.value - (msg.value >> 3) >= game.stake,
            "Must stake at least the same as the previous player!");
    } 

    function _stake(Game storage game, bool isPlayerX) internal returns (uint256) {
        if (isPlayerX) {
            game.playerX = msg.sender;
        } else {
            game.playerO = msg.sender;
        }

        uint newStake = _collectStake(game);

        payable(address(this)).transfer(msg.value);
        return newStake;
    }

    function newGameAsX() external payable minimumStake() gamesAvailable() 
        returns (uint256) {
        return _newGame(true);
    }

    function newGameAsO() external payable minimumStake() gamesAvailable() 
        returns (uint256) {
        return _newGame(false);
    }

    function _newGame(bool isX) internal returns (uint256) {
        uint gameID = nextGameID;
        nextGameID++;
        Game storage game = _game(gameID);
        uint256 newStake = _stake(game, isX);
        emit NewGame(gameID, isX, msg.sender, newStake);
        return gameID;
    }

    function stakeAndJoin(uint256 gameId) public payable minimumStake() {
        Game storage game = _game(gameId);
        _rightStake(game);
        bool stakesAsX = game.playerX == address(0);
        uint256 newStake = _stake(game, stakesAsX);
        emit Staked(gameId, stakesAsX, msg.sender, newStake);
        assert(game.playerX != address(0));
        assert(game.playerO != address(0));
        mintGameToken(game.playerX, game.playerO);
    }

    function _game(uint256 gameId) internal view returns (Game storage) {
        return games[gameId];
    }

    function board(uint256 gameId) external view returns(string[9] memory) {
        Game memory game = _game(gameId);
        string[9] memory stringBoard;

        bytes1 cell;
        bool isX;
        bool isO;
        for (uint256 i = 0; i < 9;) {
            cell = game.boardInBytes[i];
            isX = (cell & xMark) == xMark;
            isO = (cell & oMark) == oMark;
            assert(!(isX && isO));
            stringBoard[i] = isX ? "X" : (isO ? "O" : "_");
            unchecked {
                ++i;
            }
        }
        return stringBoard;
    }

    function mintGameToken(address _playerX, address _playerO) internal {
        uint256 playerOToken = 2 * nextGameID;
        uint256 playerXToken = playerOToken - 1;
        gameIdByTokenId[playerOToken] = gameIdByTokenId[
            playerXToken
        ] = nextGameID;
        nft.mint(_playerO, playerOToken);
        nft.mint(_playerX, playerXToken);
    }

    function gameStake(uint gameId) external view returns(uint) {
        return _game(gameId).stake;
    }

    function isTurnX(uint256 gameId) public view returns(bool) {
        Game storage game = _game(gameId);
        return !game.turnO;
    }

    function isTurnO(uint256 gameId) public view returns(bool) {
        Game storage game = _game(gameId);
        return game.turnO;
    }

    function winner(uint gameId) public view returns(address) {
        return _game(gameId).winner;
    }

    function move(uint256 gameId, uint8 cellIndex) public payable {

        Game storage game = _game(gameId);
        require(game.playerX != address(0), "Waiting for player X");
        require(game.playerO != address(0), "Waiting for player O");
        require(game.winner == address(0), "This game already has a winner");
        require((game.turnO && msg.sender == game.playerO) || 
                (!game.turnO && msg.sender == game.playerX),
            "Only preset players can move");
        require(game.boardInBytes[cellIndex] == 0x00, "Cell is not empty");

        bytes1 mark = game.turnO ? oMark : xMark;
        game.boardInBytes[cellIndex] = mark;
        emit Move(gameId, game.turnO, cellIndex);

        if (checkLastMarkWon(game.boardInBytes, cellIndex, mark)) {
            game.winner = msg.sender;
            emit Won(gameId, msg.sender, game.stake);
        }
        game.turnO = !game.turnO;
    }

    function checkLastMarkWon(bytes1[9] memory boardInBytes, uint8 lastCell, bytes1 lastMark) 
        internal pure returns (bool) {
        uint8 colOffset = lastCell % 3; 
        uint8 rowStart = lastCell - colOffset;
        // check horizontal line
        if (boardInBytes[rowStart + ((lastCell + 1) % 3)] == lastMark &&
            boardInBytes[rowStart + ((lastCell + 2) % 3)] == lastMark) {
            return true;
        }
    
        // check vertical line
        uint8 rowOffset = (rowStart / 3);
        if (boardInBytes[((rowOffset + 1) % 3) * 3 + colOffset] == lastMark &&
            boardInBytes[((rowOffset + 2) % 3) * 3 + colOffset] == lastMark) {
            return true;
        }

        if (boardInBytes[4] == lastMark) {
            if (boardInBytes[0] == lastMark && boardInBytes[8] == lastMark) {
                return true;
            }
            if (boardInBytes[2] == lastMark && boardInBytes[6] == lastMark) {
                return true;
            }
        }

        return false;
    }

    function claimStake(uint256 gameId) public payable {
        require(gameId <= nextGameID, "Game does not exist");
        Game storage game = _game(gameId);
        require(msg.sender == game.winner, "Only winner can claim stake");
        require(game.stake > 0, "Stake already claimed");

        uint stakeToTransfer = game.stake;
        assert(game.stake > 1e6 gwei);

        assert(address(this).balance >= stakeToTransfer);
        payable(msg.sender).transfer(stakeToTransfer);
        // which is the preferred method to transfer ether,
        // beyond the pattern of withdrawal?
        // (bool sent, ) = payable(msg.sender).call{value: stakeToTransfer}("");
        // require(sent, "Failed to send Ether");
    }

    function recoverFees() public payable {
        require(msg.sender == owner, "Only owner can collect fees");

        require(address(this).balance >= collectedFees, "Not enough balance");
        require(collectedFees > 0, "No fees to transfer");
        payable(msg.sender).transfer(collectedFees);
    }
}
