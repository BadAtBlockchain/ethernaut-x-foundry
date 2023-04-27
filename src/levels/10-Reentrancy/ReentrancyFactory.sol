// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Reentrancy.sol';

contract ReentrancyFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;

        Reentrance instance = new Reentrance();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Reentrance instance = Reentrance(_instance);
        return address(instance).balance == 0;
    }

    receive() external payable {}
}