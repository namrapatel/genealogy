// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Role } from "./Interaction.sol";
import { rolesToEntities } from "./utils.sol";

abstract contract Procedure {
    address[] public subProcedures;
    mapping(address => string[]) public subProcedureToOrderedRoleIds;

    constructor(address[] memory _subProcedures, uint8[] memory numIdsBySubProcedure, string[] memory ids) {
        subProcedures = _subProcedures;
        buildSubProcedureToOrderedRoleIds(numIdsBySubProcedure, ids);
    }

    function execute(uint256[] memory entities) public returns (bytes memory result) {
        if (subProcedures.length > 0) {
            for(uint256 i = 0; i < subProcedures.length; i++) {
                address subProcedure = subProcedures[i];
                Role[] memory roles = getRoles(subProcedure, entities);
                bytes memory executionResult = _execute(roles);
                result = abi.encodePacked(result, executionResult);
            }
            return result;
        } else {
            // This is the case where the procedure is a leaf node,
            // if _execute is not overridden, it will just return an empty bytes array
            return _execute(getRoles(address(0), entities)); 
        }
    }

    // User would override this function if they have their own logic they want to implement
    // instead of just executing the subprocedures
    function _execute(Role[] memory roles) public virtual returns (bytes memory result) {
        for(uint256 i = 0; i < subProcedures.length; i++) {
            address subProcedure = subProcedures[i];
            uint256[] memory entities = rolesToEntities(roles);
            bytes memory subProcedureResult = Procedure(subProcedure).execute(entities);
            result = abi.encodePacked(result, subProcedureResult);
        }
        return result;
    }

    // Takes a list of entities and the subprocedure and builds Role structs for each entity
    function getRoles(
        address subProcedure,
        uint256[] memory entities
    ) internal view returns (Role[] memory orderedRoles) {
        string[] memory orderedRoleIds = subProcedureToOrderedRoleIds[subProcedure];
        orderedRoles = new Role[](orderedRoleIds.length);
        for(uint256 i = 0; i < orderedRoleIds.length; i++) {
            string memory roleId = orderedRoleIds[i];
            orderedRoles[i] = Role({
                key: roleId,
                entity: entities[i]
            });
        }
        return orderedRoles;
    }

    function buildSubProcedureToOrderedRoleIds(
        uint8[] memory numIdsBySubProcedure,
        string[] memory ids
    ) internal {
        uint256 index = 0;
        for(uint256 i = 0; i < subProcedures.length; i++) {
            uint256 numIds = numIdsBySubProcedure[i];
            string[] memory orderedRoleIds = new string[](numIds);
            for(uint256 j = 0; j < numIds; j++) {
                orderedRoleIds[j] = ids[index];
                index++;
            }
            subProcedureToOrderedRoleIds[subProcedures[i]] = orderedRoleIds;
        }
    }

    function getSubProcedures() public view returns (address[] memory) {
        return subProcedures;
    }

    function setSubProcedures(address[] memory _subProcedures) public {
        subProcedures = _subProcedures;
    }

    function addSubProcedure(address _subProcedure) public {
        subProcedures.push(_subProcedure);
    }

    function removeSubProcedure(address _subProcedure) public {
        for(uint256 i = 0; i < subProcedures.length; i++) {
            if (subProcedures[i] == _subProcedure) {
                subProcedures[i] = subProcedures[subProcedures.length - 1];
                subProcedures.pop();
                break;
            }
        }
    }

    function getSubProcedureToOrderedRoleIds(address subProcedure) public view returns (string[] memory) {
        return subProcedureToOrderedRoleIds[subProcedure];
    }

    function setSubProcedureToOrderedRoleIds(address subProcedure, string[] memory ids) public {
        subProcedureToOrderedRoleIds[subProcedure] = ids;
    }

    function addSubProcedureToOrderedRoleIds(address subProcedure, string memory id) public {
        subProcedureToOrderedRoleIds[subProcedure].push(id);
    }

    function removeSubProcedureToOrderedRoleIds(address subProcedure, string memory id) public {
        string[] storage ids = subProcedureToOrderedRoleIds[subProcedure];
        for(uint256 i = 0; i < ids.length; i++) {
            if (keccak256(abi.encodePacked(ids[i])) == keccak256(abi.encodePacked(id))) {
                ids[i] = ids[ids.length - 1];
                ids.pop();
                break;
            }
        }
    }
}
