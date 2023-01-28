//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract KnowledgeTest {
    string[] public tokens = ["BTC", "ETH"];
    address[] public players;

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable{}

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function transferAll(address payable _toAddress) external onlyOwner returns (bool) {
        uint balance = address(this).balance;
        (bool success, ) = _toAddress.call{value: balance}("");
        return success;
    }

    function changeTokens() public onlyOwner {
        tokens[0] = "VET";
    }

    function start() public {
        players.push(msg.sender);
    }

    function concatenate(string memory str1, string memory str2) external pure returns (string memory) {
           return string.concat(str1,str2);
    }

}

