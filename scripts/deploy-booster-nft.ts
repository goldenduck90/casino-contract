import { ethers } from "hardhat";

const deployToken = async () => {
  const wolfieBoosterNFT = await ethers.getContractFactory("WolfieBoosterNFT");
  const boosterNft = await wolfieBoosterNFT.deploy();
  await boosterNft.deployed();
  console.log("WolfieBoosterNFT address:", boosterNft.address); // eslint-disable-line no-console
}

const main = async () => {
  await deployToken();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error); // eslint-disable-line no-console
    process.exit(1);
  });
