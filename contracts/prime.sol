pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Prime is ERC20 {
    uint initial_supply = 10000 * (10**18);

    constructor() ERC20("Prime", "PRI") {
        _mint(msg.sender, initial_supply);
    }
}