// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import '@openzeppelin/contracts/access/AccessControl.sol';

contract Membership is AccessControl {
	bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
	bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');

	// ---------------------------------------------------------------------------------------
	constructor(address admin, address executor) {
		_setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
		_setRoleAdmin(EXECUTOR_ROLE, ADMIN_ROLE);

		_setupRole(ADMIN_ROLE, admin);

		_setupRole(EXECUTOR_ROLE, admin);
		_setupRole(EXECUTOR_ROLE, executor);
	}
}
