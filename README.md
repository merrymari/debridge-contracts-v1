<br/>
<p align="center">
<a href="https://debridge.finance/" target="_blank">
<img src="https://user-images.githubusercontent.com/10200871/137014801-40decb80-0595-4f0f-8ee5-f0f1ab5c0380.png" width="225" alt="logo">
</a>
</p>
<br/>

[deBridge](https://debridge.finance/) — cross-chain interoperability
 and liquidity transfer protocol that allows the truly decentralized transfer of data and assets between various blockchains. deBridge protocol is an infrastructure platform and a hooking service which aims to become a standard for:
- cross-chain composability of smart contracts
- cross-chain swaps
- bridging of any arbitrary asset
- interoperability and bridging of NFTs

More information about the project can be also found in the [documentation portal](https://docs.debridge.finance/)
<br/>
Testnet UI deployed on [testnet.debridge.finance](https://testnet.debridge.finance/)

# Debridge Smart Contracts


The contracts' directory contains the following subfolders:

```
contracts/
	interfaces/ - contains interfaces of the project contracts
	libraries/ - libraries created for the project
	mock/ - contracts for tests
	periphery/ - periphery contracts
	transfers/ - related to core cross-chain functionality
```
The detailed methods' description can be found in the contracts themselves or in the [documentation](https://docs.debridge.finance/).

<!-- Part between CONTRACTS_AUTOGENERATED_DESCRIPTION* is autogenerated. Do no remove CONTRACTS_AUTOGENERATED_DESCRIPTION* -->
<!-- CONTRACTS_AUTOGENERATED_DESCRIPTION_START -->
## 
### CallProxy

Proxy to execute the other contract calls.
This contract is used when a user requests transfer with specific call of other contract.
### DeBridgeToken

ERC20 token that is used as wrapped asset to represent the native token value on the other chains.
### DeBridgeTokenProxy

This contract implements a proxy that gets the implementation address for each call
from DeBridgeTokenDeployer. It's deployed by DeBridgeTokenDeployer.
Implementation is DeBridgeToken.
### SimpleFeeProxy

Helper to withdraw fees from DeBridgeGate and transfer them to a treasury.
### DeBridgeGate

Contract for assets transfers. The user can transfer the asset to any of the approved chains.
The admin manages the assets, fees and other important protocol parameters.
### DeBridgeTokenDeployer

Deploys a deToken(DeBridgeTokenProxy) for an asset.
### OraclesManager

The base contract for oracles management. Allows adding/removing oracles,
managing the minimal required amount of confirmations.
### SignatureVerifier

It's used to verify that a transfer is signed by oracles.
### WethGate

Upgradable contracts cannot receive ether via `transfer` because of increased SLOAD gas cost.
We use this non-upgradeable contract as the recipient and then immediately transfer to an upgradable contract.
More details about this issue can be found
[here](https://forum.openzeppelin.com/t/openzeppelin-upgradeable-contracts-affected-by-istanbul-hardfork/1616).

<!-- CONTRACTS_AUTOGENERATED_DESCRIPTION_END -->

## [How Transfers Works](https://docs.debridge.finance/the-core-protocol/transfers)

## Test
Create a .env file with the content below (all are default values from ganache)
```dotenv
TEST_BSC_PROVIDER=https://bsc-dataseed.binance.org/
TEST_ORACLE_KEYS=["0x512aba028561d58c914fdcb31cc7f4dd9a433cb3672eb9eaf44302eb097ec3bc","0x79b2a2a43a1e9f325920f99a720605c9c563c61fb5ae3ebe483f83f1230512d3","0xefb1529474de412cfeb875bc13c47fe3032202bdf777f350415c877eddad62ba","0xed4a4d31740e08e1f30854271fdc31758349b89c9ae9da86711ed3001f1dc409","0x49378a90c0b6c07c5cadcfcb13222bd12eebb4e96455ff48b57e54baa12c91c1","0x1029e16ddabd4f7f38a175464eba097aea1173840f4286551ec435903823e94a","0xf4d8a0f92a47559cd2fb91ae67fe1c36de46b577695f4a44ce026b59b01289c6","0x6f3255cdf01eee387574036f0183c6b024dadc6aa4e5bb272d0564403e2e579f","0x40775e39b578b0ab1603f87636c9fac9697487d918d4647df7f8549c6eff3d09","0x3ecd7955f78fbd0c9025a742f778d8b292fb3c8544a17c1adb77fbe20f21bb63"]
MNEMONIC="cactus require cushion flavor mobile behave pole time wasp silk moon correct"
DEPLOYER_PRIVATE_KEY="0x512aba028561d58c914fdcb31cc7f4dd9a433cb3672eb9eaf44302eb097ec3bc"
DEPLOYER_ACCOUNT="0x6AFb86b6eE3A6a3F42Ae2526157f753DDdbd2f1E"
MULTISIG_ACCOUNT="0xe13E4F9441a381F54eD969c768713157D125e216"
INFURA_ID=xxx # Change to your infura id
```
then run `yarn test`

## Docs generation
`yarn docs`

## Troubleshooting
###  Cannot find module '../typechain-types' or its corresponding type declarations.
`hardhat clean`
>> https://github.com/dethcrypto/TypeChain/tree/master/packages/hardhat#installation
> 
>Warning: before running it for the first time you need to do hardhat clean, otherwise TypeChain will think that there is no need to generate any typings. This is because this plugin will attempt to do incremental generation and generate typings only for changed contracts. You should also do hardhat clean if you change any TypeChain related config option.
