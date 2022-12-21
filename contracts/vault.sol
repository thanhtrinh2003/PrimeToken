pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./pusd.sol";

contract Vault is Ownable {

    // this will be inputted later 
    address public PRIME_address;
    address public PUSD_address;

    constructor(address _PRIME_address, address _PUSD_address) {
        PRIME_address = _PRIME_address;
        PUSD_address= _PUSD_address;
    }

    struct vaultItems {
        uint256 amount;
        uint256 interestAmount;
        uint256 lastestTimeStamp;
    }

    uint256 public depositCount;
    mapping(address => vaultItems) public depositTokens;

    event Deposit(address withdrawer, uint256 amount);
    event Withdraw(address withdrawer, uint256 amount);
    
    function deposit(address _withdrawer, uint256 _amount) external {
        require(_withdrawer == msg.sender, "You are not the one who withdraw!");
        require(IERC20(PRIME_address).balanceOf(_withdrawer) >= _amount, "Your token amount must be greater than the amount you are depositing!");
        require(IERC20(PRIME_address).approve(address(this), _amount));
        require(IERC20(PRIME_address).transferFrom(_withdrawer, address(this), _amount));

        //updating interest amount
        uint256 cycle = (block.timestamp - depositTokens[_withdrawer].lastestTimeStamp)/((365 * 24 * 60 * 60));
        for (uint i=0; i <cycle; i++) {
            depositTokens[_withdrawer].interestAmount += (depositTokens[_withdrawer].amount)/100;
        }

        if(depositTokens[_withdrawer].lastestTimeStamp == 0) {
            depositTokens[_withdrawer].lastestTimeStamp = block.timestamp;
        } else {
             depositTokens[_withdrawer].lastestTimeStamp += cycle * 365 * 24 * 60 * 60;
        }
        
        depositTokens[_withdrawer].amount += _amount;

        emit Deposit(_withdrawer, _amount);
    }

    function withdrawAll(address _withdrawer) external {
        require(_withdrawer == msg.sender, "You are not the one who withdraw!");
        
        //updating interest amount
        uint256 cycle = (block.timestamp - depositTokens[_withdrawer].lastestTimeStamp)/((365 * 24 * 60 * 60));
        for (uint i=0; i <cycle; i++) {
            depositTokens[_withdrawer].interestAmount += (depositTokens[_withdrawer].amount)/100;
        }

        if(depositTokens[_withdrawer].lastestTimeStamp == 0) {
            depositTokens[_withdrawer].lastestTimeStamp = block.timestamp;
        } else {
             depositTokens[_withdrawer].lastestTimeStamp += cycle * 365 * 24 * 60 * 60;
        }
        
        uint256 totalTokensAmount = depositTokens[_withdrawer].amount + depositTokens[_withdrawer].interestAmount;
        require(totalTokensAmount > 0, "User does not have any tokens left in vaults!");

        require(IERC20(PRIME_address).transfer(msg.sender, depositTokens[_withdrawer].amount), "the transfer failed");
        require(IERC20(PUSD_address).transfer(msg.sender, depositTokens[_withdrawer].interestAmount), "the transfer failed");
        
        depositTokens[_withdrawer].amount = 0;
        depositTokens[_withdrawer].interestAmount = 0;
        depositTokens[_withdrawer].lastestTimeStamp = block.timestamp;

        emit Withdraw(_withdrawer, totalTokensAmount);
    }

    function withdrawInterest(address _withdrawer) external {
        require(_withdrawer == msg.sender, "You are not the one who withdraw!");
       
       //updating interest amount
        uint256 cycle = (block.timestamp - depositTokens[_withdrawer].lastestTimeStamp)/((365 * 24 * 60 * 60));
        for (uint i=0; i <cycle; i++) {
            depositTokens[_withdrawer].interestAmount += (depositTokens[_withdrawer].amount)/100;
        }

        if(depositTokens[_withdrawer].lastestTimeStamp == 0) {
            depositTokens[_withdrawer].lastestTimeStamp = block.timestamp;
        } else {
             depositTokens[_withdrawer].lastestTimeStamp += cycle * 365 * 24 * 60 * 60;
        }

        require(depositTokens[_withdrawer].interestAmount > 0, "User does not have any tokens left in vaults!");
        require(IERC20(PUSD_address).transfer(msg.sender, depositTokens[_withdrawer].interestAmount), "the transfer failed");
        
        depositTokens[_withdrawer].interestAmount = 0;

        emit Withdraw(_withdrawer, depositTokens[_withdrawer].interestAmount);
    }

    function depositAmount(address _withdrawer) external view returns (uint256){
        return depositTokens[_withdrawer].amount;
    }

    function depositInterestAmount(address _withdrawer) external view returns (uint256){
        return depositTokens[_withdrawer].interestAmount;
    }

    function depositTotalAmount(address _withdrawer) external view returns (uint256){
        return depositTokens[_withdrawer].amount + depositTokens[_withdrawer].interestAmount;
    }

}
