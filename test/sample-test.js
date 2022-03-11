const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NftMarketPlace", function () {
  it("Should create execute salse", async function () {
    const Market = await ethers.getContractFactory("NftMarketPlace");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;
    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();
    const auctionPrice = ethers.utils.parseUnits("1","ether");
    
  });
});
