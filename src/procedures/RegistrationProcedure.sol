// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { World } from "../World.sol";
import { Procedure } from "../Procedure.sol";
import { addressToEntity } from "../utils.sol";

uint256 constant ID = uint256(keccak256(("world.procedure.register")));

enum RegisterationType {
    Record,
    Procedure
}

contract RegistrationProcedure is Procedure {
    constructor(
        World _world,
        string memory idString
    ) Procedure(
        _world,
        new address[](0),
        new uint8[](0),
        new string[](0),
        ID,
        "world.procedure.register"
    ) {}

    function _execute(
        address msgSender,
        RegistrationType registrationType,
        address addr,
        uint256 id
    ) public override returns (bytes memory) {

        require(msg.sender == address(world), "RegistrationProcedure can only be called via World.");
        require(registerType == RegisterType.Component || registerType == RegisterType.System, "Invalid type.");
        require(id != 0, "Invalid id.");
        require(addr != address(0), "Invalid address.");

        Uint256Record registry = registrationType = RegistrationType.Record 
            ? world._records
            : world._procedures;
        uint256 entity = addressToEntity(addr);

        require(!registry.has(entity), "entity already registered");

        uint256[] memory entitiesWithId = registry.getEntitiesWithValue(id);

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