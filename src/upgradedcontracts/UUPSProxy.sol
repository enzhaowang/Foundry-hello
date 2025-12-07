//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

library StorageSlot {
    struct AddressSlot{
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns(AddressSlot storage addressSlot) {
        assembly {
             addressSlot.slot := slot
        }
    }

    
}

contract Counter {
    bytes32 private constant implSlot = bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

    uint256 private counter;

    constructor() {
        counter = 1;
    }

    function init() public{
        counter = 1;
    }

    function add(uint256 i) public {
        counter += 1;
    }

    function get() public view returns(uint256){
        return counter;
    }

    function upgradeTo(address _impl) public {
        _setImplementation(_impl);
    }

    function _setImplementation(address _impl) private {
        require(_impl.code.length > 0, "implementation is not contract");
        StorageSlot.getAddressSlot(implSlot).value = _impl;
    }


}

contract CounterV2 {
    uint256 private counter;
    uint256 private counter1;

    function add(uint256 i) public {
        counter += i;
    }

    function add1(uint256 i) public {
        counter1 += i;
    }

    function get() public view returns(uint256){
        return counter;
    }

    function get1() public view returns(uint256){
        return counter1;
    }
}

contract UUPSProxy {
    constructor() {

    }

    function _delegate(address _implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    } 

    function _fallback() private{
        _delegate(_getImplementation());
    }

     fallback() external payable { _fallback(); }

     receive() external payable { _fallback();}


    function _getImplementation() private view returns(address){
        return StorageSlot.getAddressSlot(implSlot).value;
    }






}