// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract LiquidityController is IERC721Receiver, AccessControl {
	bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
	bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');

	INonfungiblePositionManager public immutable nonfungiblePositionManager;
	ISwapRouter public immutable swapRouter;

	// Represents the "Liquidity Position" (ERC721, NFT, Deposit, ...) at Uniswap
	struct Deposit {
		address token0;
		address token1;
		uint24 fee;
		int24 tickLower;
		int24 tickUpper;
	}

	// @dev: for storing the NFTs, deposits[tokenId] => Deposit
	mapping(uint256 => Deposit) public deposits;

	// ---------------------------------------------------------------------------------------
	event NewDeposit(uint256 tokenId, address token0, address token1, uint24 fee);
	event CollectedFees(uint256 tokenId, uint256 amount0, uint256 amount1, bool withdrawal);
	event LiquidityIncreased(uint256 tokenId, uint256 amount0, uint256 amount1, uint256 liquidity);
	event LiquidityDecreased(uint256 tokenId, uint256 amount0, uint256 amount1, uint256 liquidity);
	event TokenSwap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

	// ---------------------------------------------------------------------------------------
	modifier onlyAdmins() {
		require(hasRole(ADMIN_ROLE, msg.sender) == true, 'Not Admin');
		_;
	}
	modifier onlyAdminsOrExecutors() {
		require(
			hasRole(ADMIN_ROLE, msg.sender) == true || hasRole(EXECUTOR_ROLE, msg.sender) == true,
			'Not AdminOrExecutor'
		);
		_;
	}

	// ---------------------------------------------------------------------------------------
	constructor(
		INonfungiblePositionManager _nonfungiblePositionManager,
		ISwapRouter _swapRouter,
		address _admin,
		address _exec
	) {
		nonfungiblePositionManager = _nonfungiblePositionManager;
		swapRouter = _swapRouter;

		_setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
		_setRoleAdmin(EXECUTOR_ROLE, ADMIN_ROLE);

		_setupRole(ADMIN_ROLE, _admin);
		_setupRole(EXECUTOR_ROLE, _exec);
	}

	// ---------------------------------------------------------------------------------------
	// Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
	function onERC721Received(address, address, uint256 tokenId, bytes calldata) external override returns (bytes4) {
		_createDeposit(tokenId);
		return this.onERC721Received.selector;
	}

	function _createDeposit(uint256 tokenId) internal {
		(
			,
			address operator,
			address token0,
			address token1,
			uint24 fee,
			int24 tickLower,
			int24 tickUpper,
			,
			,
			,
			,

		) = nonfungiblePositionManager.positions(tokenId);
		require(operator == address(this), 'Not Owned');
		deposits[tokenId] = Deposit({
			token0: token0,
			token1: token1,
			fee: fee,
			tickLower: tickLower,
			tickUpper: tickUpper
		});
		emit NewDeposit(tokenId, token0, token1, fee);
	}

	// ---------------------------------------------------------------------------------------
	// Safety functions, ownership, erc20, erc721 // don't be stupid. :)
	function redeemOwnership(address toTransfer, address to) external onlyAdmins {
		Ownable(toTransfer).transferOwnership(to);
	}

	function redeemToken(address token, address to, uint256 value) external onlyAdmins {
		TransferHelper.safeTransfer(token, to, value);
	}

	function redeemNFT(uint256 tokenId, address to) external onlyAdmins {
		nonfungiblePositionManager.safeTransferFrom(address(this), to, tokenId);
		delete deposits[tokenId];
	}

	// ---------------------------------------------------------------------------------------
	// transfer helfer from msg.sender for a specific deposit type, -> needs allowance
	function transferForDeposit(uint256 tokenId, uint256 amount0, uint256 amount1) external onlyAdmins {
		transferForTokens(deposits[tokenId].token0, deposits[tokenId].token1, amount0, amount1);
	}

	function transferForTokens(address token0, address token1, uint256 amount0, uint256 amount1) public onlyAdmins {
		TransferHelper.safeTransferFrom(token0, msg.sender, address(this), amount0);
		TransferHelper.safeTransferFrom(token1, msg.sender, address(this), amount1);
	}

	// ---------------------------------------------------------------------------------------
	// approve for any two tokens to the manager
	function approveManager(address token0, address token1, uint256 amount0, uint256 amount1) external onlyAdmins {
		TransferHelper.safeApprove(token0, address(nonfungiblePositionManager), amount0);
		TransferHelper.safeApprove(token1, address(nonfungiblePositionManager), amount1);
	}

	function approveRouter(address token0, address token1, uint256 amount0, uint256 amount1) external onlyAdmins {
		TransferHelper.safeApprove(token0, address(swapRouter), amount0);
		TransferHelper.safeApprove(token1, address(swapRouter), amount1);
	}

	// approve, native proxy
	function approve(address token, address to, uint256 amount) external onlyAdmins {
		TransferHelper.safeApprove(token, to, amount);
	}

	// ---------------------------------------------------------------------------------------
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
	) external onlyAdmins returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) {
		INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
			token0: token0,
			token1: token1,
			fee: fee,
			tickLower: tickLower,
			tickUpper: tickUpper,
			amount0Desired: amount0ToMint,
			amount1Desired: amount1ToMint,
			amount0Min: amount0Min,
			amount1Min: amount1Min,
			recipient: address(this),
			deadline: block.timestamp
		});

		// @dev: needs allowance, see "approveManager"
		// @dev: pool needs to exist already, incl fee diff.
		(tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);

		// Create a deposit
		_createDeposit(tokenId);
	}

	// ---------------------------------------------------------------------------------------
	function collectFees(
		uint256 tokenId,
		bool withdraw
	) external onlyAdminsOrExecutors returns (uint256 amount0, uint256 amount1) {
		if (withdraw == true) {
			// check if you have the rights to withdraw
			require(hasRole(ADMIN_ROLE, msg.sender) == true, 'Not Admin');
		}

		// set amount0Max and amount1Max to uint256.max to collect all fees
		INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
			tokenId: tokenId,
			recipient: withdraw ? msg.sender : address(this), // give admin the write to withdraw, otherwise to SC
			amount0Max: type(uint128).max,
			amount1Max: type(uint128).max
		});

		(amount0, amount1) = nonfungiblePositionManager.collect(params);
		emit CollectedFees(tokenId, amount0, amount1, withdraw);
	}

	// ---------------------------------------------------------------------------------------
	function increaseLiquidity(
		uint256 tokenId,
		uint256 amount0Desired,
		uint256 amount1Desired,
		uint256 amount0Min,
		uint256 amount1Min
	) external onlyAdminsOrExecutors returns (uint128 liquidity, uint256 amount0, uint256 amount1) {
		INonfungiblePositionManager.IncreaseLiquidityParams memory params = INonfungiblePositionManager
			.IncreaseLiquidityParams({
				tokenId: tokenId,
				amount0Desired: amount0Desired,
				amount1Desired: amount1Desired,
				amount0Min: amount0Min,
				amount1Min: amount1Min,
				deadline: block.timestamp
			});

		// @dev: needs allowance, see "approveManager"
		(liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);
		emit LiquidityIncreased(tokenId, amount0, amount1, liquidity);
	}

	// ---------------------------------------------------------------------------------------
	function decreaseLiquidity(
		uint256 tokenId,
		uint128 liquidity,
		uint256 amount0Min,
		uint256 amount1Min
	) external onlyAdminsOrExecutors returns (uint256 amount0, uint256 amount1) {
		// @dev: amount0Min and amount1Min are price slippage checks
		// @dev: if the amount received after burning is not greater than these minimums, transaction will fail
		INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager
			.DecreaseLiquidityParams({
				tokenId: tokenId,
				liquidity: liquidity,
				amount0Min: amount0Min,
				amount1Min: amount1Min,
				deadline: block.timestamp
			});

		(amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);
		emit LiquidityDecreased(tokenId, amount0, amount1, liquidity);
	}

	// ---------------------------------------------------------------------------------------
	function swapExactInputSingle(
		address tkn0,
		address tkn1,
		uint24 fee,
		uint256 amountIn,
		uint256 amountOutMinimum,
		uint160 sqrtPriceLimitX96
	) external onlyAdminsOrExecutors returns (uint256 amountOut) {
		ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
			tokenIn: tkn0,
			tokenOut: tkn1,
			fee: fee,
			recipient: address(this),
			deadline: block.timestamp,
			amountIn: amountIn,
			amountOutMinimum: amountOutMinimum,
			sqrtPriceLimitX96: sqrtPriceLimitX96
		});

		// @dev: needs allowance, see "approveRouter"
		amountOut = swapRouter.exactInputSingle(params);
		emit TokenSwap(tkn0, tkn1, amountIn, amountOut);
	}

	// ---------------------------------------------------------------------------------------
	function swapExactOutputSingle(
		address tkn0,
		address tkn1,
		uint24 fee,
		uint256 amountOut,
		uint256 amountInMaximum,
		uint160 sqrtPriceLimitX96
	) external onlyAdminsOrExecutors returns (uint256 amountIn) {
		ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
			tokenIn: tkn0,
			tokenOut: tkn1,
			fee: fee,
			recipient: address(this),
			deadline: block.timestamp,
			amountOut: amountOut,
			amountInMaximum: amountInMaximum,
			sqrtPriceLimitX96: sqrtPriceLimitX96
		});

		// @dev: needs allowance, see "approveRouter"
		amountIn = swapRouter.exactOutputSingle(params);
		emit TokenSwap(tkn0, tkn1, amountIn, amountOut);
	}
}
