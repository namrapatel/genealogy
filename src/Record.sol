// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Set } from "./Set.sol";
import { Dict } from "./Dict.sol";
import { MapSet } from "./MapSet.sol";
import { IRecord } from "./interfaces/IRecord.sol";
import { LibTypes } from "./libraries/LibTypes.sol";
import { IEntityIndexer } from "./interfaces/IEntityIndexer.sol";

abstract contract Record is IRecord {

    // Metadata
    address public world;
    address internal _owner;
    mapping(address => bool) writeAccess;
    uint256 public id;
    string public idString;   

    // Entity related data
    // TODO: Maybe use nested mapping instead of a contract for each owner
    mapping(address => mapping(uint256 => bytes)) ownerToEntityValuePairs; // 
    mapping(address => address) ownerToValueToEntities; // MapSet
    mapping(address => address) ownerToEntities; // Set
    // IEntityIndexer[] internal indexers;

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

    /** Revert if caller is not the owner of this component */
    modifier onlyOwner() {
        require(msg.sender == _owner, "ONLY_OWNER");
        _;
    }

    /** Revert if caller does not have write access to this component */
    modifier onlyWriter() {
        require(writeAccess[msg.sender], "ONLY_WRITER");
        _;
    }

    /** Get the owner of this component */
    function owner() public view override returns (address) {
        return _owner;
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

    function has(uint256 entity, address owner) public view virtual override returns (bool) {
        return Set(ownerToEntities[owner]).has(entity);
    }

    function getRawValue(uint256 entity, address owner) public view virtual override returns (bytes memory) {
        return ownerToEntityValuePairs[owner][entity];
    }

    function getEntities(address owner) public view virtual override returns (uint256[] memory) {
        return Set(ownerToEntities[owner]).getItems();
    }

    function getEntitiesWithValue(bytes memory value, address owner) public view virtual override returns (uint256[] memory) {
        return MapSet(ownerToValueToEntities[owner]).getItems(uint256(keccak256(value)));
    }

    function transferOwnership(address newOwner) external override onlyOwner {
       writeAccess[msg.sender] = false;
        _owner = newOwner;
        writeAccess[newOwner] = true;
    }

    function registerIndexer(uint256 entity, IEntityIndexer indexer) external onlyOwner {}

    // TODO: registerIndexer()

    function getSchema() public pure virtual returns (string[] memory keys, LibTypes.SchemaValue[] memory values);

}   