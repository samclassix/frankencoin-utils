import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
import { Address, zeroAddress } from 'viem';
import { INonfungiblePositionManager } from '../../exports/INonfungiblePositionManager';
import { ISwapRouter } from '../../exports/ISwapRouter';
import { getChildFromSeed } from '../../helper/wallet';
import { ADDRESS } from '../../address.config';
import { polygon } from 'viem/chains';

const seed = process.env.DEPLOYER_ACCOUNT_SEED;
if (!seed) throw new Error('Failed to import the seed string from .env');

const w0 = getChildFromSeed(seed, 0);
const w1 = getChildFromSeed(seed, 1);
const w2 = getChildFromSeed(seed, 2);

console.log('Info');
console.log({
	deployer: w0.address,
	admin: w1.address,
	executor: w2.address,
});

const manager: Address = ADDRESS[polygon.id].NonFungiblePositionManager;
const router: Address = ADDRESS[polygon.id].SwapRouter;
if (manager.length < 20 || router.length < 20) throw new Error('Check imported addresses for manager and router');

// constructor args
export const args = [manager, router, w1.address, w2.address];
console.log('Constructor Args');
console.log(args);

const LiquidityControllerModule = buildModule('LiquidityControllerModule', (m) => {
	const controller = m.contract('LiquidityController', [manager, router, w1.address, w2.address]);
	return { controller };
});

export default LiquidityControllerModule;
