pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/16-Preservation/PreservationFactory.sol';
import '../core/Ethernaut.sol';

contract PreservationTest is DSTest {
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

  function testPreservationHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    PreservationFactory preservationFactory = new PreservationFactory();
    ethernaut.registerLevel(preservationFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(preservationFactory);
    Preservation preservationContract = Preservation(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    // Due to the way storage works with delegate call,
    // we can create a malicious contract with similar storage slot layout
    // ensure the call signature matches and overwrite the owner (slot 3)
    // see PreservationAttack.sol
    preservationContract.setFirstTime(1000);

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

