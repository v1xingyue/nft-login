// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC1155/ERC1155.sol";

contract ChaoverseMember_0 is AccessControl {
    uint256 public constant levelCacheBlock = 32;

    struct ChaoNFT {
        address contractAddress;
        uint256 tokenID;
        uint256 weight;
    }

    struct memberLevel {
        uint256 level;
        uint256 expire;
    }

    string public contractName = "chaoverse_member";
    string public version = "0.0.0";
    address payable public developer;

    string[] public nftNames;

    mapping(string => ChaoNFT) public communityNFTS;
    mapping(address => memberLevel) public userLevels;

    function donate() public payable {
        developer.transfer(msg.value);
    }

    constructor() {
        developer = payable(msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function nftContain(string memory name) public view returns (bool) {
        ChaoNFT memory nft = communityNFTS[name];
        return
            nft.contractAddress != 0x0000000000000000000000000000000000000000 &&
            nft.tokenID != 0;
    }

    modifier nftNotAdded(string memory name) {
        require(!nftContain(name));
        // 空函数体
        _;
    }

    modifier nftAdded(string memory name) {
        require(nftContain(name));
        // 空函数体
        _;
    }

    function addNFT(
        string calldata name,
        address contractAddress,
        uint256 tokenID
    ) public onlyRole(DEFAULT_ADMIN_ROLE) nftNotAdded(name) {
        nftNames.push(name);
        communityNFTS[name] = ChaoNFT(contractAddress, tokenID, 0);
    }

    function updateWeight(string calldata name, uint256 weight)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        nftAdded(name)
    {
        ChaoNFT storage nft = communityNFTS[name];
        nft.weight = weight;
    }

    function getTokenBalance(
        address checkAddress,
        address _contractAddr,
        uint256 _tokenId
    ) public view returns (uint256) {
        ERC1155 token = ERC1155(_contractAddr);
        return token.balanceOf(checkAddress, _tokenId);
    }

    function refreshLevel()
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 nftCount = nftNames.length;

        uint256 uniqueCount = 0;
        uint256 totalCount = 0;
        uint256 nftTmpCount = 0;

        for (uint256 i = 0; i < nftCount; i++) {
            string memory name = nftNames[i];
            if (nftContain(name)) {
                ChaoNFT memory nft = communityNFTS[name];
                nftTmpCount = getTokenBalance(
                    msg.sender,
                    nft.contractAddress,
                    nft.tokenID
                );

                if (nftCount > 0) {
                    uniqueCount += 1;
                    totalCount += nftTmpCount;
                }
            }
        }

        uint256 expireBlock = block.number + levelCacheBlock;

        // 练气
        if (totalCount >= 1) {
            userLevels[msg.sender] = memberLevel(1, expireBlock);
        }

        //筑基
        if (uniqueCount > 3) {
            userLevels[msg.sender] = memberLevel(2, expireBlock);
        }

        //结丹
        if (uniqueCount > 10) {
            userLevels[msg.sender] = memberLevel(3, expireBlock);
        }

        //元婴
        if (uniqueCount > 25) {
            userLevels[msg.sender] = memberLevel(4, expireBlock);
        }

        //化神
        if (totalCount >= 200 && uniqueCount >= 40) {
            userLevels[msg.sender] = memberLevel(5, expireBlock);
        }

        return (userLevels[msg.sender].level, uniqueCount, totalCount);
    }
}
