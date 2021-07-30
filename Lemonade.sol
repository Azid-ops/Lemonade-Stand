pragma solidity 0.4.24;
contract LemonateStand
{
    address owner;
    uint Myval;
    
    enum State{ForSale,Sold,Shipped}
    
    struct Thing
    {
        string name;
        uint val;
        uint price;
        State state;
        address seller;
        address buyer;
    }
    
    mapping(uint=>Thing) test;
    
    event forSale(uint Myval);
    
    event Sold(uint val);
    
    event Shipped(uint val);
    
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    modifier verifyCaller(address _address)
    {
        require(msg.sender== _address);
        _;
    }
    
    modifier ForSale(uint _val)
    {
        require(test[_val].state == State.ForSale);
        _;
    }
    
    modifier paidEnough(uint _price)
    {
        require(msg.value>=_price);
        _;
    }
    
    modifier sold(uint _val)
    {
        require(test[_val].state == State.Sold);
        _;
    }
    
    modifier returnMoney(uint _val)
    {
        _;
        uint price = test[_val].price;
        uint refund = msg.value - price;
        test[_val].buyer.transfer(refund);
    }
    
    constructor()public payable
    {
        owner = msg.sender;
        Myval=0;
    }
    function addItem(string _name, uint _price) onlyOwner public
    {
        Myval += 1;
        emit forSale(Myval);
        test[Myval] = Thing({
            name:_name,
            val:Myval,
            price:_price,
            state:State.ForSale,
            seller:msg.sender,
            buyer:0
        });
    }
    
    function fetch(uint _val) public view returns(string _name,uint _myValue,uint _price,string _state,address _seller, address _buyer)
    {
        uint Newstate;
        _name = test[_val].name;
        _myValue = test[_val].val;
        _price = test[_val].price;
        Newstate = uint(test[_val].state);
        if(Newstate == 0)
        {
            _state = "ForSale";
        }
        if(Newstate == 1)
        {
            _state = "Sold";
        }
        if(Newstate == 2)
        {
            _state = "Shipped";
        }
        _seller =test[_val].seller;
        _buyer = test[_val].buyer;
    }
    
    function buyItem(uint _val) ForSale(_val) paidEnough(test[_val].price) returnMoney(_val) public payable
    {
        address buyer = msg.sender;
        uint price = test[_val].price;
        test[_val].buyer = buyer;
        test[_val].state = State.Sold;
        test[_val].seller.transfer(price);
        emit Sold(_val);
    }
    
    function Shipping(uint _val) sold(_val) verifyCaller(test[_val].seller) public
    {
        test[_val].state = State.Shipped;
        emit Shipped(_val);
    }
}
