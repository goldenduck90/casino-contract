// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

import {IERC20} from "./interfaces/IERC20.sol";
import {Ownable} from "./openzepplin/Ownable.sol";
import {SafeMath} from "./openzepplin/SafeMath.sol";

contract CoinFlip is Ownable {
    using SafeMath for uint256;
    IERC20 public token;
    uint256 public fee;

    uint256 private lastHash;
    uint256 private FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    mapping(address => uint256) public pendingAmount;

    event FlipFinished(address player, bool result, uint256 amount);

    constructor(IERC20 _token, uint256 _fee) {
        token = _token;
        fee = _fee;
    }

    function flip(bool _guess, uint256 _amount) public {
        uint256 blockValue = uint256(blockhash(block.number.sub(1)));

        if (lastHash == blockValue) {
            revert("Invalid Block");
        }

        token.transferFrom(msg.sender, address(this), _amount);

        lastHash = blockValue;
        uint256 coinFlip = blockValue.div(FACTOR);
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            pendingAmount[msg.sender] = _amount * 2;
            emit FlipFinished(msg.sender, true, _amount);
        } else {
            pendingAmount[msg.sender] = 0;
            emit FlipFinished(msg.sender, false, _amount);
        }
    }

    function claim() public payable {
        require(pendingAmount[msg.sender] > 0, "Nothing to claim");

        uint256 rewardAmount = pendingAmount[msg.sender].mul(10000 - fee).div(10000);
        token.transfer(msg.sender, rewardAmount);
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function withdraw(uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}
