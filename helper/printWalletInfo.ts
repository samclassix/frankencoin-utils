import { getChildFromSeed } from './wallet';

const seed = process.env.DEPLOYER_ACCOUNT_SEED;
if (!seed) throw new Error('Failed to import the seed string from .env');
console.log('seed:', seed);

const w0 = getChildFromSeed(seed, 0);
const w1 = getChildFromSeed(seed, 1);
const w2 = getChildFromSeed(seed, 2);

console.log('Wallet', 0);
console.log({
	address: w0.address,
	pubKey: w0.publicKey,
	privKey: w0.privateKey,
	path: w0.path,
	index: w0.index,
});

console.log('Wallet', 1);
console.log({
	address: w1.address,
	pubKey: w1.publicKey,
	privKey: w1.privateKey,
	path: w1.path,
	index: w1.index,
});

console.log('Wallet', 2);
console.log({
	address: w2.address,
	pubKey: w2.publicKey,
	privKey: w2.privateKey,
	path: w2.path,
	index: w2.index,
});
