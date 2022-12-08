// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

/**
 * Implements a mapping(uint256 => uint256) and a bunch of helper functions for it
 */
contract Dict {

    mapping(uint256 => uint256) private items;
    mapping(uint256 => uint256) private itemToIndex;
    uint256[] private itemKeys;
    
    function add(uint256 key, uint256 value) public {
        if (has(key)) return;
    
        itemToIndex[key] = itemKeys.length;
        itemKeys.push(key);
        items[key] = value;
    }
    
    function remove(uint256 key) public {
        if (!has(key)) return;
    
        // Copy the last item to the given item's index
        itemKeys[itemToIndex[key]] = itemKeys[itemKeys.length - 1];
    
        // Update the moved item's stored index to the new index
        itemToIndex[itemKeys[itemToIndex[key]]] = itemToIndex[key];
    
        // Remove the given item's stored index
        delete itemToIndex[key];
    
        // Remove the last item
        itemKeys.pop();
    }
    
    function has(uint256 key) public view returns (bool) {
        if (itemKeys.length == 0) return false;
        if (itemToIndex[key] == 0) return itemKeys[0] == key;
        return itemToIndex[key] != 0;
    }
    
    function get(uint256 key) public view returns (uint256) {
        return items[key];
    }
    
    function getKeys() public view returns (uint256[] memory) {
        return itemKeys;
    }
    
    function size() public view returns (uint256) {
        return itemKeys.length;
    }
  
}