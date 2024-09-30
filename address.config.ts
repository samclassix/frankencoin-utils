import { polygon } from 'viem/chains';
import { Address, zeroAddress } from 'viem';

export interface ChainAddress {
	LiquidityController: Address;
	NonFungiblePositionManager: Address;
	SwapRouter: Address;

	// accept any optional key
	[key: string]: Address | undefined;
}

export const ADDRESS: Record<number, ChainAddress> = {
	[polygon.id]: {
		LiquidityController: '0x8f48c02243dE42c06cC74FB39bF54aDb2402841D',
		NonFungiblePositionManager: '0xC36442b4a4522E871399CD717aBDD847Ab11FE88',
		SwapRouter: '0xE592427A0AEce92De3Edee1F18E0157C05861564',
	},
};
