// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { World } from "../World.sol";
import { Procedure } from "../Procedure.sol";

contract RegistrationProcedure is Procedure {
    constructor(
        World _world,
        string memory idString
    ) Procedure() {
        
    }

}