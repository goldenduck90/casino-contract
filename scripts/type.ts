export interface Config {
    token: string,
    nft_booster: string,
    nft_character: string,
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