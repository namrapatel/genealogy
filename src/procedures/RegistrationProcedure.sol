// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { World } from "../World.sol";
import { Procedure } from "../Procedure.sol";
import { addressToEntity, entityToAddress } from "../utils.sol";
import { IOwned } from "../interfaces/IOwned.sol";
import { Uint256Record } from "../records/Uint256Record.sol";

enum RegistrationType {
    Record,
    Procedure
}

uint256 constant ID = uint256(keccak256("world.procedure.register"));

contract RegistrationProcedure is Procedure {
    constructor(
        World _world,
        address[] memory _subProcedures,
        uint8[] memory numIdsBySubProcedure,
        string[] memory ids,
        string memory idString
    ) Procedure(
        _world,
        _subProcedures,
        numIdsBySubProcedure,
        ids,
        "world.procedure.register"
    ) {}

    function _execute(bytes memory arguments) public override returns (bytes memory) {
        (address msgSender, RegistrationType registrationType, address addr, uint256 id) = abi.decode(
            arguments,
            (address, RegistrationType, address, uint256)
        );

        require(msg.sender == address(world), "RegistrationProcedure can only be called via World.");
        require(registrationType == RegistrationType.Record || registrationType == RegistrationType.Procedure, "Invalid type.");
        require(id != 0, "Invalid id.");
        require(addr != address(0), "Invalid address.");

        Uint256Record registry = registrationType == RegistrationType.Record 
            ? world.getRecords()
            : world.getProcedures();
        uint256 entity = addressToEntity(addr);

        address currentTenet = registry.currentTenet();
        require(!registry.has(entity, currentTenet), "entity already registered");

        uint256[] memory entitiesWithId = registry.getEntitiesWithValue(id, currentTenet);

        require(
        entitiesWithId.length == 0 ||
            (entitiesWithId.length == 1 && IOwned(entityToAddress(entitiesWithId[0])).owner() == msgSender),
        "id already registered and caller not owner"
        );

        if (entitiesWithId.length == 1) {
        // Remove previous system
        registry.remove(entitiesWithId[0]);
        }

        registry.set(entity, id);
    }
}