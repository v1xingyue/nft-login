pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts@4.8.0/token/ERC1155/ERC1155.sol";

contract Sample {
    // 0,1,2
    enum State {
        Working,
        Ready,
        Active
    }

    struct Person {
        string firstName;
        string secondName;
    }

    Person[] public people;

    uint256 public peopleCount;

    State public state;
    string message;
    bool public myBool = true;
    int256 public myInt = -1238;
    uint256 public myUint = 25555;
    int8 public myUint8 = 8;

    address owner;

    string public constant notChangeValue = "this is never changed.";

    // 不存在的key 会返回默认值
    mapping(string => Person) public namedPerson;

    modifier onlyOwner() {
        require(msg.sender == owner);
        // 空函数体
        _;
    }

    constructor() {
        message = "hello world";
        owner = msg.sender;
    }

    // 获得某个token 拥有的数额
    function getTokenBalance(address _contractAddr, uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        ERC1155 token = ERC1155(_contractAddr);
        return token.balanceOf(msg.sender, _tokenId);
    }

    function get() public view returns (string memory) {
        return message;
    }

    function set(string calldata _value) public {
        message = _value;
    }

    function changeState() public {
        state = State.Working;
    }

    function addPerson(string memory firstName, string memory secondName)
        public
        onlyOwner
    {
        people.push(Person(firstName, secondName));
        // peopleCount += 1;
        privateFunction();
    }

    function addNamedPerson(string memory firstName, string memory secondName)
        public
    {
        namedPerson[firstName] = Person(firstName, secondName);
    }

    function privateFunction() internal {
        peopleCount += 1;
    }
}
