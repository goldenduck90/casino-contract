export interface Config {
    token: string,
    nft_booster: { contract: string, baseUri: string },
    nft_character: { contract: string, baseUri: string },
    coinflip: {
        address: string,
        fee: number
    },
    dice: {
        address: string,
        fee: number
    },
    staking: {
        address: string,
        baseRate: number
    }
}