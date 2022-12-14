// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract mappingTest {
    mapping(uint256 => uint256) public data;
    uint256[] ids;

    function setValue(uint256 s) public {
        data[s] += 1;
        if (data[s] == 1) {
            ids.push(s);
        }
    }

    function resetMap() public {
        uint256 l = ids.length;
        for (uint256 x = 0; x < l; x++) {
            uint256 k = ids[x];
            data[k] = 0;
        }
    }
}
