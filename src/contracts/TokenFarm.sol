pragma solidity ^0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenFarm {
    string public name = "Dapp Token Farm";
    DappToken public dappToken;
    DaiToken public daiToken;

    address public owner;
    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    constructor(DappToken _dappToken, DaiToken _daiToken) public {
        dappToken = _dappToken;
        daiToken = _daiToken;
        owner = msg.sender;
    }

    //stake tokens (deposit)
    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "Amount cannot be 0");

        daiToken.transferFrom(msg.sender, address(this), _amount);

        stakingBalance[msg.sender] = stakingBalance[msg.sender] + _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }

        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true;
    }

    //unstake tokens (withdraw)
    function unstakeTokens() public {
        uint balance = stakingBalance[msg.sender];

        require(balance > 0, "Staking balance cannot be 0");

        daiToken.transfer((msg.sender), balance);

        stakingBalance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    //issuing tokens
    function issueTokens() public {
        //only the owner can call, (address that created contract)
        require(msg.sender == owner, "Caller must be the owner");

        for (uint256 i = 0; i < stakers.length; i++) {
            //for each person who's staked within the Dapp
            address recipient = stakers[i];
            //get their balance staked
            uint256 balance = stakingBalance[recipient];
            //send them same amount of mDAI
            if (balance > 0) {
                dappToken.transfer(recipient, balance);
            }
        }
    }
}
