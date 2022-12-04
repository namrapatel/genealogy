// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract Procedure {
    address[] subProcedures;

    constructor(address[] memory _subProcedures) {
        subProcedures = _subProcedures;
    }

    function execute() public virtual;
}
