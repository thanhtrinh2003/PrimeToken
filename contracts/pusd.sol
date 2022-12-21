pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PUSD is ERC20, Ownable {

    uint initial_supply = 10000 * (10**18);

    constructor() ERC20("Prime USD", "PUSD") {
        _mint(msg.sender, initial_supply);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}