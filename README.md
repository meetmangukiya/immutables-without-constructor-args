# `immutables-without-constructor-args`

Oftentimes it is desirable to not have constructor args, or only to have static
constructor args which could technically be replaced by using constants directly.

Two major reasons are:
1. Factory spawned contracts without constructor args don't get automatically verified.
2. You are trying to create a `create2` 1:1 mapped contracts for users. If you add constructor args
   that will change the init code and you might not be able to enforce 1:1 mapping even if you use
   a salt that is derived from user address.

At the same time immutables are very useful for gas optimizations. This project demonstrates how
we can do both of these things, remove constructor args, but still have dynamic deploy time parameters
that can be used to initialize the immutables.

## How?

We create a factory contract that will allow to call `create` and `create2` with given init data and salts.
We also take an additional parameter `initData` which is what you'd have put in constructor args in normal
ways of writing solidity. But here, what we do is we store the initData in transient storage and expose the
same via a view function `getInitData` that lives for the duration of contract initialization. The contract
can then read the constructor args using that view function and decode it and initialize the contrat immutable
variables.

Following is an example of how you might do that.

```solidity
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
```

See the [factory](./src/ImmutablesWithoutConstructorArgsFactory.sol) and
[example contract](./test/ImmutablesWithoutConstructorArgsFactory.t.sol) here.

Tests:

```sh
$ forge test -vvv
...
Ran 2 tests for test/ImmutablesWithoutConstructorArgsFactory.t.sol:ImmutablesWithoutConstructorArgsFactoryTest
[PASS] testCreate(address,uint256,uint256) (runs: 257, μ: 99157, ~: 99236)
[PASS] testCreate2(address,uint256,uint256,bytes32) (runs: 257, μ: 99298, ~: 99429)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 19.55ms (27.48ms CPU time)

Ran 1 test suite in 168.97ms (19.55ms CPU time): 2 tests passed, 0 failed, 0 skipped (2 total tests)
```
