// SPDX-License-Identifier: MIT
pragma abicoder v2;
pragma solidity ^0.7.6;

import "hardhat/console.sol";
import "./bytesUtils/Bytes.sol";

/**
 * @title Arbiter
 * @dev A super simple ERC20 implementation!
 */
contract Arbiter is Bytes{
    //xxl Done
    uint256 public constant ARBITER_NUM = 12;
    // using Bytes for bytes;
    function getTokenIDByTxhash(bytes32 _elaHash) public view returns (uint256) {
            uint selector = 1004;
            uint offSet = 32;
            bytes memory result;
            uint256 inputSize = 0;
            uint256 leftGas = gasleft();

            bytes memory input = toBytes(_elaHash);
            inputSize = input.length + offSet;
            assembly {
                let resultSize := 32
                result := mload(0x40)
                mstore(0x40, add(result, resultSize))
                if iszero(staticcall(leftGas, selector, input, inputSize, result, resultSize)) {
                    revert(0,0)
                }
                let actualSize := returndatasize()
                mstore(result, actualSize)
                if eq(actualSize, 31) {//because return data is bigint, if front byte is 0, will delete, if copy 32 bytes, the 0 is will fill in end
                    returndatacopy(add(result, 33), 0, actualSize)
                } 
                if eq(actualSize, 32){
                    returndatacopy(add(result, 32), 0, actualSize)
                }
                
            }
            uint256 tokenID;
            assembly {
                tokenID := mload(add(result, 32))
            }
            return tokenID;
    }

    function getBPosNFTPayloadVersion(bytes32 _elaHash) public view returns (uint256) {
        uint method = 1006;
        uint offSet = 32;
        uint outputSize = 32;
        uint256[1] memory result;
        uint256 inputSize = 0;
        uint256 leftGas = gasleft();

        bytes memory input = toBytes(_elaHash);
        inputSize = input.length + offSet;
        assembly {
            if iszero(staticcall(leftGas, method, input, inputSize, result, outputSize)) {
                revert(0,0)
            }
        }
        return result[0];
    }

    function getBPosNFTInfo(bytes32 _elaHash) public view returns(bytes32, string memory, bytes32, uint32,uint32,int64,int64,bytes memory) {
        bytes32[100] memory result;
        uint256 inputSize = 0;

        bytes memory input = toBytes(_elaHash);
        inputSize = input.length + 32;
        assembly {
            if iszero(staticcall(gas(), 1005, input, inputSize, result, 3200)) {
                revert(0,0)
            }
        }

        bytes memory data = new bytes(0);
        uint i = 0;
        bytes memory a;
        for  (i = 0; i< result.length; i++) {
            a = toBytes(result[i]);
            data = concat(data, a);
        }
        return abi.decode(data, (bytes32, string, bytes32, uint32, uint32, int64, int64, bytes));
    }

    //uint256 constant public ARBITER_NUM = 3;
    function isArbiterInList(bytes32 arbiter) internal view returns (bool) {
        bytes32[ARBITER_NUM] memory arbiterList = getArbiterList();

        for (uint256 i = 0; i < ARBITER_NUM; i++) {
            if (arbiter == arbiterList[i]) {
                return true;
            }
        }

        return false;
    }

    function getArbiterList()
        public
        view
        returns (bytes32[ARBITER_NUM] memory)
    {
        bytes32[ARBITER_NUM] memory p;
        uint256 input;
        assembly {
            if iszero(staticcall(gas(), 1000, input, 0x00, p, 384)) {
                revert(0, 0)
            }
        }
        return p;
    }

    function pledgeBillVerify(
        bytes32 _elaHash,
        address _to,
        bytes[] memory _signature,
        bytes[] memory _publicKey,
        uint256 multi_m
    ) public view returns (uint) {
        uint256[1] memory result;
        uint256 inputSize = 0;
        uint256 leftGas = gasleft();

        bytes memory multi_n = toBytes(_publicKey.length);
        bytes memory elaHash = toBytes(_elaHash);
        bytes memory input = concat(elaHash, toBytes(_to));
        input = concat(input, multi_n);
        input = concat(input, toBytes(multi_m));
        input = concat(input, toBytes(_signature.length));
        uint i;
        for(i = 0; i < _publicKey.length; i++) {
            input = concat(input, _publicKey[i]);
        }
        for(i = 0; i < _signature.length; i++) {
            input = concat(input, _signature[i]);
        }

        inputSize = input.length + 32;
        assembly {
            if iszero(staticcall(leftGas, 1003, input, inputSize, result, 32)) {
                revert(0,0)
            }
        }
        return result[0];
    }

    function hexStr2bytes(string memory _data)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory a = bytes(_data);
        uint8[] memory b = new uint8[](a.length);

        for (uint256 i = 0; i < a.length; i++) {
            uint8 _a = uint8(a[i]);

            if (_a > 96) {
                b[i] = _a - 97 + 10;
            } else if (_a > 66) {
                b[i] = _a - 65 + 10;
            } else {
                b[i] = _a - 48;
            }
        }

        bytes memory c = new bytes(b.length / 2);
        for (uint256 _i = 0; _i < b.length; _i += 2) {
            c[_i / 2] = bytes1(b[_i] * 16 + b[_i + 1]);
        }

        return c;
    }

}
