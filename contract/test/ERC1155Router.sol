// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract myContract is ERC1155Receiver {
    event ContractNftGot(
        address _from,
        address _contract,
        uint256 _token,
        uint256 _count
    );

    function onERC1155Received(
        address _from,
        address _contract,
        uint256 _token,
        uint256 _count,
        bytes calldata
    ) public virtual override returns (bytes4) {
        emit ContractNftGot(_from, _contract, _token, _count);
        return this.onERC1155Received.selector;
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

    function buyItems(
        IERC1155 _contract,
        uint256 _itemId,
        uint256 _amount
    ) external {
        IERC1155 _IERC1155 = _contract;
        require(_IERC1155.balanceOf(address(this), _itemId) >= _amount);
        _IERC1155.safeTransferFrom(
            address(this),
            msg.sender,
            _itemId,
            _amount,
            ""
        );
    }
}
