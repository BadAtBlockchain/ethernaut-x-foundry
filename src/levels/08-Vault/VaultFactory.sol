// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Vault.sol';

contract VaultFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;
        Vault instance = new Vault("AzureDiamond : hunter2");
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Vault instance = Vault(_instance);
        return !instance.locked();
    }
}