// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/** Turn an Ethereum address into its corresponding entity ID. */
function addressToEntity(address addr) pure returns (uint256) {
  return uint256(uint160(addr));
}