// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IRecord } from "./interfaces/IRecord.sol";
import { IEntityIndexer } from "./interfaces/IEntityIndexer.sol";
import { Set } from "./Set.sol";
import { MapSet } from "./MapSet.sol";

abstract contract Record is IRecord {

    address public world;
    address internal _owner;
    mapping(address => bool) writeAccess;

    mapping(uint256 => bytes) internal entityToValue;
    Set internal entities;
    MapSet internal valueToEntities;
    IEntityIndexer[] internal indexers;

    uint256 public id;
    string public idString;   


    constructor(
        address _world,
        uint256 _id,
        string memory _idString
    ) {
        _owner = msg.sender;
        writeAccess[msg.sender] = true;
        id = _id;
        idString = _idString;
        if (_world != address(0)) registerWorld(_world);

        entities = new Set();
        valueToEntities = new MapSet();
    }
    
}