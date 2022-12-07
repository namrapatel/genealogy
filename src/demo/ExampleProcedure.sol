// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Procedure } from "../Procedure.sol";

struct Role {
    string key;
    uint256[] entities;
}

contract ExampleProcedure is Procedure {

    constructor(address[] memory _subProcedures) Procedure(_subProcedures) {}

    function execute(Role[] memory roles) public override returns (bytes memory result) {
        // Loop through the subProcedures and execute them
        return abi.encode("success");
    }
}
