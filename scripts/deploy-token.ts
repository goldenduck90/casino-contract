import { ethers } from "hardhat";

const deployToken = async () => {
  const acounts = await ethers.getSigners()
  const WOLFLABToken = await ethers.getContractFactory("WOLFLABToken");
  const token = await WOLFLABToken.deploy(acounts[0].address);
  await token.deployed();
  console.log("WOLFLABToken address:", token.address); // eslint-disable-line no-console
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
