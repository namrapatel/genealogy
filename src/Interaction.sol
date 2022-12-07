// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Procedure } from "./Procedure.sol";
import { addressToEntity } from "./utils.sol";

// Temporary
struct Role {
    string key;
    uint256 entity;
}

struct Turn {
    address state;
    uint256[] entitiesWithPermission;
    uint256 totalCallsAllowed;
    mapping(uint256 => uint256) entityToCallsAllowed;
    uint8[] roleIndexes;
    uint256[] sequenceOfEntitiesTakingTurns;
}

abstract contract Interaction {
   
    uint256 turnCounter;
    Role[] roles;
    mapping(uint256 => Turn) turns;

    bool isSequenced;
    uint256 currentSequenceIndex;
    // Turn Number -> Sequence of Entites taking turns
    mapping(uint256 => uint256[]) turnToSequenceOfEntitiesTakingTurns;


    constructor(
        Role[] memory _roles,
        address[] memory _states,
        uint256[] memory _totalCallsAllowed,    
        uint256[][] memory _entitiesWithPermission,
        uint256[][] memory _entityToCallsAllowed,
        uint8[][] memory _roleIndexes,
        bool _isSequenced,
        uint256[] memory _sequenceOfEntitiesTakingTurns,
        uint256 _currentSequenceIndex
    ) {
        turnCounter = 0;
        roles = _roles;
        isSequenced = _isSequenced;
        currentSequenceIndex = _currentSequenceIndex;

        for(uint256 i = 0; i < _states.length; i++) {
            turns[i] = Turn({
                state: _states[i],
                entitiesWithPermission: _entitiesWithPermission[i],
                totalCallsAllowed: _totalCallsAllowed[i],
                roleIndexes: _roleIndexes[i],
                sequenceOfEntitiesTakingTurns: _sequenceOfEntitiesTakingTurns
            });

            for(uint256 j = 0; j < _entitiesWithPermission[i].length; j++) {
                turns[i].entityToCallsAllowed[_entitiesWithPermission[i][j]] = _entityToCallsAllowed[i][j];
            }
        }
    }

    function authenticateAndExecute() public {
        Turn memory turn = turns[turnCounter];

        uint256[] memory entitiesWithPermission = turns[turnCounter].turnToEntitiesWithPermission;
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
        uint256 callsAllowed = turns[turnCounter][senderEntity].turnToEntityToCallsAllowed;
        require(callsAllowed > 0, "Sender has exceeded their calls allowed");

        // Require that the total calls allowed has not been exceeded
        uint256 totalCallsAllowed = turns[turnCounter].turnToTotalCallsAllowed;
        require(totalCallsAllowed > 0, "Total calls allowed has been exceeded");

        // Decrement the total calls allowed and the sender's calls allowed
        turns[turnCounter].turnToTotalCallsAllowed--;
        turns[turnCounter][senderEntity].turnToEntityToCallsAllowed--;

        // Get the role indexes for the sender
        uint8[] memory roleIndexes = turns[turnCounter].turnToRoleIndexes;

        execute(turns[turnCounter].turnToState, roleIndexes);
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

    function changeTurn(bytes memory executionResult) internal virtual {
        
    }

    function changeState(bytes memory executionResult) internal virtual;

}
