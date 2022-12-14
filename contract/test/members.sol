// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/access/AccessControl.sol";

contract ChaoverseMember_1 is AccessControl {
    struct ChaoNFT {
        address contractAddress;
        uint256 tokenID;
    }

    ChaoNFT[] public nfts;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addNFT(address memory contractAddress, uint256 memory tokenID)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        nfts.push(ChaoNFT(contractAddress, tokenID));
    }
}
