// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Delegation.sol';

contract DelegationFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;
        Delegate delegateInstance = new Delegate(address(this));
        Delegation instance = new Delegation(address(delegateInstance));
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Delegation instance = Delegation(_instance);
        return instance.owner() == _player;
    }
}