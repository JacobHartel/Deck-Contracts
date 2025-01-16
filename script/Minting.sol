// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {ERC721} from "solady/tokens/ERC721.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {Base64} from "solady/utils/Base64.sol";
import {LibString} from "solady/utils/LibString.sol";

contract CustomNFT is ERC721, Ownable {
    using LibString for uint256;

    uint256 public totalSupply;

    struct Metadata {
        string name;
        string imageURI;
        uint256 rarity; // In percentage (5 for 5% etc)
    }

    mapping(uint256 => Metadata) public metadata;
    mapping(uint256 => uint256) public tokenToMetadata;

    constructor() {
        // Initialize metadata (example)
        metadata[1] = Metadata("NFT Name 1", "ipfs://placeholder.png", 5);
        metadata[2] = Metadata("NFT Name 2", "ipfs://placeholder2.png", 15);
        metadata[3] = Metadata("NFT Name 3", "ipfs://placeholder3.png", 50);
    }

    function name() public pure override returns (string memory) {
        return "Custom NFT Collection";
    }

    function symbol() public pure override returns (string memory) {
        return "CNFT";
    }

    function mint(address to, uint256 metadataId) external onlyOwner returns (uint256) {
        require(metadata[metadataId].rarity > 0, "Invalid metadata ID");

        uint256 tokenId = totalSupply++;
        _mint(to, tokenId);

        tokenToMetadata[tokenId] = metadataId;
        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");

        Metadata memory data = metadata[tokenToMetadata[tokenId]];

        string memory json = Base64.encode(
            abi.encodePacked(
                '{',
                '"name": "', data.name, '",',
                '"description": "Custom NFT with rarity and dynamic metadata",',
                '"attributes": [',
                '{"trait_type": "Rarity", "value": "', data.rarity.toString(), '"}',
                '],',
                '"image": "', data.imageURI, '"',
                '}'
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}

