// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// contracts/security/ReentrancyGuard.sol

contract NftMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemSold;

    uint256 listingPrice = 0.020 ether;
    address payable owner;
    struct MarketProduct {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    // Mapping product through id or product
    mapping(uint256 => MarketProduct) public idToMarketProduct;

    // create event for market product creation.
    event MarketProductCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor() ERC721("My Token", "MYTOKENSYM") {
        owner = payable(msg.sender);
    }

    // Create Market product
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1 wei");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price."
        );

        // mapping tokenId for specific product.
        idToMarketProduct[tokenId] = MarketProduct(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        // TokenId token must be owned by from(msg.sender here)
        _transfer(msg.sender, address(this), tokenId);
 
        // Trigger event for CreateMarketItem
        emit MarketProductCreated(
            tokenId,
            msg.sender,
            address(this),
            price,
            false
        );
    }

    // Mints a token and lists it in marketplace
    function createToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    // Allow resellToken to others
    function resellToken(uint256 _tokenId, uint256 _price) public payable {
        require(
            idToMarketProduct[_tokenId].owner == msg.sender,
            "Only item owner can perform this operation"
        );
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );
        idToMarketProduct[_tokenId].sold = false;
        idToMarketProduct[_tokenId].price = _price;
        idToMarketProduct[_tokenId].seller = payable(msg.sender);
        idToMarketProduct[_tokenId].owner = payable(address(this));
        _itemSold.decrement();
        _transfer(msg.sender, address(this), _tokenId);
    }

    // Create sale for market place item
    // Transfer ownership of item as well as funds between parties
    function createMarketSale(uint256 _tokenId) public payable {
        uint256 price = idToMarketProduct[_tokenId].price;
        address seller = idToMarketProduct[_tokenId].seller;
        require(
            msg.value == price,
            "Fill the asking price in order to complete the purchase."
        );
        idToMarketProduct[_tokenId].owner = payable(msg.sender);
        idToMarketProduct[_tokenId].sold = true;
        idToMarketProduct[_tokenId].seller = payable(address(0));
        _itemSold.increment();
        _transfer(address(this), msg.sender, _tokenId);
        payable(owner).transfer(listingPrice);
        payable(seller).transfer(msg.value);
    }

    // Update listing price
    function updateListingPrice(uint256 _listingPrice) public payable {
        require(
            owner == msg.sender,
            "Only marketplace owner can modify listing price"
        );
        listingPrice = _listingPrice;
    }

    // Get listing Price
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // Return all unsold market Item
    function fetchMarketItems() public view returns (MarketProduct[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = _tokenIds.current() - _itemSold.current();
        uint256 currentIndex = 0;
        MarketProduct[] memory items = new MarketProduct[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketProduct[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketProduct storage currentItem = idToMarketProduct[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Returns only items that a user has purchased!
    function fetchMyNFTs() public view returns (MarketProduct[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        // Count how many items have user NFT
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketProduct[i].owner == msg.sender) {
                itemCount += 1;
            }
        }

        // Create new item list, how many nft a user have.
        MarketProduct[] memory items = new MarketProduct[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketProduct[i].owner == msg.sender) {
                uint256 currentId = i;
                MarketProduct storage currentItem = idToMarketProduct[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Returns only items a user has listed;
    function fetchItemsListed() public view returns (MarketProduct[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        // Count how many items have seller list.
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketProduct[i].seller == msg.sender) {
                itemCount += 1;
            }
        }
        // Create new item list, how many items have a seller.
        MarketProduct[] memory items = new MarketProduct[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idToMarketProduct[i].seller == msg.sender) {
                uint256 currentId = i;
                MarketProduct storage currentItem = idToMarketProduct[
                    currentId
                ];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
