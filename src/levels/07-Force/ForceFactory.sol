// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Force.sol';

contract ForceFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;
        Force instance = new Force();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Force instance = Force(_instance);
        return _instance.balance > 0;
    }
}