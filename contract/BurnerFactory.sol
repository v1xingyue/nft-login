// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ChaoverseBurner.sol";

contract BurnerFactory {
    ChaoverseBurner[] public list_of_burners;

    function createProduct() public returns (address) {
        ChaoverseBurner burner = new ChaoverseBurner(msg.sender);
        list_of_burners.push(burner);
        return address(burner);
    }
}
