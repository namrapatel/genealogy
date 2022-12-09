// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Set } from "./Set.sol";
import { Uint256Record } from "./records/Uint256Record.sol";

uint256 constant recordsRecordId = uint256(keccak256("world.record.records"));
uint256 constant proceduresRecordId = uint256(keccak256("world.record.procedures"));

contract World {

    Set private entities = new Set();
    Uint256Record private _records;
    Uint256Record private _procedures;

    constructor() {
        _records = new Uint256Record(address(0), recordsRecordId, "world.record.records");
        _procedures = new Uint256Record(address(0), proceduresRecordId, "world.record.procedures");
        
        
    }
}