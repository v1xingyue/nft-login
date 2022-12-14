// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC1155/ERC1155.sol";
import "./interface/base.sol";

contract ChaoverseLevel is VeryBase, AccessControl {
    ICommunityNftCenter ChaoCenter;
    mapping(address => memberLevel) public userLevels;

    constructor() VeryBase("chaoverse.level", "0.0.0") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        ChaoCenter = ICommunityNftCenter(msg.sender);
    }

    function SetChaoCenter(ICommunityNftCenter centerAddress) public {
        ChaoCenter = centerAddress;
    }

    function getTokenBalance(
        address checkAddress,
        address _contractAddr,
        uint256 _tokenId
    ) public view returns (uint256) {
        ERC1155 token = ERC1155(_contractAddr);
        return token.balanceOf(checkAddress, _tokenId);
    }

    function CountChaoNFT(address userAddress)
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 _nftCount = ChaoCenter.nftCount();

        uint256 uniqueCount = 0;
        uint256 totalCount = 0;
        uint256 nftTmpCount = 0;
        uint256 totalWeight = 0;

        for (uint256 i = 0; i < _nftCount; i++) {
            string memory name = ChaoCenter.nftNames(i);
            if (name != "") {
                ChaoNFT memory nft = ChaoCenter.namedNFT(name);
                nftTmpCount = getTokenBalance(
                    userAddress,
                    nft.contractAddress,
                    nft.tokenID
                );
                if (nftTmpCount > 0) {
                    uniqueCount += 1;
                    totalCount += nftTmpCount;
                    totalWeight += nftTmpCount * nft.weight;
                }
            }
        }
        return (uniqueCount, totalCount, totalWeight);
    }

    function refreshLevel(address userAddress) public returns (uint256) {
        uint256 uniqueCount = 0;
        uint256 totalCount = 0;
        uint256 totalWeight = 0;

        (uniqueCount, totalCount, totalWeight) = CountChaoNFT(userAddress);

        //化神
        if (totalCount >= 200 && uniqueCount >= 40) {
            userLevels[msg.sender] = memberLevel(
                5,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        //元婴
        else if (uniqueCount > 25) {
            userLevels[msg.sender] = memberLevel(
                4,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        //结丹
        else if (uniqueCount > 10) {
            userLevels[msg.sender] = memberLevel(
                3,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        //筑基
        else if (uniqueCount > 3) {
            userLevels[msg.sender] = memberLevel(
                2,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        // 练气
        else if (totalCount >= 1) {
            userLevels[msg.sender] = memberLevel(
                1,
                expireBlock,
                uniqueCount,
                totalCount
            );
        } else {
            userLevels[msg.sender] = memberLevel(0, expireBlock, 0, 0);
        }
    }
}
