// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DynamicNFT is ERC721 {
    struct NFTMetadata {
        string name;
        string description;
        string imageCID;
    }

    mapping(uint256 => NFTMetadata) public nftMetadata;

    constructor() ERC721("DynamicNFT", "DNFT") {}

    function mint(
        uint256 tokenId,
        string memory name,
        string memory description,
        string memory imageCID
    ) public {
        require(!_exists(tokenId), "Token already exists");
        string memory ipfsBaseUrl = "https://ipfs.io/ipfs/";
        nftMetadata[tokenId] = NFTMetadata(
            name,
            description,
            string(abi.encodePacked(ipfsBaseUrl, imageCID))
        );
        _mint(msg.sender, tokenId);
    }

    function getMetadata(
        uint256 tokenId
    ) public view returns (NFTMetadata memory) {
        require(_exists(tokenId), "Token does not exist");

        return nftMetadata[tokenId];
    }
}