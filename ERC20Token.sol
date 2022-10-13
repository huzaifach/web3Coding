//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

abstract contract myERC20Standard{

    // SETTING ERC20 STANDARDS for my coin
    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);

    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address _owner) public view virtual returns (uint256 balance);
    function transfer(address _to, uint256 _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
    function allowance(address _owner, address _spender) public view virtual returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract setOwner{
    
    address public owner;
    address public newOwner;

    event transferOwnership(address indexed owner, address indexed newOwner);

    // HERE we set the owner of our contract
    constructor (){
        owner = msg.sender; 
    }
     // HERE we change owner, if needed
    function chnageOwner(address _to) public {
        require (msg.sender == owner, "Ownership can only be changed by Real Owner of this contract");
        newOwner = _to;
    }

    // HERE new owner selected by original owner accepts the ownership of this contract 
    function accpetOwnership() public {
        require(msg.sender == newOwner, "Ownership can only be accepted by new Owner");
        emit transferOwnership(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    // what is line 28 and 45 doing here?? can we do it without indexing??
}

contract myERC20Token is setOwner , myERC20Standard {

    // declaring state variables 

    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint public _totalSupply;
    address public _minter;

    mapping(address => uint) tokenBalance;
    mapping(address => mapping ( address => uint )) allowedAddresses;

    // initializing state variables 
    constructor (address coinMinter){
        _name = "Islamic Coin";
        _symbol = "ISC";
        _totalSupply = 10000000000;
        _minter = coinMinter;
        tokenBalance[_minter] = _totalSupply; 
    }

    // CHECKING VALUES OF STATE VARIABLES USING ERC20 STANDARD FUNCTIONS 
    function name() public view override returns (string memory){
        return _name;
    }

    function symbol() public view override returns (string memory){
        return _symbol;
    }

    function decimals() public view override returns (uint8){
        return _decimals;
    }

    function totalSupply() public view override returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view  override returns (uint256 balance){
        return tokenBalance[_owner];
    }


    // We allow minter to transfer tokens to some other user/Address
    function transfer(address _to, uint256 _value) public  override returns (bool success){
        require(tokenBalance[msg.sender] >= _value, "Insufficient Tokens");
        tokenBalance[msg.sender] -= _value;
        tokenBalance[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // We allow third party to tranfer our tokens on our behalf to some other user/Address 
    function transferFrom(address _from, address _to, uint256 _value) public  override returns (bool success){
        uint allowedBalance = allowedAddresses[_from][msg.sender];
        require(_value <= allowedBalance , "Insufficient Balance");
        emit Transfer( _from, _to, _value);
        return true;
    }

    // We allow users how much of the available tokens he/she can use/spend
    function approve(address _spender, uint256 _value) public  override returns (bool success){
        require(tokenBalance[msg.sender] >= _value, "Insufficient Tokens");
        allowedAddresses[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // We check limit of how much tokes are allowed to be spent by a particular user by owner
    function allowance(address _owner, address _spender) public view  override returns (uint256 remaining){
        return allowedAddresses[_owner][_spender];
    }

}