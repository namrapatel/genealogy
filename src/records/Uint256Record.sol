// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "../Record.sol";

contract Uint256Record is Record {
    constructor(
        address world,
        uint256 id,
        string memory idString
    ) Record(world, id, idString) {}

    function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
        keys = new string[](1);
        values = new LibTypes.SchemaValue[](1);

        keys[0] = "value";
        values[0] = LibTypes.SchemaValue.UINT256;
    }

    function set(uint256 entity, uint256 value) public {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity, address owner) public view returns (uint256) {
        uint256 value = abi.decode(getRawValue(entity, owner), (uint256));
        return value;
    }

    function getEntitiesWithValue(uint256 value) public view returns (uint256[] memory) {
        return getEntitiesWithValue(abi.encode(value));
    }

}