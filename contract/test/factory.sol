// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// 合约部署合约

contract Product {
    address public owner;
    address public deployer;

    constructor(address _owner) {
        owner = _owner;
        deployer = msg.sender;
    }
}

contract Factory {
    Product product;
    Product[] public list_of_products;

    function createProduct() public returns (address) {
        product = new Product(msg.sender);
        list_of_products.push(product);
        return address(product);
    }
}
