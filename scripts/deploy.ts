import { ethers } from "hardhat";

async function main() {
  // Deploy the PodcastNFT contract
  const PodcastNFT = await ethers.getContractFactory("PodcastNFT");
  const podcastNFT = await PodcastNFT.deploy();

  await podcastNFT.waitForDeployment();

  console.log("PodcastNFT deployed to:", podcastNFT.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
