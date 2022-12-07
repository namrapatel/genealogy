// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Procedure } from "./Procedure.sol";
import { addressToEntity } from "./utils.sol";

abstract contract Interaction {
   
    uint256 turnCounter;
    address changeTurnProcedure;
    address changeStateProcedure;

    mapping(uint256 => address[]) turnToState;
    mapping(uint256 => uint256[]) turnToEntitiesWithPermission;

    constructor() {
        turnCounter = 0;

    }

    function authenticate() public {
        uint256[] memory entitiesWithPermission = turnToEntitiesWithPermission[turnCounter];
        uint256 senderEntity = addressToEntity(msg.sender);
        // Require that senderEntity is in the entitiesWithPermission array
        bool senderHasPermission = false;
        for(uint256 i = 0; i < entitiesWithPermission.length; i++) {
            if(entitiesWithPermission[i] == senderEntity) {
                senderHasPermission = true;
                break;
            }
        }
        require(senderHasPermission, "Sender does not have permission to execute this interaction");

        execute();

    }


    function execute() public virtual;

}
