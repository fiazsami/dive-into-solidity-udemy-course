//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract Lottery {
    uint MIN_ENTRY_PRICE = 100000000000000000;

    // declaring the state variables
    address[] private players; //dynamic array of type address payable
    address[] private gameWinners;
    address private owner;

    // used to ensure only one address is entered
    mapping(address => bool) private currentPlayers;
    
    // mutex variable
    bool private isPicking;

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }


    modifier canPlay() {
        bool notEnoughPlayers = players.length < 3;
        require(!notEnoughPlayers, "NOT_ENOUGH_PLAYERS");
        require(!isPicking);
        _;
    }


    modifier singleEntry() {
        require(!currentPlayers[msg.sender], "CANNOT_ENTER_2x");
        currentPlayers[msg.sender] = true;
        _;
    }


    modifier minEntryPrice() {
        require(msg.value == MIN_ENTRY_PRICE);       
        _;
    }



    // declaring the constructor
    constructor() {
        owner = msg.sender;
    }


    // declaring the receive() function that is necessary to receive ETH
    receive() external payable minEntryPrice singleEntry {
        players.push(msg.sender);
    }


    // returning the contract's balance in wei
    function getBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }


    // selecting the winner
    function pickWinner() public onlyOwner canPlay returns (bool) {
        isPicking = true;

        uint256 r = random();
        uint256 selected = r  % players.length;
        address winner = players[selected];

        gameWinners.push(winner);
        uint balance = address(this).balance;    
        (bool success, ) = winner.call{value: balance}("");

        resetGame();

        return success;
    }


    function resetGame() private {
        for (uint i ; i < players.length ; i++) {
            delete currentPlayers[players[i]];   
        }
        delete players;

        isPicking = false;
    }


    function getPlayer(uint index) external view returns (address) {
        return players[index];
    }


    function getWinner(uint index) external view returns (address) {
        return gameWinners[index];
    }


    function getPlayerCount() external view returns(uint count) {
        return players.length;
    }


    // helper function that returns a big random integer
    // UNSAFE! Don't trust random numbers generated on-chain, they can be exploited! This method is used here for simplicity
    // See: https://solidity-by-example.org/hacks/randomness
    function random() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            );
    }
}
