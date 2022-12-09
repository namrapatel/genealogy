// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Set } from "./Set.sol";
import { Uint256Record } from "./records/Uint256Record.sol";
import { RegistrationType, RegistrationProcedure, ID as registerationProcedureId } from "./procedures/RegistrationProcedure.sol";

uint256 constant recordsRecordId = uint256(keccak256("world.record.records"));
uint256 constant proceduresRecordId = uint256(keccak256("world.record.procedures"));
uint256 constant interactionsRecordId = uint256(keccak256("world.record.interactions"));

contract World {

    Set private entities = new Set();
    Uint256Record private _records;
    Uint256Record private _procedures;
    Uint256Record private _interactions;
    RegistrationProcedure public registrator;

    constructor() {
        _records = new Uint256Record(address(0), recordsRecordId, "world.record.records");
        _procedures = new Uint256Record(address(0), proceduresRecordId, "world.record.procedures");
        _interactions = new Uint256Record(address(0), interactionsRecordId, "world.record.interactions");
        
        // Initialize registration procedure
        registrator = new RegistrationProcedure(this, "world.procedure.register");

        // Authorize registration procedure to write to the list of records, procedures, and interactions
        _records.authorizeWriter(address(registrator));
        _procedures.authorizeWriter(address(registrator));
        _interactions.authorizeWriter(address(registrator));
    }

    function init() public {
        _records.registerWorld(address(this));
        _procedures.registerWorld(address(this));
        _interactions.registerWorld(address(this));
        registrator.execute(abi.encode(msg.sender, RegistrationType.Procedure, address(registrator), registerationProcedureId));
    }

    function getRecords() public view returns (Uint256Record) {
        return _records;
    }

    function getProcedures() public view returns (Uint256Record) {
        return _procedures;
    }

    function getInteractions() public view returns (Uint256Record) {
        return _interactions;
    }
}