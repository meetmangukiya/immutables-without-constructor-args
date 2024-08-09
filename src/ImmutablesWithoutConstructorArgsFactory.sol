pragma solidity ^0.8.24;

contract ImmutablesWithoutConstructorArgsFactory {
    modifier withInitData(bytes calldata initData) {
        assembly ("memory-safe") {
            let initDataLen := initData.length
            tstore(0, initDataLen)
            let nWords := div(add(initDataLen, 31), 32)
            for { let i := 0 } lt(i, nWords) { i := add(i, 1) } {
                tstore(add(i, 1), calldataload(add(initData.offset, mul(i, 0x20))))
            }
        }
        _;
        assembly ("memory-safe") {
            // restore the length
            tstore(0, 0)
        }
    }

    function create(bytes calldata initCode, bytes calldata initData)
        external
        payable
        withInitData(initData)
        returns (address addr)
    {
        assembly ("memory-safe") {
            let freePtr := mload(0x40)
            calldatacopy(freePtr, initCode.offset, initCode.length)
            addr := create(callvalue(), freePtr, initCode.length)
        }
    }

    function create2(bytes calldata initCode, bytes calldata initData, bytes32 salt)
        external
        payable
        withInitData(initData)
        returns (address addr)
    {
        assembly ("memory-safe") {
            let freePtr := mload(0x40)
            calldatacopy(freePtr, initCode.offset, initCode.length)
            addr := create2(callvalue(), freePtr, initCode.length, salt)
        }
    }

    function getInitData() external view returns (bytes memory) {
        assembly ("memory-safe") {
            let nBytes := tload(0)
            // store the offset
            mstore(0x00, 0x20)
            // store the length
            mstore(0x20, nBytes)
            let nWords := div(add(nBytes, 31), 0x20)
            let destOffset := 0x40
            for { let i := 0 } lt(i, nWords) { i := add(i, 1) } {
                // store nth word
                mstore(destOffset, tload(add(i, 1)))
                destOffset := add(destOffset, 0x20)
            }
            return(0, destOffset)
        }
    }
}
