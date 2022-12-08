// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Role } from "./Interaction.sol";

abstract contract Procedure {
    address[] subProcedures;
    mapping(address => string[]) subProcedureToOrderedRoleIds;

    constructor(address[] memory _subProcedures, uint8[] memory numIdsBySubProcedure, string[] memory ids) {
        subProcedures = _subProcedures;
        buildSubProcedureToOrderedRoleIds(numIdsBySubProcedure, ids);
    }

    // Takes a list of Roles and uses getRoles for each subprocedure to get the ordered list of entities
    // to pass to the subprocedure's execute function
    function execute(uint256[] memory roles) public virtual returns (bytes memory result) {
        for(uint256 i = 0; i < subProcedures.length; i++) {
            address subProcedure = subProcedures[i];
            uint256[] memory orderedEntities = getRoles(subProcedure, roles);
            bytes memory subProcedureResult = Procedure(subProcedure).execute(orderedEntities);
            result = abi.encodePacked(result, subProcedureResult);
        }
        return result;
    }

    function getRoles(address subProcedure, Role[] memory roles) internal returns (uint256[] memory orderedEntities) {
        string[] memory orderedRoleIds = subProcedureToOrderedRoleIds[subProcedure];
        orderedEntities = new uint256[](orderedRoleIds.length);
        for(uint256 i = 0; i < orderedRoleIds.length; i++) {
            string memory roleId = orderedRoleIds[i];
            for(uint256 j = 0; j < roles.length; j++) {
                if(keccak256(abi.encodePacked(roles[j].key)) == keccak256(abi.encodePacked(roleId))) {
                    orderedEntities[i] = roles[j].entity;
                    break;
                }
            }
        }
        return orderedEntities;
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
