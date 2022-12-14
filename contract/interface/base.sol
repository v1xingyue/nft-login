// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

struct ChaoNFT {
    address contractAddress;
    uint256 tokenID;
    uint256 weight;
}

struct memberLevel {
    uint256 level;
    uint256 expire;
    uint256 uniqueCount;
    uint256 totalCount;
    uint256 voteWeight;
}

interface ICommunityNftCenter {
    function nftCount() external returns (uint256);

    function setNFTName(uint256, string calldata) external;

    function nftNames(uint256) external returns (string memory);

    function namedNFT(string calldata) external returns (ChaoNFT memory);

    function addNFT(
        string calldata,
        address,
        uint256
    ) external;

    function updateWeight(string calldata, uint256) external;
}

contract VeryBase {
    address payable public developer;
    string public name;
    string public version;

    constructor(string memory _name, string memory _version) {
        developer = payable(msg.sender);
        name = _name;
        version = _version;
    }

    function donate() public payable {
        developer.transfer(msg.value);
    }
}
