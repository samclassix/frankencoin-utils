# frankencoin-utils

The `LiquidityController` contract is responsible for managing liquidity on Uniswap V3 protocol.
It implements the `IERC721Receiver` interface to receive NFTs, and the `AccessControl` contract to manage
admin and executor roles.

The contract has an immutable reference to the `INonfungiblePositionManager` contract, which is used
to interact with the Uniswap V3 protocol.

```
Contract (solidity): `contracts/LiquidityController.sol`
Interface (solidity): `contracts/interfaces/ILiquidityController.sol`
Interface (typescript): `exports/LiquidityController.ts`
```

# Deployed on Polygon for testing

https://polygonscan.com/address/0x10a0ddb46361b3f1d6405efffc1db96771bab85f

```
Smart Contract Address
0x10a0ddb46361b3f1d6405efffc1db96771bab85f
```

### Constructor Args

```
NonfungiblePositionManager (polygon)
0xC36442b4a4522E871399CD717aBDD847Ab11FE88

SwapRouter (polygon)
0xE592427A0AEce92De3Edee1F18E0157C05861564

Admin
0x7724C12D726F81a9BCeDA55D01A14460C57217cB

Executor
0x9229e0179a436CD0b77F731992307AC765Bc4b17
```

# Possible Usage

1. Deploy this SC with constructor params.
2. Approve transfers / set allowance
    - token0 -> `ERC20.approve(...)` -> SC
    - token1 -> `ERC20.approve(...)` -> SC
    - `SC:approveForManager(token0, token1, 1 << 255, 1 << 255);`
    - e.g. for "infinity" approvement
3. `SC:transferForTokens(token0, token1, amount0, amount1);`
4. `SC:mintNewPosition(token0, token1, fee, ...);`
5. `SC:collectFees(tokenId, true); // claim as admin`
6. or collect fees to contract for further use with `false`

# Idea of LiquidityController

![alt text](assets/idea.png)

# Scripts

```json
yarn run ...

"compile": "npx hardhat compile",
"test": "npx hardhat test",
"coverage": "npx hardhat coverage",
"publish": "npm publish --access public"
```

### Deploy & Verify

```bash
npx hardhat ignition deploy ./ignition/modules/LiquidityController.ts --network polygon --deployment-id dep1
npx hardhat verify --network polygon --constructor-args ./ignition/constructor-args/dep1.js 0xafc9c7A3fabe414D1bf558C8c3921A53ac0c52ca
```

> Check out ./ignition/deployments/[deployment]/deployed_addresses.json

> Check out ./ignition/deployments/[deployment]/journal.jsonl

# Version - Proof of Concept

> Check out `docs/Poc Development/Poc Development.md`

> Check out Tests on Polygon `docs/Poc Development/PoC Development.md`
