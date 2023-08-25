import { ethers } from "hardhat";

const deployToken = async () => {
  const WOLFLABToken = await ethers.getContractFactory("WOLFLABToken");
  const token = await WOLFLABToken.deploy("0x73eA65d9551b91cb30F2ee617717dB8dB74F538f");
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
