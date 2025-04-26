// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Limited Edition NFT which mints, and pays out to the artist.

// Main NFT contract
contract PodcastNFT is ERC721URIStorage, Ownable {
    // 1. Set Limited Edition Number
    uint256 public constant MAX_SUPPLY = 20;
    // 2. Set Price per NFT
    uint256 public constant PRICE = 0.1 ether;
    // 3. Tracks how many NFTs have been minted so far
    uint256 public currentSupply = 0;
    // 4. Set Address that receives mint payments
    address payable public artistAddress = payable(0x000000000000000000000000000000000000dEaD);

    // 5. Constructor sets NFT name/symbol
    constructor()
        ERC721("PodcastNFT", "PNFT")
        Ownable(msg.sender) // Sets deployer as owner
    {}

    / / Mint a new NFT with a given metadata URI
    function mint(string memory tokenURI) public payable {
        require(currentSupply < MAX_SUPPLY, "Max supply reached");
        require(msg.value == PRICE, "Incorrect ETH amount sent");

        uint256 tokenId = currentSupply + 1;
        _safeMint(msg.sender, tokenId);      // Mint NFT to sender
        _setTokenURI(tokenId, tokenURI);     // Set metadata URI

        currentSupply++;                     // Increment supply

        // Send payment directly to artist
        (bool sent, ) = artistAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether to artist");
    }
}
