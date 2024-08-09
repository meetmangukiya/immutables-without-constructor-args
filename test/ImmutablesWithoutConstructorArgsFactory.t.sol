pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ImmutablesWithoutConstructorArgsFactory} from "src/ImmutablesWithoutConstructorArgsFactory.sol";
import {console} from "forge-std/console.sol";

contract ImmutablesWithoutConstructorArgs {
    address public immutable addr;
    uint public immutable num;

    constructor() payable {
        bytes memory initData = ImmutablesWithoutConstructorArgsFactory(msg.sender).getInitData();
        (address addr_, uint num_) = abi.decode(initData, (address, uint));
        addr = addr_;
        num = num_;
    }
}

contract ImmutablesWithoutConstructorArgsFactoryTest is Test {
    ImmutablesWithoutConstructorArgsFactory factory;

    function setUp() external {
        factory = new ImmutablesWithoutConstructorArgsFactory();
    }

    function testCreate(address addr, uint num, uint value) external {
        bytes memory initData = abi.encode(addr, num);
        bytes memory initCode = type(ImmutablesWithoutConstructorArgs).creationCode;
        vm.deal(address(this), value);
        address deployedAddr = factory.create{value: value}(initCode, initData);
        assertEq(ImmutablesWithoutConstructorArgs(deployedAddr).addr(), addr, "addr not initialized correctly");
        assertEq(ImmutablesWithoutConstructorArgs(deployedAddr).num(), num, "num not initialized correctly");
        assertEq(deployedAddr.balance, value, "balance not as expected");
    }

    function testCreate2(address addr, uint num, uint value, bytes32 salt) external {
        bytes memory initData = abi.encode(addr, num);
        bytes memory initCode = type(ImmutablesWithoutConstructorArgs).creationCode;
        vm.deal(address(this), value);
        address deployedAddr = factory.create2{value: value}(initCode, initData, salt);
        assertEq(ImmutablesWithoutConstructorArgs(deployedAddr).addr(), addr, "addr not initialized correctly");
        assertEq(ImmutablesWithoutConstructorArgs(deployedAddr).num(), num, "num not initialized correctly");
        assertEq(deployedAddr.balance, value, "balance not as expected");
    }
}
