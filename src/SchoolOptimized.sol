pragma solidity ^0.8.30;

contract SchoolOptimized {
    //define studnets link
    mapping(address => address) nextStudents;
    mapping(address => uint256) scores;
    uint256 listSize;
    address immutable GUARD = address(1);
    
    constructor() {
        nextStudents[GUARD] = GUARD;
    }

    function addStudent(address prevStudent, uint256 value, address student) public {
        require(nextStudents[prevStudent] != address(0), 'prevStudent should not refer to 0');
        require(nextStudents[student] == address(0), 'studnet next should be address 0');
        require(_verifyIndex(prevStudent, value, nextStudents[prevStudent]), 'verify index failed');
        nextStudents[student] = nextStudents[prevStudent];
        nextStudents[prevStudent] = student;
        scores[student] = value;
        listSize++;

    }

    function addScore(address newPrevStudent, address oldPrevStudent, address student, uint256 value) public {
        updateScore(newPrevStudent, oldPrevStudent, student, scores[student] + value);
    }

    function decreaseScore(address newPrevStudent, address oldPrevStudent, address student, uint256 value) public {
        updateScore(newPrevStudent, oldPrevStudent, student, scores[student] - value);
    }

    function updateScore(address newPrevStudent, address oldPrevStudent, address student, uint256 newValue) public {
        require(nextStudents[newPrevStudent] != address(0));
        require(nextStudents[oldPrevStudent] != address(0));
        require(nextStudents[student] != address(0));

        if(oldPrevStudent == newPrevStudent) {
            _isPrevStudent(oldPrevStudent, student);
            _verifyIndex(oldPrevStudent, newValue, nextStudents[student]);
            scores[student] = newValue;
        } else {
            removeStudent(oldPrevStudent, student);
            addStudent(newPrevStudent, newValue, student);
        }
    }

    function removeStudent(address prevStudent, address student) public {
        require(nextStudents[prevStudent] != address(0));
        require(nextStudents[student] != address(0));
        require(_verifyIndex(prevStudent, scores[student], nextStudents[student]));
        nextStudents[prevStudent] = nextStudents[student];
        nextStudents[student] = address(0);
        listSize--;
    }

    function getTop(uint256 k) public view returns(address[] memory) {
        require((k <= listSize));
        address[] memory addressList = new address[](k);
        address currentAddress = nextStudents[GUARD];
        
        for(uint256 i = 0; i < k; i++) {
            addressList[i] = currentAddress;
            currentAddress = nextStudents[currentAddress];
        }
    }

    function _verifyIndex(address prevStudent, uint256 value, address nextStudent) internal view returns(bool){
        return (
            (prevStudent == GUARD || value <= scores[prevStudent]) &&
            (nextStudents[prevStudent] == GUARD || value > scores[nextStudent])
        );
    }

    function _isPrevStudent(address prevStudent, address student) internal view returns(bool) {
        return (
            nextStudents[prevStudent] == student
        );
    }


}

