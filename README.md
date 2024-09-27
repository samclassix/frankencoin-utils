# frankencoin-utils

### Idea of LiquidityController

![alt text](assets/idea.png)

# Scripts

```json
yarn run ...

"compile": "npx hardhat compile",
"test": "npx hardhat test",
"coverage": "npx hardhat coverage",
"publish": "npm publish --access public"
```

# NPM publish

This will help with typescript, abi and deployment addresses support.

```bash
npm publish --access public
```

### Export abi.ts

...

# Version - PoC

### Setup

Add the correct openzepplin solidity version, otherwise it won't compile.

> yarn add @openzeppelin/contracts@3.4.2

```
// Importent
pragma solidity =0.7.6;
pragma abicoder v2;
```

### Liquidity Controller

`contract LiquidityController is IERC721Receiver, AccessControl {}`

Implements:

-   IERC721Receiver, to receive NFTs
-   AccessControl, for admin(s) and executor(s)

### IERC721Receiver

```
INonfungiblePositionManager public immutable nonfungiblePositionManager;

// Represents the deposit of an NFT
struct Deposit {
    address owner;
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
}

// @dev: for storing the NFTs, deposits[tokenId] => Deposit
mapping(uint256 => Deposit) public deposits;
```

### AccessControl

```
bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');

modifier onlyAdmins() {
    require(hasRole(ADMIN_ROLE, msg.sender) == true, 'No Admin');
    _;
}
modifier onlyAdminsOrExecutors() {
    require(
        hasRole(ADMIN_ROLE, msg.sender) == true || hasRole(EXECUTOR_ROLE, msg.sender) == true,
        'No AdminOrExecutor'
    );
    _;
}
```

## AccessControl Functions

```
"function ADMIN_ROLE() view returns (bytes32)",
"function DEFAULT_ADMIN_ROLE() view returns (bytes32)",
"function EXECUTOR_ROLE() view returns (bytes32)",
"function getRoleAdmin(bytes32) view returns (bytes32)",
"function getRoleMember(bytes32,uint256) view returns (address)",
"function getRoleMemberCount(bytes32) view returns (uint256)",
"function grantRole(bytes32,address)",
"function hasRole(bytes32,address) view returns (bool)",
"function renounceRole(bytes32,address)",
"function revokeRole(bytes32,address)",
```

## Redeem safety function [admin]

```js
function redeemOwnership(address toTransfer, address to) external onlyAdmins {}
function redeemToken(address token, address to, uint256 value) external onlyAdmins {}
function redeemNFT(uint256 tokenId, address to) external onlyAdmins {}
```

## Approve / set allowance, transfer helper function [admin]

```js
// allow admins to set the allowance for the NFT pos.manager
function setAllowanceForManager(
    address token0,
    address token1,
    uint256 amount0,
    uint256 amount1
) external onlyAdmins {}

// allow admins to set any allowance (approve proxy)
function setAllowanceTo(address token, address to, uint256 amount) external onlyAdmins {}

// allow admins to transfer to a tokenId deposit
function transferForDeposit(uint256 tokenId, uint256 amount0, uint256 amount1) external onlyAdmins {}
```

## Mint [admin]

```js
// allow admins to create new positions (deposits)
function mintNewPosition(
    address token0,
    address token1,
    uint24 fee,
    int24 tickLower,
    int24 tickUpper,
    uint256 amount0ToMint,
    uint256 amount1ToMint,
    uint256 amount0Min,
    uint256 amount1Min
) external onlyAdmins returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) {}
```

## Control [admin/executor]

```js
function collectFees(uint256 tokenId) external onlyAdminsOrExecutors returns (uint256 amount0, uint256 amount1) {}

function increaseLiquidity(
    uint256 tokenId,
    uint256 amountAdd0,
    uint256 amountAdd1,
    uint256 amount0Min,
    uint256 amount1Min
) external onlyAdminsOrExecutors returns (uint128 liquidity, uint256 amount0, uint256 amount1) {}

function decreaseLiquidity(
    uint256 tokenId,
    uint128 liquidity,
    uint256 amount0Min,
    uint256 amount1Min
) external onlyAdminsOrExecutors returns (uint256 amount0, uint256 amount1) {}
```
