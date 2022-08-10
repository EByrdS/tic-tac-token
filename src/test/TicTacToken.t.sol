// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./utils/TicTacTokenTest.sol";

contract TestTTT is TicTacTokenTest {
    function setUp() public override {
        super.setUp();
    }

    function testPlayersStartWithBalances() public {
        assertGe(address(playerX).balance, 1 ether);
        assertGe(address(playerO).balance, 1 ether);
        assertGe(address(nonplayer).balance, 1 ether);
        assertGt(address(this).balance, 500 ether);
    }

    function testTurnX() public {
        assertTrue(tttoken.isTurnX(0));
    }

    function testTurnO() public {
        assertTrue(!tttoken.isTurnO(0));
    }

    function testStakeIsRecorded() public {
        uint sentStake = 1 ether;
        playerX.newGameAsX(sentStake);

        assertEq(tttoken.gameStake(0), sentStake - (sentStake >> 3));
    }

    function testStakingUpdatesBalances() public {
        assertEq(address(tttoken).balance, 0);
        assertEq(address(playerX).balance, 1 ether);

        uint gameId = playerX.newGameAsX(1 ether);

        assertEq(address(tttoken).balance, 1 ether);
        assertEq(address(playerX).balance, 0);

        assertEq(address(playerO).balance, 1 ether);

        playerO.stakeAndJoin(gameId, 1 ether);

        assertEq(address(playerO).balance, 0);
        assertEq(address(tttoken).balance, 2 ether);

    }

    function testBoardGeneration() public {
        uint gameId = playerX.newGameAsX(1 ether);
        playerO.stakeAndJoin(gameId, 1 ether);
        playerX.move(gameId, 0);
        string[9] memory board = tttoken.board(gameId);
        assertEq(board[0], "X");
    }

    function testCanMoveAfterBothStaking() public {
        uint gameId = playerX.newGameAsX(1 ether);
        playerO.stakeAndJoin(gameId, 1 ether);
        playerX.move(gameId, 1);
    }

    function testFailCannotStartPlayerO() public {
        uint gameId = playerX.newGameAsX(1 ether);
        playerO.stakeAndJoin(gameId, 1 ether);
        playerO.move(gameId, 4);
    }

    function testFailCannotStakeLessThanPreviousPlayer() public {
        uint gameId = playerX.newGameAsX(1 ether);
        playerO.stakeAndJoin(gameId, (1 ether) - 2);
    }

    function testTurnToggling() public {
        uint gameId = playerX.newGameAsX(1 ether);
        playerO.stakeAndJoin(gameId, 1 ether);
        playerX.move(gameId, 0);
        playerO.move(gameId, 1);
        string[9] memory board = tttoken.board(gameId);
        assertEq(board[0], "X");
        assertEq(board[1], "O");
    }

    function testOwnerIsDeployer() public {
        // This class TestTTT is the deployer
        assertEq(tttoken.owner(), address(this));
        assertTrue(!(tttoken.owner() == address(tttoken)));
    }

    function testFailCannotStartWithouPlayerX() public {
        playerO.stakeAndJoin(0, 1 ether);
    }

    function testFailCannotStartWithoutPlayerO() public {
        uint gameId = playerX.newGameAsX(1 ether);
        playerX.move(gameId, 0);
    }

    function testPlayerCanCreateANewGame() public {
        playerX.newGameAsX(1 ether);
    }

    function testGameCreationHasDifferentIndex() public {
        uint gameId1 = playerX.newGameAsX(1e6 gwei);
        uint gameId2 = playerX.newGameAsX(1e6 gwei);
        assertTrue(gameId1 == 0, "First game id is not 0");
        assertTrue(gameId2 == 1, "Second game is is not 1");
    }

    function testFailCannotStakeLessThanMinimum() public {
        playerX.newGameAsX(0.9e6 gwei); // 0.0009 ether
    }

    function testFailCannotMoveTwiceInARow() public {
        uint gameId = playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(gameId, 1e6 gwei);
        playerX.move(gameId, 0);
        playerX.move(gameId, 1);
    }

    function testCanCreateNewGame() public {
        playerX.newGameAsX(1e6 gwei);

        uint gameId2 = playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(gameId2, 1e6 gwei);
        playerX.move(gameId2, 0);
        playerO.move(gameId2, 1);
    }

    function testWinHorizontalFirst() public {
        uint gameId = playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(gameId, 1e6 gwei);

        playerX.move(gameId, 0); playerO.move(gameId, 3);
        playerX.move(gameId, 1); playerO.move(gameId, 4);

        assertEq(tttoken.winner(gameId), address(0));
        playerX.move(gameId, 2);
        assertEq(tttoken.winner(gameId), address(playerX));
    }

    function testWinHorizonatlSecond() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 3); playerO.move(0, 0);
        playerX.move(0, 4); playerO.move(0, 1);

        assertEq(tttoken.winner(0), address(0));
        playerX.move(0, 5);
        assertEq(tttoken.winner(0), address(playerX));
    }

    function testWinHorizonalThird() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 6); playerO.move(0, 0);
        playerX.move(0, 7); playerO.move(0, 1);

        assertEq(tttoken.winner(0), address(0));
        playerX.move(0, 8);
        assertEq(tttoken.winner(0), address(playerX));
    }

    function testWinVerticalFirst() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 0); playerO.move(0, 1);
        playerX.move(0, 3); playerO.move(0, 4);

        assertEq(tttoken.winner(0), address(0));
        playerX.move(0, 6);
        assertEq(tttoken.winner(0), address(playerX));
    }

    function testWinVerticalSecond() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 1); playerO.move(0, 0);
        playerX.move(0, 4); playerO.move(0, 3);

        assertEq(tttoken.winner(0), address(0));
        playerX.move(0, 7);
        assertEq(tttoken.winner(0), address(playerX));
    }

    function testWinVerticalThird() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 2); playerO.move(0, 0);
        playerX.move(0, 5); playerO.move(0, 3);

        assertEq(tttoken.winner(0), address(0));
        playerX.move(0, 8);
        assertEq(tttoken.winner(0), address(playerX));
    }

    function testWinDiagonalFirst() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 0); playerO.move(0, 1);
        playerX.move(0, 4); playerO.move(0, 2);

        assertEq(tttoken.winner(0), address(0));
        playerX.move(0, 8);
        assertEq(tttoken.winner(0), address(playerX));
    }

    function testWinDiagonalSecond() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 2); playerO.move(0, 0);
        playerX.move(0, 4); playerO.move(0, 1);

        assertEq(tttoken.winner(0), address(0));
        playerX.move(0, 6);
        assertEq(tttoken.winner(0), address(playerX));
    }

    function testPlayerOCanWin() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 0); playerO.move(0, 3);
        playerX.move(0, 1); playerO.move(0, 4);
        playerX.move(0, 6);

        assertEq(tttoken.winner(0), address(0));
        playerO.move(0, 5);
        assertEq(tttoken.winner(0), address(playerO));
    }

    function testWinnerCanWithdraw() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);
        playerX.move(0, 0); playerO.move(0, 3);
        playerX.move(0, 1); playerO.move(0, 4);
        playerX.move(0, 2);

        playerX.claimStake(0);

        assertGt(address(playerX).balance, 1 ether, 
            "Player X doesn't have more than 1 ether");
        assertEq(address(playerO).balance, 1 ether - 1e6 gwei,
            "Player O doesn't have 1-1e6gwei ether");
        assertEq(address(tttoken).balance,
            2 ether - address(playerX).balance - address(playerO).balance,
            "TTToken balance doesn't hold fee");
    }

    function testOwnerCanClaimFees() public {
        playerX.newGameAsX(1e6 gwei);
        tttoken.recoverFees();
    }

    function testFailNonOwnerCannotClaimFees() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.recoverFees();
    }

    function testFailCannotOverwriteMarkedSpace() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);

        playerX.move(0, 0); playerO.move(0, 0);
    }

    function testFailNoMovesAfterGameOver() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);
        playerX.move(0, 0); playerO.move(0, 3);
        playerX.move(0, 1); playerO.move(0, 4);
        playerX.move(0, 2);

        playerO.move(0, 5);
    }

    function testFailNonPlayerCannotMarkBoard() public {
        playerX.newGameAsX(1e6 gwei);
        playerO.stakeAndJoin(0, 1e6 gwei);
        playerX.move(0, 0); playerO.move(0, 3);

        nonplayer.move(0, 3);
    }

    function testHasTokenAddress() public {
        assertEq(address(tttoken.token()), address(token));
    }
}
