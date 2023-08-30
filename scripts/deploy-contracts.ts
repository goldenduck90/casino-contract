import { ethers } from "hardhat";
import { base_mainnet, goerli } from './config.json';

const deployCoinFlip = async (token: string, fee: number) => {
    const CoinFlip = await ethers.getContractFactory("CoinFlip");
    const flip = await CoinFlip.deploy(token, fee);
    await flip.deployed();
    console.log("CoinFlip address:", flip.address); // eslint-disable-line no-console
}

const deployDice = async (token: string, fee: number) => {
    const Dice = await ethers.getContractFactory("Dice");
    const dice = await Dice.deploy(token, fee);
    await dice.deployed();
    console.log("Dice address:", dice.address); // eslint-disable-line no-console
}

const deployStakingContract = async (nft_booster: string, nft_character: string, token: string, baseRate: number) => {
    const StakingContract = await ethers.getContractFactory("StakingContract");
    const staking = await StakingContract.deploy(nft_booster, nft_character, token, baseRate);
    await staking.deployed();
    console.log("StakingContract address:", staking.address); // eslint-disable-line no-console
}

const main = async () => {
    const { nft_booster: nftBooster, nft_character: nftCharacter, token, coinflip: { fee: coinFlipFee }, dice: { fee: diceFee }, staking: { baseRate: stakingBaseRate } } = goerli;
    await deployStakingContract(nftBooster, nftCharacter, token, stakingBaseRate);
    // await deployCoinFlip(token, coinFlipFee);
    // await deployDice(token, diceFee);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error); // eslint-disable-line no-console
        process.exit(1);
    });
