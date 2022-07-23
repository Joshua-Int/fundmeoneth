// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Owner.sol";

/** 
 * @title CreateFund
 * @dev Implements creater fund donation
 */
contract CreatorFund is Owner {

    struct Creator {
        string[] tags;
        string photo; // personal info
        string description;
        string emailId;
        string website;
        string linkedIn; // social media
        string instagram;
        string twitter;
    }
    
    struct User {
        address payable walletAddress;
        string name;
        bool isDisabled; // disable user
        bool isCreator;
        uint totalFundContributorsCount;
        uint totalFundsReceived;
        uint totalCreatorsFundedCount;
        uint totalFundsSent;
        uint withdrawbleBalance;
    }

    mapping (address => mapping (address => uint))  public sentFundsList; // funds sent from wallet
    mapping (address => mapping (address => uint))  public receivedFundsList; // funds received in wallet
    mapping(address => User) public users;
    mapping(address => Creator) public creators;
    
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    function createUser(string memory _name) public returns (bool){
        address payable wallet = payable(msg.sender);
        users[msg.sender] = User(wallet,_name,false,false,0,0,0,0,0);
        return true;
    }

    function createOrUpdateCreator(
        string[] memory _tags,
        string memory _photo,
        string memory _description,
        string memory _emailId,
        string memory _website,
        string memory _linkedIn,
        string memory _instagram,
        string memory _twitter) public returns(bool)  {
        User storage myUser = users[msg.sender];
        myUser.isCreator = true;
        creators[msg.sender] = Creator(
            _tags,
            _photo,
            _description,
            _emailId,
            _website,
            _linkedIn,
            _instagram,
            _twitter
        );
        return true;
    }

    function donate(address payable _creator) public payable returns (bool){
        // require(msg.value >=minimumContribution,"Minimum Contribution is not met");
        require(users[_creator].isCreator == true,"User is not a Creator");
        require(users[_creator].isDisabled == false,"User is Disabled");
        require(msg.value > 0,"Donations cannot be below 0");
        if(sentFundsList[msg.sender][_creator]==0){
            users[msg.sender].totalCreatorsFundedCount++;
        }
        users[msg.sender].totalFundsSent+=msg.value;
        sentFundsList[msg.sender][_creator]+=msg.value;
        if(receivedFundsList[_creator][msg.sender]==0){
        users[_creator].totalFundContributorsCount++;
        }
        users[_creator].totalFundsReceived+=msg.value;
        receivedFundsList[_creator][msg.sender] +=msg.value;
        users[_creator].withdrawbleBalance +=msg.value;
        return true;
    }

    function withdraw(uint _withdrawAmount) public {
        uint actualWithdrawAmount = _withdrawAmount * 10 ** 18;
        require(users[msg.sender].withdrawbleBalance>actualWithdrawAmount, "requested amount is higher than the available then the withdrawAmount");
        User storage thisUser=users[msg.sender];
        thisUser.walletAddress.transfer(actualWithdrawAmount);
        thisUser.withdrawbleBalance-=actualWithdrawAmount;
    }

    function getCreatorInfo() public view returns (Creator memory){
        require(users[msg.sender].walletAddress != address(0), "No User Found");
        require(users[msg.sender].isCreator == true,"User is not a Creator");
        Creator memory myCreator = creators[msg.sender];
        return myCreator;
    }

    function getUserData() public view returns (User memory){
        require(users[msg.sender].walletAddress != address(0), "No User Found");
        User memory myUser = users[msg.sender];
        return myUser;
    }

    function disableUser(address _creator)  public isOwner returns(bool) {
        users[_creator].isDisabled = true;
        return true;
    }

} 