// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Role } from "./Interaction.sol";
import { rolesToEntities } from "./utils.sol";

abstract contract Procedure {
    address[] subProcedures;
    mapping(address => string[]) subProcedureToOrderedRoleIds;

    constructor(address[] memory _subProcedures, uint8[] memory numIdsBySubProcedure, string[] memory ids) {
        subProcedures = _subProcedures;
        buildSubProcedureToOrderedRoleIds(numIdsBySubProcedure, ids);
    }

    function execute(uint256[] memory entities) public virtual returns (bytes memory result) {
        for(uint256 i = 0; i < subProcedures.length; i++) {
            address subProcedure = subProcedures[i];
            Role[] memory roles = getRoles(subProcedure, entities);
            bytes memory executionResult = _execute(roles);
            result = abi.encodePacked(result, executionResult);
        }
        return result;
    }

    // User would override this function
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
    function getRoles(address subProcedure, uint256[] memory entities) internal view returns (Role[] memory orderedRoles) {
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

    // Getting, setting, reordering
}
