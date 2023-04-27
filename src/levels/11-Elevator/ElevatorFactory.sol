// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Elevator.sol';

contract ElevatorFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;

        Elevator instance = new Elevator();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Elevator instance = Elevator(_instance);
        return instance.top();
    }

    receive() external payable {}
}