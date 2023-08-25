// SPDX-License-Identifier: MIT
pragma solidity >=0.8.5 <0.9.0;

import {IERC20} from "./interfaces/IERC20.sol";
import {Ownable} from "./openzepplin/Ownable.sol";
import {SafeMath} from "./openzepplin/SafeMath.sol";

contract Dice is Ownable {
    using SafeMath for uint256;
    IERC20 public token;
    uint256 public fee;
    uint256 lastHash;

    struct Bet {
        bool result;
        uint256 amount;
        uint256 guess;
        uint256 dice1;
        uint256 dice2;
        bool claimed;
    }

    mapping(address => Bet) public DiceData;

    event DiceFinished(Bet betData);

    constructor(IERC20 _token, uint256 _fee) {
        token = _token;
        fee = _fee;
    }

    function flip(uint256 _guess, uint256 _amount) public {
        require(_guess < 3, "Invalid guess number");

        token.transferFrom(msg.sender, address(this), _amount);

        uint256 dice1 = uint256(blockhash(block.number - 1 + block.timestamp)).mod(6).add(1);
        uint256 dice2 = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.number, block.prevrandao)))
            .mod(6)
            .add(1);

        uint256 result = 3;
        if (dice1 < dice2) result = 0;
        else if (dice1 == dice2) result = 1;
        else if (dice1 > dice2) result = 2;

        Bet memory data = Bet({
            result: (result == _guess),
            amount: _amount,
            guess: _guess,
            dice1: dice1,
            dice2: dice2,
            claimed: false
        });
        DiceData[msg.sender] = data;

        emit DiceFinished(data);
    }

    function claim() public payable {
        Bet memory data = DiceData[msg.sender];
        require(data.result == true, "Nothing to claim");
        require(data.claimed == false, "Already claimed");

        uint256 multiplier = data.guess == 1 ? 4 : 2;
        uint256 rewardAmount = data.amount.mul(multiplier).mul(10000 - fee).div(10000);

        token.transfer(msg.sender, rewardAmount);

        DiceData[msg.sender].claimed = true;
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }
}
