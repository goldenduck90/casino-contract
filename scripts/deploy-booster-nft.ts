import { ethers } from "hardhat";
import { base_mainnet } from './config.json';

const deployToken = async () => {
  const wolfiesBoosterNFT = await ethers.getContractFactory(
    "WolfiesBoosterNFT"
  );
  const boosterNft = await wolfiesBoosterNFT.deploy();
  await boosterNft.deployed();
  console.log("WolfiesBoosterNFT address:", boosterNft.address); // eslint-disable-line no-console
  const { nft_booster: { baseUri } } = base_mainnet;

  await boosterNft.functions.setBaseURI(baseUri)
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
