// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Preservation.sol';
import './PreservationAttack.sol';

contract PreservationFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;

        PreservationAttack attack1 = new PreservationAttack();
        PreservationAttack attack2 = new PreservationAttack();

        Preservation instance = new Preservation(
            address(attack1), 
            address(attack2)
        );
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Preservation instance = Preservation(_instance);
        return instance.owner() == _player;
    }

    receive() external payable {}
}