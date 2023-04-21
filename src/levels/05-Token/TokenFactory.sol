// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import '../../core/BaseLevel.sol';
import './Token.sol';

contract TokenFactory is Level {
    uint256 public supply = 42069; // large amount for total supply
    uint256 public playerSupply = 20; // starting amount according to challenge

    function createInstance(address _player) override public payable returns (address) {
        _player;
        Token instance = new Token(supply);
        // set the player wallet up with starting capital relative to challenge
        instance.transfer(_player, playerSupply);
        return address(instance);
    }

    function validateInstance(address payable _instance, address _player) override public returns (bool) {
        Token instance = Token(_instance);
        return instance.balanceOf(_player) > playerSupply;
    }
}