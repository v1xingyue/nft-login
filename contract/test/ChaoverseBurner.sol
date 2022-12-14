// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

// 测试地址
// 0xC52721C3F8582349356D2d8952Dbb1038964ee1a

contract ChaoverseBurner is ERC1155Receiver {
    struct BurnInfo {
        address _contract;
        uint256 burn_id;
        uint256 burn_count;
        uint256 reward_id;
        uint256 reward_count;
        address hole;
    }

    address public owner;
    BurnInfo public info;

    function onERC1155Received(
        address,
        address _from,
        uint256 _token,
        uint256 _count,
        bytes calldata
    ) public virtual override returns (bytes4) {
        IERC1155 _IERC1155 = IERC1155(info._contract);
        require(info._contract == msg.sender);
        if (_token == info.burn_id) {
            require(_IERC1155.balanceOf(address(this), info.reward_id) > 0);
            require(_count == info.burn_count);
            transerToHole(_IERC1155, _token, _count);
            _IERC1155.safeTransferFrom(
                address(this),
                _from,
                info.reward_id,
                info.reward_count,
                ""
            );
        }
        return this.onERC1155Received.selector;
    }

    function transerToHole(
        IERC1155 _IERC1155,
        uint256 _tokenId,
        uint256 amount
    ) private {
        _IERC1155.safeTransferFrom(
            address(this),
            info.hole,
            _tokenId,
            amount,
            ""
        );
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function rewardBalance() public view returns (uint256) {
        IERC1155 _IERC1155 = IERC1155(info._contract);
        return _IERC1155.balanceOf(address(this), info.reward_id);
    }

    function getReward() public onlyOwner {
        uint256 x = rewardBalance();
        IERC1155 _IERC1155 = IERC1155(info._contract);
        _IERC1155.safeTransferFrom(
            address(this),
            msg.sender,
            info.reward_id,
            x,
            ""
        );
    }

    function setBurnInfo(
        address _contract,
        address hole,
        uint256 burn_id,
        uint256 reward_id,
        uint256 reward_count,
        uint256 burn_count
    ) public onlyOwner {
        info = BurnInfo(
            _contract,
            burn_id,
            burn_count,
            reward_id,
            reward_count,
            hole
        );
    }
}
