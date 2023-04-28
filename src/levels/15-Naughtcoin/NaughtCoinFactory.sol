// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './NaughtCoin.sol';

contract NaughtCoinFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;

        NaughtCoin instance = new NaughtCoin(_player); 
        require(instance.balanceOf(_player) > 0);       
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        NaughtCoin instance = NaughtCoin(_instance);
        return instance.balanceOf(_player) == 0;
    }

    receive() external payable {}
}