// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Set } from "./Set.sol";
import { MapSet } from "./MapSet.sol";
import { IRecord } from "./interfaces/IRecord.sol";
import { LibTypes } from "./libraries/LibTypes.sol";
import { IEntityIndexer } from "./interfaces/IEntityIndexer.sol";

abstract contract Record is IRecord {

    // Metadata
    address public world;
    address internal contractOwner;
    address public currentTenet;
    mapping(address => bool) writeAccess;
    uint256 public id;
    string public idString;   

    // Entity related data
    mapping(address => mapping(uint256 => bytes)) ownerToEntityValuePairs;
    mapping(address => address) ownerToValueToEntities; // MapSet
    mapping(address => address) ownerToEntities; // Set
    // IEntityIndexer[] internal indexers;

    constructor(
        address _world,
        uint256 _id,
        string memory _idString
    ) {
        currentTenet = address(0);
        contractOwner = msg.sender;
        writeAccess[msg.sender] = true;
        id = _id;
        idString = _idString;
        if (_world != address(0)) registerWorld(_world);
    }

    /** Revert if caller is not the owner of this component */
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "ONLY_OWNER");
        _;
    }

    /** Revert if caller does not have write access to this component */
    modifier onlyWriter() {
        require(writeAccess[msg.sender], "ONLY_WRITER");
        _;
    }

    /** Get the owner of this component */
    function owner() public view override returns (address) {
        return contractOwner;
    }

    function registerWorld(address _world) public onlyOwner {
        world = _world;
        IRecord(_world).authorizeWriter(address(this));
    }

    function authorizeWriter(address writer) external override onlyOwner {
        require(msg.sender == world, "Only world can authorize writers");
        writeAccess[writer] = true;
    }

    function unauthorizeWriter(address writer) external override onlyOwner {
        require(msg.sender == world, "Only world can unauthorize writers");
        writeAccess[writer] = false;
    }
    
    function set(uint256 entity, bytes memory value) public virtual override onlyWriter {
        // TODO: Improve Tenet checking
        if(currentTenet == address(0)) {
            currentTenet = msg.sender;
        }

        // Add entity to set
        Set(ownerToEntities[msg.sender]).add(entity);

        // Remove the entity from valueToEntities map
        MapSet valueToEntities = MapSet(ownerToValueToEntities[msg.sender]);
        valueToEntities.remove(uint256(keccak256(ownerToEntityValuePairs[msg.sender][entity])), entity);
        // Add the entity to the valueToEntities map
        valueToEntities.add(uint256(keccak256(value)), entity);

        // Add the entity to the entityValuePairs map
        ownerToEntityValuePairs[msg.sender][entity] = value;

        // TODO: Update indexer
    }

    function remove(uint256 entity) public virtual override onlyWriter {
        // Remove entity from set
        Set(ownerToEntities[msg.sender]).remove(entity);

        // Remove the entity from valueToEntities map
        MapSet(ownerToValueToEntities[msg.sender]).remove(uint256(keccak256(ownerToEntityValuePairs[msg.sender][entity])), entity);

        // Remove the entity from the entityValuePairs map
        delete ownerToEntityValuePairs[msg.sender][entity];

        // TODO: Update indexer
    }

    function has(uint256 entity, address _owner) public view virtual override returns (bool) {
        return Set(ownerToEntities[_owner]).has(entity);
    }

    function getRawValue(uint256 entity, address _owner) public view virtual override returns (bytes memory) {
        return ownerToEntityValuePairs[_owner][entity];
    }

    function getEntities(address _owner) public view virtual override returns (uint256[] memory) {
        return Set(ownerToEntities[_owner]).getItems();
    }

    function getEntitiesWithValue(bytes memory value, address _owner) public view virtual override returns (uint256[] memory) {
        return MapSet(ownerToValueToEntities[_owner]).getItems(uint256(keccak256(value)));
    }

    function transferOwnership(address newOwner) external override onlyOwner {
        writeAccess[msg.sender] = false;
        contractOwner = newOwner;
        writeAccess[newOwner] = true;
    }

    function changeCurrentTenet(address newGlobalOwner) public virtual {
        // TODO: Add proper mechanism for this:
        require(msg.sender == currentTenet, "Only global owner can change global owner");
        currentTenet = newGlobalOwner;
    }

    // TODO
    function registerIndexer(uint256 entity, IEntityIndexer indexer) external onlyOwner {}

    function getSchema() public pure virtual returns (string[] memory keys, LibTypes.SchemaValue[] memory values);
}   