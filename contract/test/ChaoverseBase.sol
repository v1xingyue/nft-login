// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/access/AccessControl.sol";
import "./interface/base.sol";

contract ChaoverseBase_0 is AccessControl, VeryBase {
    string[] public nftNames;
    uint256 public nftNamesCount;
    mapping(string => ChaoNFT) public communityNFTS;

    constructor() VeryBase("chaoverse.base", "0.0.2") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        nftNamesCount = 0;
    }

    function nftContain(string memory name) public view returns (bool) {
        ChaoNFT memory nft = communityNFTS[name];
        return
            nft.contractAddress != 0x0000000000000000000000000000000000000000 &&
            nft.tokenID != 0;
    }

    modifier nftAdded(string memory name) {
        require(nftContain(name));
        _;
    }

    function addNFT(
        string calldata name,
        address contractAddress,
        uint256 tokenID
    ) public onlyRole(DEFAULT_ADMIN_ROLE) notnftAdded(name) {
        nftNames.push(name);
        communityNFTS[name] = ChaoNFT(contractAddress, tokenID, 0);
        nftNamesCount += 1;
    }

    function updateWeight(string calldata name, uint256 weight)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        nftAdded(name)
    {
        ChaoNFT storage nft = communityNFTS[name];
        nft.weight = weight;
    }
}
