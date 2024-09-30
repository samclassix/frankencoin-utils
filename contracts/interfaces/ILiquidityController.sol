// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

interface ILiquidityController {
	function nonfungiblePositionManager() external view returns (INonfungiblePositionManager);
	function swapRouter() external view returns (ISwapRouter);

	function deposits(
		uint256 tokenId
	) external view returns (address token0, address token1, uint24 fee, int24 tickLower, int24 tickUpper);

	function onERC721Received(
		address operator,
		address from,
		uint256 tokenId,
		bytes calldata data
	) external returns (bytes4);

	function redeemOwnership(address toTransfer, address to) external;
	function redeemToken(address token, address to, uint256 value) external;
	function redeemNFT(uint256 tokenId, address to) external;

	function transferForDeposit(uint256 tokenId, uint256 amount0, uint256 amount1) external;
	function transferForTokens(address token0, address token1, uint256 amount0, uint256 amount1) external;

	function approveManager(address token0, address token1, uint256 amount0, uint256 amount1) external;
	function approveRouter(address token0, address token1, uint256 amount0, uint256 amount1) external;
	function approve(address token, address to, uint256 amount) external;

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
	) external returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

	function collectFees(uint256 tokenId, bool withdraw) external returns (uint256 amount0, uint256 amount1);

	function increaseLiquidity(
		uint256 tokenId,
		uint256 amount0Desired,
		uint256 amount1Desired,
		uint256 amount0Min,
		uint256 amount1Min
	) external returns (uint128 liquidity, uint256 amount0, uint256 amount1);

	function decreaseLiquidity(
		uint256 tokenId,
		uint128 liquidity,
		uint256 amount0Min,
		uint256 amount1Min
	) external returns (uint256 amount0, uint256 amount1);

	function swapExactInputSingle(
		address tkn0,
		address tkn1,
		uint24 fee,
		uint256 amountIn,
		uint256 amountOutMinimum,
		uint160 sqrtPriceLimitX96
	) external returns (uint256 amountOut);

	function swapExactOutputSingle(
		address tkn0,
		address tkn1,
		uint24 fee,
		uint256 amountOut,
		uint256 amountInMaximum,
		uint160 sqrtPriceLimitX96
	) external returns (uint256 amountIn);

	event NewDeposit(uint256 tokenId, address token0, address token1, uint24 fee);
	event CollectedFees(uint256 tokenId, uint256 amount0, uint256 amount1);
	event LiquidityIncreased(uint256 tokenId, uint256 amount0, uint256 amount1, uint256 liquidity);
	event LiquidityDecreased(uint256 tokenId, uint256 amount0, uint256 amount1, uint256 liquidity);
	event TokenSwap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
}
