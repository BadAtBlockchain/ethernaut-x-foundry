// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Preservation.sol';

contract PreservationFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;

        LibraryContract lib1 = new LibraryContract();
        LibraryContract lib2 = new LibraryContract();

        Preservation instance = new Preservation(
            address(lib1), 
            address(lib2)
        );
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Preservation instance = Preservation(_instance);
        return instance.owner() == _player;
    }

    receive() external payable {}
}