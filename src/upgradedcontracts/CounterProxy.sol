//SPDX-License-Identifier: MIT

contract Counter {
    uint256 public num;

    function add(uint256 i) public {
        num += 1;
    }

    function get() public view returns(uint256) {
        return num;
    }

}

contract CounterV2 {
    uint256 public num;

    function add(uint256 i) public {
        num += i;
    }

    function getNum() public view returns(uint256) {
        return num;
    }
}

contract CounterProxy {
    uint256 public num;
    address impl;

    constructor(address impl_){
        impl = impl_;
    }

    function upgrade(address _impl) public {
        impl = _impl;
    }

        
    
    function add(uint256 i) public {
        bytes memory selectorAdd = abi.encodeWithSignature("add(uint256)", i);
        (bool success, ) = address(impl).delegatecall(selectorAdd);
        if(!success) revert("delegate call failed");
    }


    function getNum() public returns(uint256) {
        bytes memory selectorGetNum = abi.encodeWithSignature("get()");
        (bool success, bytes memory data) = address(impl).delegatecall(selectorGetNum);
        if(!success) revert("delegate call failed");
        (uint256 num) = abi.decode(data, (uint256));
        return num;
    }



}