// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './CoinFlip.sol';

contract CoinFlipFactory is Level {
    function createInstance(address _player) override public payable returns (address) {
        _player;
        CoinFlip instance = new CoinFlip();
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        CoinFlip instance = CoinFlip(_instance);
        return instance.consecutiveWins() == 10;
    }
}