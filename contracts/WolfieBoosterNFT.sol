// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";

contract WolfieBoosterNFT is ERC721A, ERC721AQueryable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    /// @notice Event emitted when user minted tokens.
    event Minted(address user, uint256 quantity, uint256 totalSupply);

    uint256 public immutable maxSupply;

    string private _baseTokenURI;

    mapping(address => uint256) public whitelist;

    constructor(string memory name, string memory symbol, uint256 _maxSupply) ERC721A(name, symbol) {
        maxSupply = _maxSupply;
    }

    modifier callerIsUser() {
        require(tx.origin == _msgSenderERC721A(), "The caller is another contract");
        _;
    }

    function mint(uint256 _quantity) external callerIsUser nonReentrant {
        require(_quantity <= whitelist[_msgSenderERC721A()], "Exceeded max available to purchase");
        require(totalSupply() + _quantity <= maxSupply, "Purchase would exceed max supply");

        whitelist[_msgSenderERC721A()] -= _quantity;

        _safeMint(_msgSenderERC721A(), _quantity);

        emit Minted(_msgSenderERC721A(), _quantity, totalSupply());
    }

    // metadata URI

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        require(_exists(tokenId), "Token does not exist");

        return string(abi.encodePacked(_baseTokenURI, tokenId.toString()));
    }

    /**
     * @notice Add to whitelist
     */
    function addToWhitelist(address[] calldata _toAddAddresses, uint256[] calldata _amounts) external onlyOwner {
        for (uint256 i = 0; i < _toAddAddresses.length; i++) {
            whitelist[_toAddAddresses[i]] = _amounts[i];
        }
    }

    /**
     * @notice Remove from whitelist
     */
    function removeFromWhitelist(address[] calldata toRemoveAddresses) external onlyOwner {
        for (uint i = 0; i < toRemoveAddresses.length; i++) {
            delete whitelist[toRemoveAddresses[i]];
        }
    }
}
