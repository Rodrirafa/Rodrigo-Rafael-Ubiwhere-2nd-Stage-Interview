// version
pragma solidity >=0.4.16 <0.6.6;

/// @author Rodrigo Rafael 
/// 23/04/2020

/// @title This contract allows several users to have a sigwallet for 
/// sending ether to a specified address after 50% of the votes are in
contract VotingTransfer{
    // constant for the percentage to be applied to the percentage field
    uint256 private constant PERCENTAGE_APPLIED = 50;
    // address to which the funds will be sent to when the contract triggers
    address payable public constant recipient = 0x357573E1b99293Bc09b7392B560b3C336c22690C;
    
    mapping(address => bool) hasPaid; // mapping for verification of payment
    mapping(address => bool) hasVoted; // mapping for verifcation of vote
    mapping(address => bool) isOwner;  // mapping for verification of ownership
    // defines the maximum ammount of participants to be able to vote and send ether
    uint256 private max_participants;
    // number between 0-100, defines the percentage of votes needed for the contract to send ether to the specified address
    uint256 private percentage;
    // current ammount of votes
    uint256 public ammountVotes;
    // address of the creator
    address public creator;
    // array of owners
    address[] owners;
    // the address of the contract
    address public self;
    
    modifier fromSelf() {
        require(msg.sender == address(this));
        _;
    }
    modifier maxParticipants(){
        require(owners.length < maxParticipants);
        _;
    }
    modifier _hasPaid(address _address){
        require(hasPaid[_address]);
        _;
    }
    
    
    modifier _hasVoted(address _address){
        require(hasVoted[_address]);
        _;
    }
    
    modifier _isOwner(address _address){
        require(isOwner[_address]);
        _;
    }
    
    modifier isntOwner(address _address){
        require(!isOwner[_address]);
        _;
    }
    
    /// @param max_participants number of maximum participants / owners of the contract
    constructor(uint256 _max_participants) public {
        max_participants = _max_participants;
        percentage = PERCENTAGE_APPLIED;
        creator = msg.sender;
        self = address(this);
    }
    
    /// @dev adds an owner
    ///@param owner the owner that is to be added to the list of owners
    function addOwner(address owner)
        public
        //fromSelf()
        isntOwner(owner)
        maxParticipants
    {
        isOwner[owner] = true;
        owners.push(owner);
    }
    
    /// @dev removes an owner
    ///@param owner the owner that is to be removed from the list of owners
    function removeOwner(address owner)
        public
        fromSelf()
        _isOwner(owner)
    {
        if(hasVoted[owner] == true)
        {
            ammountVotes--;
        }
        hasPaid[owner] = hasVoted[owner] = isOwner[owner] = false;
        for(uint256 i = 0; i < owners.length - 1; i++){
            if(owners[i] == owner)
            {
                //putting the last address of the array on current position
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
    }
    
    /// @dev allows deposit of ether
    function deposit() 
        public 
        payable 
        _isOwner(msg.sender) 
    {
        hasPaid[msg.sender] = true;
    }
    
    /// @dev function to vote for the tranfer of ether from this contract to
    /// a certain address 
    function vote() 
        public 
        _isOwner(msg.sender) 
        _hasPaid(msg.sender) 
    {
        hasVoted[msg.sender] = true;
        ammountVotes++;
        if(ammountVotes >= (max_participants * percentage/100)){
            triggersend();
        }
    }
    
    /// @dev function to "unvote" (remove one's vote) for the tranfer of ether
    /// from this contract to a certain address 
    function unvote() 
        public 
        _isOwner(msg.sender) 
        _hasPaid(msg.sender) 
        _hasVoted(msg.sender)
    {
        hasVoted[msg.sender] = false;
        ammountVotes--;
    }
    
    /// @dev returns the balance of this contract
    function balance() 
        public 
        view 
        returns(uint256) 
    {
        return address(this).balance;
    }
    
    /// @dev function for the trigger when 50% of the votes are payment
    /// sends ether to the recipient
    function triggersend() private {
        
        recipient.transfer(address(this).balance);
        resetmappings();
        ammountVotes = 0;
    }
    
    
    ///@dev function for putting all mappings values to false
    function resetmappings() private {
        for(uint256 i = 0; i < owners.length; i++)
        {
            hasVoted[owners[i]] = false;
            hasPaid[owners[i]] = false;
        }
    }
}