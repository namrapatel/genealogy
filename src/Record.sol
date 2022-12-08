// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IRecord } from "./interfaces/IRecord.sol";
import { IEntityIndexer } from "./interfaces/IEntityIndexer.sol";
import { Set } from "./Set.sol";
import { MapSet } from "./MapSet.sol";
import { Dict } from "./Dict.sol";

abstract contract Record is IRecord {

    // Metadata
    address public world;
    address internal _owner;
    mapping(address => bool) writeAccess;
    uint256 public id;
    string public idString;   

    // Entity related data
    mapping(address => Dict[]) internal ownerToEntityValuePair;
    mapping(address => mapping(uint256 => uint256[])) ownerToValueToEntities;
    IEntityIndexer[] internal indexers;

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
    }

    function registerWorld(address _world) internal {
        world = _world;
        IRecord(_world).authorizeWriter(address(this));
    }

    function authorizeWriter(address writer) external override {
        require(msg.sender == world, "Only world can authorize writers");
        writeAccess[writer] = true;
    }

    function unauthorizeWriter(address writer) external override {
        require(msg.sender == world, "Only world can unauthorize writers");
        writeAccess[writer] = false;
    }
    
}