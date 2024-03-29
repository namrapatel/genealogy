// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Procedure } from "./Procedure.sol";
import { addressToEntity } from "./utils.sol";

struct Role {
    string key;
    uint256 entity;
}

struct State {
    string key;
    address state;
}

// Potential variants:
// uint256 totalCallsAllowed;
// mapping(uint256 => uint256) entityToCallsAllowed;
// TODO: wait time by block timestamp?
// uint256[] sequenceOfEntitiesTakingTurns;

abstract contract Interaction {
   
    uint256 public turnCounter;
    Role[] public roles;
    State[] public states;
    mapping(uint256 => uint8[]) public turnToRoleIndexes;
    mapping(uint256 => address) public turnToState;
    bool locked;

    event Executed(uint256 indexed turnCounter, bytes indexed executionResult);
    event Transition(uint256 indexed turnCounter, Role[] indexed newRoles, address indexed newState);

    constructor(
        Role[] memory _roles,
        address[] memory _states,
        uint8[][] memory _roleIndexes,
        bool _locked
    ) {
        turnCounter = 0;
        roles = _roles;
        for(uint256 i = 0; i < _states.length; i++) {
            states.push(State({
                key: "", // TODO: what are state keys?
                state: _states[i]
            }));
            turnToState[i] = _states[i];
        }
        for(uint256 i = 0; i < _roleIndexes.length; i++) {
            turnToRoleIndexes[i] = _roleIndexes[i];
        }
        locked = _locked;
    }

    function authenticateAndExecute() public virtual {
        // Get the sender's entity
        uint256 senderEntity = addressToEntity(msg.sender);
        // Loop through roles and check that senderEntity is in one of them
        bool senderIsInRole = false;
        for(uint256 i = 0; i < roles.length; i++) {
            if(roles[i].entity == senderEntity) {
                senderIsInRole = true;
                break;
            }
        }
        require(senderIsInRole, "Sender is not in any of the roles for this interaction");

        // Get the role indexes for the sender
        uint8[] memory roleIndexes = turnToRoleIndexes[turnCounter];

        execute(turnToState[turnCounter], roleIndexes);
    }

    function execute(address stateAddress, uint8[] memory roleIndexes) internal {
        // Get the roles by the indexes
        uint256[] memory entities = new uint256[](roleIndexes.length);
        for(uint256 i = 0; i < roleIndexes.length; i++) {
            entities[i] = roles[roleIndexes[i]].entity;
        }

        // Execute the state
        bytes memory result = Procedure(stateAddress).execute(entities);
        emit Executed(turnCounter, result);
        transition(result);
    }

    function transition(bytes memory executionResult) internal {
        turnCounter++;
        Role[] memory newRoles = changeTurn(executionResult);
        address newState = changeState(executionResult);
        emit Transition(turnCounter, newRoles, newState);
    }

    function changeTurn(bytes memory executionResult) internal virtual returns (Role[] memory);

    function changeState(bytes memory executionResult) internal virtual returns (address);

    function setRoles(Role[] memory _roles) public {
        require(!locked, "Interaction is locked");
        roles = _roles;
    }

    function setStates(State[] memory _states) public {
        require(!locked, "Interaction is locked");
        states = _states;
    }

    function setTurnToRoleIndexes(uint256 turn, uint8[] memory roleIndexes) public {
        require(!locked, "Interaction is locked");
        turnToRoleIndexes[turn] = roleIndexes;
    }

    function setTurnToState(uint256 turn, address state) public {
        require(!locked, "Interaction is locked");
        turnToState[turn] = state;
    }
}