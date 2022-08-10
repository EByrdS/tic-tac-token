// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./utils/NFTTest.sol";

contract TestNFT is NFTTest {
    function testHasName() public {
        assertEq(nft.name(), "Tic Tac Token NFT (Genesis Block)");
    }

    function testHasSymbol() public {
        assertEq(nft.symbol(), "TTT.0 NFT");
    }

    function testFormatsRow() public {
        assertEq(
            nft.formatRow(X, O, O, "25"),
            "<text x=\"50%\" y=\"25%\" class=\"e\" dominant-baseline=\"middle\" text-anchor=\"middle\">XOO</text>"
        );
        assertEq(
            nft.formatRow(O, X, O, "50"),
            "<text x=\"50%\" y=\"50%\" class=\"e\" dominant-baseline=\"middle\" text-anchor=\"middle\">OXO</text>"
        );
        assertEq(
            nft.formatRow(O, EMPTY, EMPTY, "75"),
            "<text x=\"50%\" y=\"75%\" class=\"e\" dominant-baseline=\"middle\" text-anchor=\"middle\">O__</text>"
        );
    }

    function testFormatsBoard() public {
        string[9] memory board = [X, O, O, O, X, O, O, EMPTY, EMPTY];
        assertEq(
            nft.boardSVG(board),
            "<svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"\
xMinYMin meet\" viewBox=\"0 0 350 350\"><style>.e{font-family:monospace;\
font-size:48pt;letter-spacing:.25em;fill:white}</style><rect width=\"100%\" \
height=\"100%\" fill=\"#303841\"/><text x=\"50%\" y=\"25%\" class=\"e\" \
dominant-baseline=\"middle\" text-anchor=\"middle\">XOO</text><text x=\"50%\" \
y=\"50%\" class=\"e\" dominant-baseline=\"middle\" text-anchor=\"middle\">OXO\
</text><text x=\"50%\" y=\"75%\" class=\"e\" dominant-baseline=\"middle\" \
text-anchor=\"middle\">O__</text></svg>"
        );
    }

    function testImageURI() public {
        string[9] memory board = [X, O, O, O, X, O, O, EMPTY, EMPTY];
        assertEq(
            nft.imageURI(board),
            "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcv\
MjAwMC9zdmciIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMC\
AzNTAgMzUwIj48c3R5bGU+LmV7Zm9udC1mYW1pbHk6bW9ub3NwYWNlO2ZvbnQtc2l6ZTo0OHB0O2x\
ldHRlci1zcGFjaW5nOi4yNWVtO2ZpbGw6d2hpdGV9PC9zdHlsZT48cmVjdCB3aWR0aD0iMTAwJSI\
gaGVpZ2h0PSIxMDAlIiBmaWxsPSIjMzAzODQxIi8+PHRleHQgeD0iNTAlIiB5PSIyNSUiIGNsYXNz\
PSJlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5YT088\
L3RleHQ+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGNsYXNzPSJlIiBkb21pbmFudC1iYXNlbGluZT0i\
bWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5PWE88L3RleHQ+PHRleHQgeD0iNTAlIiB5PSI3\
NSUiIGNsYXNzPSJlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlk\
ZGxlIj5PX188L3RleHQ+PC9zdmc+"
        );
    }

    function testMetadataJSON() public {
        string[9] memory board = [X, O, O, O, X, O, O, EMPTY, EMPTY];
        assertEq(
            nft.metadataJSON(1, board),
            "{\"name\":\"Game #1\",\"description\":\"Tic Tac Token NFT \
(Genesis Block)\",\"image\":\"data:image/svg+xml;base64,PHN2Zy\
B4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHByZXNlcnZlQXNwZ\
WN0UmF0aW89InhNaW5ZTWluIG1lZXQiIHZpZXdCb3g9IjAgMCAzNTAgMzUwIj48c\
3R5bGU+LmV7Zm9udC1mYW1pbHk6bW9ub3NwYWNlO2ZvbnQtc2l6ZTo0OHB0O2xld\
HRlci1zcGFjaW5nOi4yNWVtO2ZpbGw6d2hpdGV9PC9zdHlsZT48cmVjdCB3aWR0a\
D0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjMzAzODQxIi8+PHRleHQgeD0iN\
TAlIiB5PSIyNSUiIGNsYXNzPSJlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlI\
iB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5YT088L3RleHQ+PHRleHQgeD0iNTAlIiB5P\
SI1MCUiIGNsYXNzPSJlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LW\
FuY2hvcj0ibWlkZGxlIj5PWE88L3RleHQ+PHRleHQgeD0iNTAlIiB5PSI3NSUiIGN\
sYXNzPSJlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0\
ibWlkZGxlIj5PX188L3RleHQ+PC9zdmc+\"}"
        );
    }

    function testEncodedMetadata() public {
        assertEq(
            nft.metadataURI(1),
            "data:application/json;base64,eyJuYW1lIjoiR2FtZSAjMSIsImRlc2NyaX\
B0aW9uIjoiVGljIFRhYyBUb2tlbiBORlQgKEdlbmVzaXMgQmxvY2spIiwiaW1hZ2U\
iOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIw\
Y0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53W\
ldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTU\
NBek5UQWdNelV3SWo0OGMzUjViR1UrTG1WN1ptOXVkQzFtWVcxcGJIazZiVzl1YjN\
Od1lXTmxPMlp2Ym5RdGMybDZaVG8wT0hCME8yeGxkSFJsY2kxemNHRmphVzVuT2k0\
eU5XVnRPMlpwYkd3NmQyaHBkR1Y5UEM5emRIbHNaVDQ4Y21WamRDQjNhV1IwYUQwa\
U1UQXdKU0lnYUdWcFoyaDBQU0l4TURBbElpQm1hV3hzUFNJak16QXpPRFF4SWk4K1\
BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJeU5TVWlJR05zWVhOelBTSmxJaUJrYjIxcGJ\
tRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoMExXRnVZMmh2Y2owaWJX\
bGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJMU1DV\
WlJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeG\
xJaUIwWlhoMExXRnVZMmh2Y2owaWJXbGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BIUmx\
lSFFnZUQwaU5UQWxJaUI1UFNJM05TVWlJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVk\
QzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoMExXRnVZMmh2Y2owaWJXbGtaR\
3hsSWo1ZlgxODhMM1JsZUhRK1BDOXpkbWMrIn0="
        );
    }

    function testHasTicTacTokenContractAddress() public {
        assertEq(address(nft.ttt()), address(ttt));
    }

    // cannot call .mint as the owner is now ttt
    // function testMintsTokenToAddress() public {
    //     nft.mint(address(playerX), 1);
    //     assertEq(nft.ownerOf(1), address(playerX));
    // }

    function testFailOnlyOwnerCanMint() public {
        playerX.mint(address(playerX), 1);
    }

    function testFailOnlyOwnerCanSetTTT() public {
        playerX.setTTT(ITicTacToken(address(ttt)));
    }

    function testTokenRendersEmptyBoardForNewGame() public {
        uint256 gameId = tttPlayerX.newGameAsX(1 ether);
        tttPlayerO.stakeAndJoin(gameId, 1 ether);

        assertEq(
            nft.tokenURI(1),
            "data:application/json;base64,eyJuYW1lIjoiR2FtZSAjMSIsImRlc2NyaXB0a\
W9uIjoiVGljIFRhYyBUb2tlbiBORlQgKEdlbmVzaXMgQmxvY2spIiwiaW1hZ2UiOiJkYXRhOmltYWdl\
L3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF\
3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSF\
pwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1WN1ptOXVkQzFtWVcxcGJIazZiV\
zl1YjNOd1lXTmxPMlp2Ym5RdGMybDZaVG8wT0hCME8yeGxkSFJsY2kxemNHRmphVzVuT2k0eU5XVnRP\
MlpwYkd3NmQyaHBkR1Y5UEM5emRIbHNaVDQ4Y21WamRDQjNhV1IwYUQwaU1UQXdKU0lnYUdWcFoyaDB\
QU0l4TURBbElpQm1hV3hzUFNJak16QXpPRFF4SWk4K1BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJeU5TVW\
lJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoMExXR\
nVZMmh2Y2owaWJXbGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJMU1D\
VWlJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoMEx\
XRnVZMmh2Y2owaWJXbGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJM0\
5TVWlJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoM\
ExXRnVZMmh2Y2owaWJXbGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BDOXpkbWMrIn0="
        );
        assertEq(
            nft.tokenURI(2),
            "data:application/json;base64,eyJuYW1lIjoiR2FtZSAjMSIsImRlc2NyaXB0a\
W9uIjoiVGljIFRhYyBUb2tlbiBORlQgKEdlbmVzaXMgQmxvY2spIiwiaW1hZ2UiOiJkYXRhOmltYWdl\
L3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF\
3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSF\
pwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1WN1ptOXVkQzFtWVcxcGJIazZiV\
zl1YjNOd1lXTmxPMlp2Ym5RdGMybDZaVG8wT0hCME8yeGxkSFJsY2kxemNHRmphVzVuT2k0eU5XVnRP\
MlpwYkd3NmQyaHBkR1Y5UEM5emRIbHNaVDQ4Y21WamRDQjNhV1IwYUQwaU1UQXdKU0lnYUdWcFoyaDB\
QU0l4TURBbElpQm1hV3hzUFNJak16QXpPRFF4SWk4K1BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJeU5TVW\
lJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoMExXR\
nVZMmh2Y2owaWJXbGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJMU1D\
VWlJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoMEx\
XRnVZMmh2Y2owaWJXbGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BIUmxlSFFnZUQwaU5UQWxJaUI1UFNJM0\
5TVWlJR05zWVhOelBTSmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoM\
ExXRnVZMmh2Y2owaWJXbGtaR3hsSWo1ZlgxODhMM1JsZUhRK1BDOXpkbWMrIn0="
        );
    }
}
