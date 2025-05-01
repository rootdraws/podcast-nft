// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Open edition NFT sale with a 24-hour time window
contract PodcastNFT is ERC721URIStorage, Ownable {
    // Price per NFT ~$5 USD 
    uint256 public constant PRICE = 0.003 ether;
    // Tracks how many NFTs have been minted so far
    uint256 public currentSupply = 0;
    // Address that receives mint payments (burn address)
    address payable public artistAddress = payable(0xA3e51498579Db0f7bb1ec9E3093B2F44158E25a5); // SGT_SLAUGHTERMELON

    
    // Time Variables
    uint256 public saleStart;
    uint256 public saleEnd; 

    // --- Events ---
    event SaleStarted(uint256 saleStart, uint256 saleEnd);
    event Minted(address indexed minter, uint256 indexed tokenId, string tokenURI);

    // Constructor sets NFT name/symbol
    constructor()
        ERC721("PodcastNFT", "PNFT")
        Ownable(msg.sender)
    {}

    // Start the sale: can only be called by the owner
    function start() external onlyOwner {
        require(saleStart == 0, "Sale already started");
        saleStart = block.timestamp;
        saleEnd = saleStart + 24 hours;
        emit SaleStarted(saleStart, saleEnd);
    }

    // Mint a new NFT with a given metadata URI, only during the sale window
    function mint(string memory tokenURI) public payable {
        require(saleStart != 0, "Sale not started");
        require(block.timestamp >= saleStart, "Sale not started yet");
        require(block.timestamp <= saleEnd, "Sale has ended");
        require(msg.value == PRICE, "Incorrect ETH amount sent");

        uint256 tokenId = currentSupply + 1;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);

        currentSupply++;

        emit Minted(msg.sender, tokenId, tokenURI);

        // Send payment directly to artist
        (bool sent, ) = artistAddress.call{value: msg.value}("");
        require(sent, "Failed to send Ether to artist");
    }
}
