export function storeDeployment(deployment: string) {
	const path: string = `${__dirname}/../ignition/deployments/${deployment}/`;
	const fileAddr = Object.values(require(path + 'deployed_addresses.json'));
	console.log(fileAddr);
}

storeDeployment('dep1');
