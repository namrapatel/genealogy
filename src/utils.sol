// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import { Role } from "./Interaction.sol";

/** Turn an Ethereum address into its corresponding entity ID. */
function addressToEntity(address addr) pure returns (uint256) {
  return uint256(uint160(addr));
}

// Get uint256[] entities from Role[]
function rolesToEntities(Role[] memory roles) pure returns (uint256[] memory) {
  uint256[] memory entities = new uint256[](roles.length);
  for(uint256 i = 0; i < roles.length; i++) {
    entities[i] = roles[i].entity;
  }
  return entities;
}