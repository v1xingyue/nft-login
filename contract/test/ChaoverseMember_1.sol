// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC1155/ERC1155.sol";

contract ChaoverseMember_1 is AccessControl {
    event AccontNftGot(string name, address _addr, uint256 count);

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
    }

    uint256 public constant levelCacheBlock = 32;
    string public constant contractName = "chaoverse_member";
    string public constant version = "0.0.2";

    address payable public developer;
    string[] public nftNames;
    uint256 public nftNamesCount;

    mapping(string => ChaoNFT) public communityNFTS;
    mapping(address => memberLevel) public userLevels;

    constructor() {
        developer = payable(msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        nftNamesCount = 0;
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

                if (nftTmpCount > 0) {
                    emit AccontNftGot(name, msg.sender, nftTmpCount);
                    uniqueCount += 1;
                    totalCount += nftTmpCount;
                }
            }
        }

        uint256 expireBlock = block.number + levelCacheBlock;

        //??????
        if (totalCount >= 200 && uniqueCount >= 40) {
            userLevels[msg.sender] = memberLevel(
                5,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        //??????
        else if (uniqueCount > 25) {
            userLevels[msg.sender] = memberLevel(
                4,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        //??????
        else if (uniqueCount > 10) {
            userLevels[msg.sender] = memberLevel(
                3,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        //??????
        else if (uniqueCount > 3) {
            userLevels[msg.sender] = memberLevel(
                2,
                expireBlock,
                uniqueCount,
                totalCount
            );
        }
        // ??????
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
        return (userLevels[msg.sender].level, uniqueCount, totalCount);
    }
}
