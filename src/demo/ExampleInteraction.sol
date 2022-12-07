// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Procedure } from "../Procedure.sol";
import { Interaction } from "../Interaction.sol";
import { addressToEntity } from "../utils.sol";

contract ExampleInteraction is Interaction{

    constructor() Interaction(

    ) {
        turnCounter = 0;
    }

    function changeTurn() public {
        turnCounter++;
    }

    function changeState() public { 
        turnCounter++;
    }

}   