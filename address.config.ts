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
		LiquidityController: '0x10A0DDB46361b3F1d6405eFffc1Db96771bAb85F',
		NonFungiblePositionManager: '0xC36442b4a4522E871399CD717aBDD847Ab11FE88',
		SwapRouter: '0xE592427A0AEce92De3Edee1F18E0157C05861564',

		zchf: '0x02567e4b14b25549331fCEe2B56c647A8bAB16FD',
		usdt: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
	},
};
