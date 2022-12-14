// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.8.0/access/AccessControl.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC1155/IERC1155.sol";
import "./interface/base.sol";

contract ChaoverseBurner is VeryBase, ERC1155Receiver {
    // hole 地址 0x0000000000000000000000000000000000000001
    struct BurnInfo {
        address _contract;
        uint256[] burn_ids;
        uint256 burn_count;
        uint256 reward_id;
        uint256 reward_count;
        address hole;
        uint256 oneAddrMaxGet;
    }
    mapping(address => uint256) rewarded;
    address[] rewardedAddress;

    address public owner;
    BurnInfo public info;

    constructor() VeryBase("chaoverse.burner", "0.0.2") {
        owner = msg.sender;
    }

    function addressNotRewarded(address addr) private view returns (bool) {
        return rewarded[addr] < info.oneAddrMaxGet;
    }

    function burnValid(uint256 id) private view returns (bool) {
        if (id == info.reward_id) {
            return true;
        }
        uint256 idsCount = info.burn_ids.length;
        for (uint256 i = 0; i < idsCount; i++) {
            if (info.burn_ids[i] == id) {
                return true;
            }
        }
        return false;
    }

    function onERC1155Received(
        address,
        address _from,
        uint256 _token,
        uint256 _count,
        bytes calldata
    ) public virtual override returns (bytes4) {
        if (_token == info.reward_id) {
            return this.onERC1155Received.selector;
        } else {
            IERC1155 _IERC1155 = IERC1155(info._contract);
            require(info._contract == msg.sender);
            require(burnValid(_token));
            require(addressNotRewarded(_from));
            require(
                _IERC1155.balanceOf(address(this), info.reward_id) >=
                    info.reward_count
            );
            require(_count == info.burn_count);

            transerToHole(_IERC1155, _token, _count);
            _IERC1155.safeTransferFrom(
                address(this),
                _from,
                info.reward_id,
                info.reward_count,
                ""
            );

            rewarded[_from] += 1;
            if (rewarded[_from] == 1) {
                rewardedAddress.push(_from);
            }
            return this.onERC1155Received.selector;
        }
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

    function resetReward() private {
        uint256 l = rewardedAddress.length;
        for (uint256 i = 0; i < l; i++) {
            rewarded[rewardedAddress[i]] = 0;
        }
    }

    function setBurnInfo(
        address _contract,
        address hole,
        uint256[] calldata burn_ids,
        uint256 reward_id,
        uint256 reward_count,
        uint256 burn_count,
        uint256 oneAddrGetMax
    ) public onlyOwner {
        resetReward();
        info = BurnInfo(
            _contract,
            burn_ids,
            burn_count,
            reward_id,
            reward_count,
            hole,
            oneAddrGetMax
        );
    }

    function burnInfo(uint256 idx) public view returns (uint256, uint256) {
        return (info.burn_ids.length, info.burn_ids[idx]);
    }
}
