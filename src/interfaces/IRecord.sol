// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "./IOwned.sol";

interface IRecord is IOwned {
  function transferOwnership(address newOwner) external;

  function set(uint256 entity, bytes memory value) external;

  function remove(uint256 entity) external;

  function has(uint256 entity, address owner) external view returns (bool);

  function getRawValue(uint256 entity, address owner) external view returns (bytes memory);

  function getEntities(address owner) external view returns (uint256[] memory);

  function getEntitiesWithValue(bytes memory value, address owner) external view returns (uint256[] memory);

  function authorizeWriter(address writer) external;

  function unauthorizeWriter(address writer) external;
}
