// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Procedure } from "./Procedure.sol";
import { addressToEntity } from "./utils.sol";

// Temporary
struct Role {
    string key;
    uint256 entity;
}

abstract contract Interaction {
   
    uint256 turnCounter;
    Role[] roles;
    // Turn Number -> State
    mapping(uint256 => address) turnToState;
    // Turn Number -> Entities with permission to execute this interaction
    mapping(uint256 => uint256[]) turnToEntitiesWithPermission;
    // Turn Number -> Total Calls Allowed
    mapping(uint256 => uint256) turnToTotalCallsAllowed;
    // Turn Number -> Entity -> Calls Allowed for that entity
    mapping(uint256 => mapping(uint256 => uint256)) turnToEntityToCallsAllowed;
    // Turn Number -> Sequence of Entites taking turns
    mapping(uint256 => uint256[]) turnToSequenceOfEntitiesTakingTurns;
    mapping(uint256 => uint8[]) turnToRoleIndexes; 

    // There needs to be a mapping between State Procedure

    constructor() {
        turnCounter = 0;
    }

    function authenticateAndExecute() public {
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

        // Require that the sender has not exceeded their calls allowed
        uint256 callsAllowed = turnToEntityToCallsAllowed[turnCounter][senderEntity];
        require(callsAllowed > 0, "Sender has exceeded their calls allowed");

        // Require that the total calls allowed has not been exceeded
        uint256 totalCallsAllowed = turnToTotalCallsAllowed[turnCounter];
        require(totalCallsAllowed > 0, "Total calls allowed has been exceeded");

        // Decrement the total calls allowed and the sender's calls allowed
        turnToTotalCallsAllowed[turnCounter]--;
        turnToEntityToCallsAllowed[turnCounter][senderEntity]--;

        // Get the role indexes for the sender
        uint8[] memory roleIndexes = turnToRoleIndexes[turnCounter];

        execute(turnToState[turnCounter], roleIndexes);
    }

    function execute(address stateAddress, uint8[] memory roleIndexes) internal {
        // Get the roles by the indexes
        Role[] memory _roles = new Role[](roleIndexes.length);
        for(uint256 i = 0; i < roleIndexes.length; i++) {
            roles[i] = roles[roleIndexes[i]];
        }

        bytes memory result = Procedure(stateAddress).execute(_roles);
        transition(result);
    }

    function transition(bytes memory executionResult) internal {
        turnCounter++;
        changeTurn(executionResult);
        changeState(executionResult);
    }

    function changeTurn(bytes memory executionResult) internal virtual;

    function changeState(bytes memory executionResult) internal virtual;

}
