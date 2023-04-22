// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './King.sol';

contract KingFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;
        require(msg.value >= 0, "We need some ether to start");
        King instance = new King{value: msg.value}();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        King instance = King(_instance);
        (bool result, ) = address(instance).call{ value: 0 }("");
        !result;
        return instance._king() != address(this);
    }

    receive() external payable {}
}