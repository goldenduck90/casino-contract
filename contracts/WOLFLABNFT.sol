// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CLIX is ERC721Enumerable, Ownable {
    using SafeMath for uint256;

    uint256 public constant MAX_MINT = 5555;

    string private _tokenURI = "";

    constructor() ERC721("WOLFLAB", "WOLFIES") {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _tokenURI;
    }

    function safeMint(uint numberOfTokens) public payable {
        for (uint i = 0; i < numberOfTokens; i++) {
            if (totalSupply() < MAX_MINT) {
                uint256 tokenId = totalSupply() + 1;
                _safeMint(msg.sender, tokenId);
            } else {
                break;
            }
        }
    }
}
