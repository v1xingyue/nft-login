// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/access/AccessControl.sol";
import "./interface/base.sol";

contract ChaoverseBase is VeryBase, AccessControl, ICommunityNftCenter {
    uint256 public _nftCount;
    mapping(string => ChaoNFT) public _namedNFT;
    string[] public _nftNames;

    constructor() VeryBase("chaoverse.base", "0.0.0") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _nftCount = 0;
    }

    function nftContain(string memory name) public view returns (bool) {
        ChaoNFT memory nft = _namedNFT[name];
        return
            nft.contractAddress != 0x0000000000000000000000000000000000000000 &&
            nft.tokenID != 0;
    }

    modifier nftAdded(string memory name) {
        require(nftContain(name));
        _;
    }

    modifier nftNotAdded(string memory name) {
        require(!nftContain(name));
        _;
    }

    function setNFTName(uint256 idx, string calldata name)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _nftNames[idx] = name;
    }

    function addNFT(
        string calldata name,
        address contractAddress,
        uint256 tokenID
    ) public onlyRole(DEFAULT_ADMIN_ROLE) nftNotAdded(name) {
        _nftNames.push(name);
        _namedNFT[name] = ChaoNFT(contractAddress, tokenID, 0);
        _nftCount += 1;
    }

    function updateWeight(string calldata name, uint256 weight)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        nftAdded(name)
    {
        ChaoNFT storage nft = _namedNFT[name];
        nft.weight = weight;
    }

    function namedNFT(string calldata name)
        public
        view
        returns (ChaoNFT memory)
    {
        return _namedNFT[name];
    }

    function nftCount() public view returns (uint256) {
        return _nftCount;
    }

    function nftNames(uint256 idx) public view returns (string memory) {
        return _nftNames[idx];
    }
}
