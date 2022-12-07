// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Role } from "./Interaction.sol";

abstract contract Procedure {
    address[] subProcedures;

    constructor(address[] memory _subProcedures) {
        subProcedures = _subProcedures;
    }

    function execute(Role[] memory roles) public virtual returns (bytes memory result);
}
