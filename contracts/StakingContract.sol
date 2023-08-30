// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.5 <0.9.0;

import {Ownable} from "./openzepplin/Ownable.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IERC721} from "./interfaces/IERC721.sol";
import {SafeMath} from "./openzepplin/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakingContract is Ownable ReentrancyGuard {
    using SafeMath for uint256;

    address public BoosterNFTToken;
    address public CharacterNFTToken;
    address public Token;

    uint256 private baseRate;

    uint256 public tvl;
    uint256 public totalReward;
    uint256 public rewardTokenAmount;

    constructor(address _BoosterNFTToken, address _CharacterNFTToken, address _Token, uint256 _baseRate) {
        BoosterNFTToken = _BoosterNFTToken;
        CharacterNFTToken = _CharacterNFTToken;
        Token = _Token;
        baseRate = _baseRate;

        totalReward = 0;
        rewardTokenAmount = 0;
        tvl = 0;
    }

    //structs
    struct Staking {
        address staker;
        uint256 amount;
        uint256[] boosterNftIds;
        uint256[] characterNftIds;
        mapping(uint256 => uint256) boosterNftTokenIndex;
        mapping(uint256 => uint256) characterNftTokenIndex;
        uint256 lastTime;
        uint256 rewardRate;
        uint256 pendingReward;
    }

    mapping(address => Staking) public StakingData;

    event NFTTokenStaked(address indexed staker, address indexed token, uint256[] tokenIds);
    event NFTTokenUnstaked(address indexed staker, address indexed token, uint256[] tokenIds);
    event rewardClaimed(address indexed staker, address indexed token, uint256 amount);
    event tokenStaked(address indexed staker, address indexed token, uint256 amount);
    event tokenUnstaked(address indexed staker, address indexed token, uint256 amount);

    function stakeBoosterNFTToken(address token, uint256[] calldata tokenIds) external {
        require(token == BoosterNFTToken, "incorrect BoosterNFT to stake");

        uint256 tokenId;
        uint256 len = tokenIds.length;

        updateReward(msg.sender);
        Staking storage stakingInfo = StakingData[msg.sender];

        for (uint256 i; i < len; ) {
            tokenId = tokenIds[i];
            IERC721(token).transferFrom(msg.sender, address(this), tokenId);
            stakingInfo.boosterNftIds.push(tokenId);
            stakingInfo.boosterNftTokenIndex[tokenId] = stakingInfo.boosterNftIds.length - 1;
        }
        stakingInfo.rewardRate =
            baseRate +
            4500 +
            (stakingInfo.boosterNftIds.length + stakingInfo.characterNftIds.length) *
            500;

        emit NFTTokenStaked(msg.sender, token, tokenIds);
    }

    function stakeCharacterNFTToken(address token, uint256[] calldata tokenIds) external {
        require(token == CharacterNFTToken, "incorrect CharacterNFT to stake");

        uint256 tokenId;
        uint256 len = tokenIds.length;

        updateReward(msg.sender);
        Staking storage stakingInfo = StakingData[msg.sender];

        for (uint256 i; i < len; ) {
            tokenId = tokenIds[i];
            IERC721(token).transferFrom(msg.sender, address(this), tokenId);
            stakingInfo.characterNftIds.push(tokenId);
            stakingInfo.characterNftTokenIndex[tokenId] = stakingInfo.characterNftIds.length - 1;
        }
        stakingInfo.rewardRate =
            baseRate +
            4500 +
            (stakingInfo.boosterNftIds.length + stakingInfo.characterNftIds.length) *
            500;

        emit NFTTokenStaked(msg.sender, token, tokenIds);
    }

    function unstakeBoosterNFTToken(address token, uint256[] calldata tokenIds) external {
        require(token == BoosterNFTToken, "incorrect BoosterNFT to unstake");

        uint256 tokenId;
        uint256 len = tokenIds.length;

        updateReward(msg.sender);
        Staking storage stakingInfo = StakingData[msg.sender];

        for (uint256 i; i < len; ) {
            tokenId = tokenIds[i];
            require(IERC721(token).ownerOf(tokenId) == address(this), "Incorrect BoosterNFT Token ID");
            IERC721(token).transferFrom(address(this), msg.sender, tokenId);

            uint256 oldIndex = stakingInfo.boosterNftTokenIndex[tokenId]
            uint256 lastTokenId = stakingInfo.boosterNftIds[stakingInfo.boosterNftIds.length - 1]
            stakingInfo.boosterNftIds[oldIndex] = lastTokenId;
            stakingInfo.boosterNftTokenIndex[lastTokenId] = oldIndex;

            delete stakingInfo.boosterNftTokenIndex[tokenId];
            stakingInfo.boosterNftIds.pop();
        }

        stakingInfo.rewardRate =
            baseRate +
            4500 +
            (stakingInfo.boosterNftIds.length + stakingInfo.characterNftIds.length) *
            500;

        emit NFTTokenUnstaked(msg.sender, token, tokenId);
    }

    function unstakeCharacterNFTToken(address token, uint256[] calldata tokenIds) external {
        require(token == CharacterNFTToken, "incorrect CharacterNFT to unstake");

        uint256 tokenId;
        uint256 len = tokenIds.length;

        updateReward(msg.sender);
        Staking storage stakingInfo = StakingData[msg.sender];

        for (uint256 i; i < len; ) {
            tokenId = tokenIds[i];
            require(IERC721(token).ownerOf(tokenId) == address(this), "Incorrect CharacterNFT Token ID");
            IERC721(token).transferFrom(address(this), msg.sender, tokenId);

            uint256 oldIndex = stakingInfo.characterNftTokenIndex[tokenId]
            uint256 lastTokenId = stakingInfo.characterNftIds[stakingInfo.characterNftIds.length - 1]
            stakingInfo.characterNftIds[oldIndex] = lastTokenId;
            stakingInfo.characterNftTokenIndex[lastTokenId] = oldIndex;

            delete stakingInfo.characterNftTokenIndex[tokenId];
            stakingInfo.characterNftIds.pop();
        }

        stakingInfo.rewardRate =
            baseRate +
            4500 +
            (stakingInfo.boosterNftIds.length + stakingInfo.characterNftIds.length) *
            500;

        emit NFTTokenUnstaked(msg.sender, token, tokenId);
    }

    function stakeToken(address token, uint256 amount) external {
        require(token == Token, "incorrect Token to stake");

        Staking storage stakingInfo = StakingData[msg.sender];

        updateReward(msg.sender);

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        if (stakingInfo.boosterNftIds.length == 0 && stakingInfo.characterNftIds.length == 0) {
            stakingInfo.rewardRate = baseRate;
        }

        stakingInfo.amount += amount;

        tvl += amount;

        emit tokenStaked(msg.sender, token, amount);
    }

    function unstakeToken(address token, uint256 amount) external nonReentrant {
        require(token == Token, "incorrect Token to unstake");

        Staking storage stakingInfo = StakingData[msg.sender];

        updateReward(msg.sender);

        IERC20(token).transfer(msg.sender, amount);

        stakingInfo.amount -= amount;

        tvl -= amount;

        emit tokenUnstaked(msg.sender, token, amount);
    }

    function claimReward() external nonReentrant {
        Staking storage stakingInfo = StakingData[msg.sender];

        require(stakingInfo.staker == msg.sender, "Invalid address");

        updateReward(msg.sender);

        require(stakingInfo.pendingReward <= rewardTokenAmount, "Insufficient reward token");

        IERC20(Token).transfer(msg.sender, stakingInfo.pendingReward);
        totalReward += stakingInfo.pendingReward;

        emit rewardClaimed(msg.sender, Token, stakingInfo.pendingReward);
    }

    function updateReward(address _user) private {
        require(_user != address(0), "Zero Address");

        Staking storage stakingInfo = StakingData[msg.sender];

        if (stakingInfo.amount > 0) {
            uint256 reward = (stakingInfo.amount * stakingInfo.rewardRate * (block.timestamp - stakingInfo.lastTime)) /
                31536000 /
                10000;
            stakingInfo.pendingReward += reward;
        }
        stakingInfo.lastTime = block.timestamp;
    }

    function updateBoosterNFTToken(address _NFTToken) external onlyOwner {
        BoosterNFTToken = _NFTToken;
    }
    function updateCharacterNFTToken(address _NFTToken) external onlyOwner {
        CharacterNFTToken = _NFTToken;
    }

    function updateToken(address _Token) external onlyOwner {
        Token = _Token;
    }

    function updateBaseRate(uint256 _baseRate) external onlyOwner {
        baseRate = _baseRate;
    }
}
