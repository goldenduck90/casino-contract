import { ethers } from "hardhat";

const deployToken = async () => {
  const wolfiesBoosterNFT = await ethers.getContractFactory(
    "WolfiesBoosterNFT"
  );
  const boosterNft = await wolfiesBoosterNFT.deploy();
  await boosterNft.deployed();
  console.log("WolfiesBoosterNFT address:", boosterNft.address); // eslint-disable-line no-console
};

const main = async () => {
  await deployToken();
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error); // eslint-disable-line no-console
    process.exit(1);
  });
