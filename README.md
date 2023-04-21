# ethernaut-x-foundry

## Ethernaut puzzles solved & tested with foundry.

**Ethernaut**

https://ethernaut.openzeppelin.com/

**Foundry**

https://github.com/foundry-rs/foundry

**Mix Match of...**

https://github.com/0xEval/ethernaut-x-foundry

https://github.com/ciaranmcveigh5/ethernaut-x-foundry


## Info

This repo is setup to enable you to run the ethernaut levels locally rather than on Rinkeby. As a result you will see some contracts that are not related to individual level but instead to ethernaut's core contracts which determine if you have passed the level. 

These are the Ethernaut.sol & BaseLevel.sol contracts in the root of ./src and the factory contracts which have a naming convention of [X-LEVEL_NAME]Factory.sol in each levels repo. Have a read through if interested in what they do otherwise they can be ignored.

Make sure you're on the latest version of forge, what is your forge —version output? 
If it doesn’t show a date, try rm -rf ~/.cargo/bin/cast && rm -rf ~/.cargo/bin/forge

At the root of the repo run

```
foundryup 
forge install 
forge test
```

**File Locations**

Individual Levels can be found in their respective folders in the ./src folder.  

Eg [Fallback is located in ./src/levels/01-Fallback/Fallback.sol](src/Fallback/Fallback.sol)


Tests for each level can be found in the ./src/test folder and have the naming convention [X-LEVEL_NAME].t.sol. Each test effectively achieves the attack/exploit for the relative challenge.

Eg [Fallback test are located in ./src/test/01-Fallback.t.sol](src/test/Fallback.t.sol)


## Levels

| Level | Test |
| ------------- | -------------|
| [1. Fallback](src/levels/01-Fallback) | [1. Test](src/test/01-Fallback.t.sol) |


## References

@0xEval for the folder layout (partial clonage)
https://github.com/0xEval/ethernaut-x-foundry

@ciaranmcveigh5 for the initial project starting point (cloned)
https://github.com/ciaranmcveigh5/ethernaut-x-foundry

@cmichelio for his hardhat x ethernaut repo
https://github.com/MrToph/ethernaut

@0xSage for his great ethernaut tutorials - breaking down how each level can be defeated
https://medium.com/hackernoon/ethernaut-lvl-0-walkthrough-abis-web3-and-how-to-abuse-them-d92a8842d71b

@gakonst for his help on the foundry support channels and the tool itself
https://github.com/gakonst/foundry

@the_ethernaut for the puzzles to solve & learn from
https://ethernaut.openzeppelin.com/level/0x9CB391dbcD447E645D6Cb55dE6ca23164130D008



