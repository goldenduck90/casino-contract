// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.5 <0.9.0;

import {Ownable} from "./openzepplin/Ownable.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IERC721} from "./interfaces/IERC721.sol";
import {SafeMath} from "./openzepplin/SafeMath.sol";

contract StakingContract is Ownable {
    using SafeMath for uint256;

    address public NFTToken;
    address public Token;

    uint256 private baseRate;

    uint256 public tvl;
    uint256 public totalReward;
    uint256 public rewardTokenAmount;

    constructor(address _NFTToken, address _Token, uint256 _baseRate) {
        NFTToken = _NFTToken;
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
        uint[] nftIds;
        mapping(uint256 => uint256) nftTokenIndex;
        uint lastTime;
        uint256 rewardRate;
        uint256 pendingReward;
    }

    mapping(address => Staking) public StakingData;

    event NFTTokenStaked(address indexed staker, address indexed token, uint token_id);
    event NFTTokenUnstaked(address indexed staker, address indexed token, uint token_id);
    event rewardClaimed(address indexed staker, address indexed token, uint amount);
    event tokenStaked(address indexed staker, address indexed token, uint amount);
    event tokenUnstaked(address indexed staker, address indexed token, uint amount);

    function stakeNFTToken(address token, uint tokenId) public {
        require(token == NFTToken, "incorrect NFT to stake");

        updateReward(msg.sender);

        IERC721(token).transferFrom(msg.sender, address(this), tokenId);

        Staking storage stakingInfo = StakingData[msg.sender];
        stakingInfo.nftIds.push(tokenId);
        stakingInfo.rewardRate = baseRate + 4500 + stakingInfo.nftIds.length * 500;
        stakingInfo.nftTokenIndex[tokenId] = stakingInfo.nftIds.length - 1;

        emit NFTTokenStaked(msg.sender, token, tokenId);
    }

    function unstakeNFTToken(address token, uint tokenId) public {
        require(token == NFTToken, "incorrect NFT to unstake");
        require(IERC721(token).ownerOf(tokenId) == address(this), "Incorrect NFT Token ID");

        Staking storage stakingInfo = StakingData[msg.sender];

        updateReward(msg.sender);

        IERC721(token).transferFrom(address(this), msg.sender, tokenId);

        if (stakingInfo.nftIds.length > 0) {
            stakingInfo.nftIds.pop();
            delete stakingInfo.nftTokenIndex[tokenId];
        }

        stakingInfo.rewardRate = baseRate + 4500 + stakingInfo.nftIds.length * 500;

        emit NFTTokenUnstaked(msg.sender, token, tokenId);
    }

    function stakeToken(address token, uint256 amount) public {
        require(token == Token, "incorrect Token to stake");

        Staking storage stakingInfo = StakingData[msg.sender];

        updateReward(msg.sender);

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        if (stakingInfo.nftIds.length == 0) {
            stakingInfo.rewardRate = baseRate;
        }

        stakingInfo.amount += amount;

        tvl += amount;

        emit tokenStaked(msg.sender, token, amount);
    }

    function unstakeToken(address token, uint256 amount) public {
        require(token == Token, "incorrect Token to unstake");

        Staking storage stakingInfo = StakingData[msg.sender];

        updateReward(msg.sender);

        IERC20(token).transfer(msg.sender, amount);

        stakingInfo.amount -= amount;

        tvl -= amount;

        emit tokenUnstaked(msg.sender, token, amount);
    }

    function claimReward() public {
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

    function updateNFTToken(address _NFTToken) public onlyOwner {
        NFTToken = _NFTToken;
    }

    function updateToken(address _Token) public onlyOwner {
        Token = _Token;
    }

    function updateBaseRate(uint256 _baseRate) public onlyOwner {
        baseRate = _baseRate;
    }
}
