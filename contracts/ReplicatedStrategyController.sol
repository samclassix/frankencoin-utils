// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import './Membership.sol';

struct MemberInfo {
	uint256 id;
	address depositEth;
	string depositBtc;
}

contract ReplicatedStrategyController is AccessControl {
	bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
	bytes32 public constant EXECUTOR_ROLE = keccak256('EXECUTOR_ROLE');
	bytes32 public constant MEMBER_ROLE = keccak256('MEMBER_ROLE');

	mapping(address member => MemberInfo) public info;
	mapping(address token => bool) public isDepositToken;

	// ---------------------------------------------------------------------------------------
	modifier onlyExecutors() {
		require(hasRole(EXECUTOR_ROLE, msg.sender) == true, 'No Executor');
		_;
	}
	modifier onlyMembers() {
		require(hasRole(MEMBER_ROLE, msg.sender) == true, 'No Member');
		_;
	}

	// ---------------------------------------------------------------------------------------
	event DepositToken(address token, bool usable);
	event MemberRegistered(address member, address executor);
	event DepositAndSwap(address member, address token, uint256 amount, uint32 swapPrice);

	error NothingChanged();
	error AlreadyRegistered();
	error NotDepositToken();

	// ---------------------------------------------------------------------------------------
	constructor(address admin, address _usdc, address _usdt) {
		_setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
		_setRoleAdmin(EXECUTOR_ROLE, ADMIN_ROLE);
		_setRoleAdmin(MEMBER_ROLE, EXECUTOR_ROLE);

		_grantRole(ADMIN_ROLE, admin);
		_grantRole(EXECUTOR_ROLE, msg.sender);

		_setDepositToken(_usdc, true);
		_setDepositToken(_usdt, true);
	}

	// ---------------------------------------------------------------------------------------
	function setDepositToken(address token, bool usable) public onlyExecutors {
		_setDepositToken(token, usable);
	}

	function _setDepositToken(address token, bool usable) internal {
		if (isDepositToken[token] == usable) revert NothingChanged();
		isDepositToken[token] = usable;
		emit DepositToken(token, usable);
	}

	// ---------------------------------------------------------------------------------------
	function registerMember(address _newMember, uint256 _id, address _depositEth, string calldata _depositBtc) public onlyExecutors {
		if (info[_newMember].id != 0) revert AlreadyRegistered();
		info[_newMember].id = _id;
		info[_newMember].depositEth = _depositEth;
		info[_newMember].depositBtc = _depositBtc;
		grantRole(MEMBER_ROLE, _newMember);
		emit MemberRegistered(_newMember, msg.sender);
	}

	// ---------------------------------------------------------------------------------------
	function depositAndSwap(address token, uint256 amount, uint32 swapPrice) public onlyMembers {
		if (isDepositToken[token] == false) revert NotDepositToken();
		ERC20(token).transferFrom(msg.sender, info[msg.sender].depositEth, amount); // @dev: needs correct allowance "depositEth"
		emit DepositAndSwap(msg.sender, token, amount, swapPrice);
	}
}
