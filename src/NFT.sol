// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/ITicTacToken.sol";
import "../lib/Base64.sol";

contract NFT is ERC721, Ownable {
    using Strings for uint256;

    ITicTacToken public ttt;
    bytes1 internal constant xMark = 0x01;
    bytes1 internal constant oMark = 0x02;

    event SetTTT(ITicTacToken oldTTT, ITicTacToken newTTT);

    constructor() ERC721("Tic Tac Token NFT (Genesis Block)", "TTT.0 NFT") {}

    function mint(address to, uint256 tokenId) external onlyOwner {
        _safeMint(to, tokenId);
    }

    function setTTT(ITicTacToken _ttt) external onlyOwner {
        emit SetTTT(ttt, _ttt);
        ttt = _ttt;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return metadataURI(ttt.gameIdByTokenId(tokenId));
    }

    function metadataJSON(uint256 gameId, string[9] memory board)
        public
        view
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "{\"name\":\"Game #",
                    gameId.toString(),
                    "\",\"description\":\"",
                    name(),
                    "\",\"image\":\"",
                    imageURI(board),
                    "\"}"
                )
            );
    }

    function metadataURI(uint256 gameId) public view returns (string memory) {
        return
            _encodeDataURI(
                "application/json",
                metadataJSON(gameId, ttt.board(gameId))
            );
    }

    function imageURI(string[9] memory board)
        public
        pure
        returns (string memory)
    {
        return _encodeDataURI("image/svg+xml", boardSVG(board));
    }

    function _encodeDataURI(string memory mimeType, string memory data)
        internal
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "data:",
                    mimeType,
                    ";base64,",
                    Base64.encode(bytes(data))
                )
            );
    }

    function formatRow(
        string memory first,
        string memory second,
        string memory third,
        string memory yOffset
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<text x=\"50%\" y=\"",
                    yOffset,
                    "%\" class=\"e\" dominant-baseline=\"middle\" text-anchor=\"middle\">",
                    first,
                    second,
                    third,
                    "</text>"
                )
            );
    }

    function boardSVG(string[9] memory board)
        public
        pure
        returns (string memory)
    {
        string memory firstRow = formatRow(board[0], board[1], board[2], "25");
        string memory secondRow = formatRow(board[3], board[4], board[5], "50");
        string memory thirdRow = formatRow(board[6], board[7], board[8], "75");

        return
            string(
                abi.encodePacked(
                    "<svg xmlns=\"http://www.w3.org/2000/svg\" \
preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 350 350\">\
<style>.e{font-family:monospace;font-size:48pt;letter-spacing:.25em;fill:white}</style>\
<rect width=\"100%\" height=\"100%\" fill=\"#303841\"/>",
                    firstRow,
                    secondRow,
                    thirdRow,
                    "</svg>"
                )
            );
    }
}
