//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract myEcommerceWebSite{

    //collecting product info of different DataTypes
    struct productInfo{
        string title;
        string desc;
        uint productId;
        uint price;
        address payable seller;
        address buyer;
        bool delivered;
    }

    // created product counter for seeting initial product ID and created an array of structs containing all products
    uint productIdCounter = 1;
    productInfo[] public productDatabase;

    // Events to trigger at every function called respectively
    event productRegistered(string title, uint productId, uint price, address seller);
    event productBought(uint productId, address buyer);
    event Delivered(uint productId);

    // when product is registered, values are tempoarily stored in tempProduct struct and than pushed directly into productDatabase and than an event is triggered to get required values
    function registerProduct(string memory _title, string memory _desc, uint _price) public {
        require(_price>0 , "PRICE SHOULD BE GREATER THAN ZERO");

        // METHOD # 1 : Without creating a temporary struct and pushing values directly into array
        address _buyer; bool _delivered;
        productDatabase.push(productInfo(_title, _desc, productIdCounter, _price* 10**18, 
        payable(msg.sender),_buyer,_delivered));
        productIdCounter++;
        emit productRegistered(_title, productDatabase[0].productId, _price, msg.sender);

        // METHOD # 2 :  By creating a temporary struct and pushing that temporary struct into array
        // productInfo memory tempProduct;
        // tempProduct.title = _title;
        // tempProduct.desc = _desc;
        // tempProduct.productId = productIdCounter;
        // tempProduct.price = _price * 10**18;
        // tempProduct.seller = payable(msg.sender);
        // productDatabase.push(tempProduct);
        // productIdCounter++;
        // emit productRegistered(_title, productDatabase[0].productId, _price, msg.sender);
    }

    // when product is bought, buyer is set into databse and respective event triggers to get required values
    function buyProduct(uint _productId) public payable{
        require(_productId>0, "Product ID cannot be 0 or less than 0");
        require(productDatabase[_productId-1].price==msg.value, "Please pay the exact price");
        require(productDatabase[_productId-1].seller!=msg.sender, "Seller cannot be the buyer");
        productDatabase[_productId-1].buyer = msg.sender;
        emit productBought(_productId, msg.sender);
    }

    //finally when product is delivered, buyer tells that product is delivered and amount is released to the seller and than event triggger and return the required value
    function productDelivered(uint _productId) public returns(bool){
        require(msg.sender==productDatabase[_productId-1].buyer, "Order can only be confirmed by the Buyer");
        productDatabase[_productId-1].delivered = true;
        productDatabase[_productId-1].seller.transfer(productDatabase[_productId-1].price);
        emit Delivered(_productId);
        return productDatabase[_productId-1].delivered;
    }   
}