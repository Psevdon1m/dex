pragma solidity ^0.4.13;


import "./Owned.sol";
import "./FixedSupplyToken.sol";


contract Exchange is Owned {

    ///////////////////////
    // GENERAL STRUCTURE //
    ///////////////////////
    struct Offer {

        uint256 amount;
        address who;
    }

    struct OrderBook {

        uint256 higherPrice;
        uint256 lowerPrice;

        mapping (uint => Offer) offers;

        uint256 offers_key;
        uint256 offers_length;
    }

    struct Token {

        address tokenContract;
        string symbolName;

        mapping(uint256 => OrderBook) buyBook;
        uint256 curBuyPrice;
        uint256 lowestBuyPrice;
        uint256 amountBuyPrices;

        mapping(uint256 => OrderBook) sellBook;
        uint256 curSellPrice;
        uint256 highestSellPrice;
        uint256 amountSellPrices;
     }

    event tokenAddedToSystem(uint _SymbolIndex, string _token, uint _timestamp);

     //Deposit/Withdrawal events
    event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint amount, uint _timestamp);
    event WitdhrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event DepositForEthReceived( address indexed _from, uint _amount, uint _timestamp);
    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

    //Trading events
    event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokensm, uint _priceInWei, uint _orderKey);
    event SellOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
    event SellOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);

    event LimitBuyOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountToken, uint _priceInWei, uint _orderKey);
    event BuyOrderFulfilled(uint indexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
    event BuyOrderCanceled(uint indexed _symbolIndex, uint _priceInWei, uint _orderKey);



    //we support a max of 255 tokens...
    mapping (uint8 => Token) tokens;
    uint8 symbolNameIndex;


    //////////////
    // BALANCES //
    //////////////
    mapping (address => mapping (uint8 => uint)) tokenBalanceForAddress;

    mapping (address => uint) balanceEthForAddress;




    ////////////
    // EVENTS //
    ////////////




    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL ETHER //
    //////////////////////////////////
    function depositEther() payable {
        require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] += msg.value;
        DepositForEthReceived(msg.sender, msg.value, now);

    }

    function withdrawEther(uint amountInWei) {
        require(balanceEthForAddress[msg.sender] >= amountInWei);
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
        WithdrawalEth(msg.sender, amountInWei, now);
        
    }

    function getEthBalanceInWei() constant returns (uint){
        return balanceEthForAddress[msg.sender];
    }


    //////////////////////
    // TOKEN MANAGEMENT //
    //////////////////////

    function addToken(string symbolName, address erc20TokenAddress) onlyowner {
        require(!hasToken(symbolName));
        symbolNameIndex++;
        tokens[symbolNameIndex].tokenContract = erc20TokenAddress;
        tokens[symbolNameIndex].symbolName = symbolName;
        tokenAddedToSystem(symbolNameIndex, symbolName, now);
        
    }

    function hasToken(string symbolName) constant returns (bool) {

        uint8 index = getSymbolIndex(symbolName);
        if(index == 0){
            return false;
        }
        
        return true;
    }


    function getSymbolIndex(string symbolName) internal returns (uint8) {

        for(uint8 i = 1; i <= symbolNameIndex; i++) {
            if(stringsEqual(tokens[i].symbolName, symbolName)){
                return i;
            }
        }

        return 0;
    }


    //strings compare function
    function stringsEqual(string storage _a, string memory _b) internal returns (bool){
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);

        if(a.length != b.length){
            return false;
        }

        for(uint i = 0; i < a.length; i++){
            if(a[i] != b[i]){
                return false;
            }
            
        }
        
        return true;
  }
    //////////////////////////////////
    // DEPOSIT AND WITHDRAWAL TOKEN //
    //////////////////////////////////
    function depositToken(string symbolName, uint amount) {
        require(amount > 0);
        uint8 index = getSymbolIndex(symbolName);
        require(index > 0);
        require(tokens[index].tokenContract != address(0));
        require(tokenBalanceForAddress[msg.sender][index] + amount > tokenBalanceForAddress[msg.sender][index]);
        ERC20Interface token = ERC20Interface (tokens[index].tokenContract);
        if(token.transferFrom(msg.sender, address(this), amount)){
            tokenBalanceForAddress[msg.sender][index] += amount;
            DepositForTokenReceived(msg.sender, index, amount, now);
        }
        
        
    }

    function withdrawToken(string symbolName, uint amount) {
        require(amount > 0);
        uint8 index = getSymbolIndex(symbolName);
        require(index > 0);
        require(tokens[index].tokenContract != address(0));
        require(tokenBalanceForAddress[msg.sender][index] - amount < tokenBalanceForAddress[msg.sender][index]);
        ERC20Interface token = ERC20Interface (tokens[index].tokenContract);
        require(tokenBalanceForAddress[msg.sender][index] >= amount);
        if(token.transfer(msg.sender, amount)){
            tokenBalanceForAddress[msg.sender][index] -= amount;
            WitdhrawalToken(msg.sender, index, amount, now);
        }
    }

    function getBalance(string symbolName) constant returns (uint) {
        uint8 index = getSymbolIndex(symbolName);
        return tokenBalanceForAddress[msg.sender][index];
    }





    /////////////////////////////
    // ORDER BOOK - BID ORDERS //
    /////////////////////////////
    function getBuyOrderBook(string symbolName) constant returns (uint[], uint[]) {
    }


    /////////////////////////////
    // ORDER BOOK - ASK ORDERS //
    /////////////////////////////
    function getSellOrderBook(string symbolName) constant returns (uint[], uint[]) {
    }



    ////////////////////////////
    // NEW ORDER - BID ORDER //
    ///////////////////////////
    function buyToken(string symbolName, uint priceInWei, uint amount) {
        uint8 tokenNameIndex = getSymbolIndex(symbolName);
        require(tokenNameIndex > 0); //, "Token not added to the exchange");
        uint total_amount_ether_necessary = 0;
        uint total_amount_ether_available = 0;

        //checking the balance is sufficient
        total_amount_ether_necessary = amount * priceInWei;

        //overflow check
        require(total_amount_ether_necessary >= amount);
        require(total_amount_ether_necessary >= priceInWei);
        require(balanceEthForAddress[msg.sender] >= total_amount_ether_necessary);
        require(balanceEthForAddress[msg.sender] - total_amount_ether_necessary >= 0);

        balanceEthForAddress[msg.sender] -= total_amount_ether_necessary;

        if(tokens[tokenNameIndex].amountSellPrices == 0 || tokens[tokenNameIndex].curSellPrice > priceInWei){
            //limit order: we dont have enough offers to filfull the amount

            //add the order to the orderBook
                addBuyOffer(tokenNameIndex, priceInWei, amount, msg.sender);
            //emit the event
            LimitBuyOrderCreated(tokenNameIndex, msg.sender, amount, priceInWei, tokens[tokenNameIndex].buyBook[priceInWei].offers_length); 
       }else{
           //market order: current sell price is smallet or equal to buy price

           revert(); //for now;

        }
    }

    function addBuyOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
        tokens[tokenIndex].buyBook[priceInWei].offers_length++;
        tokens[tokenIndex].buyBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount, who);

        if(tokens[tokenIndex].buyBook[priceInWei].offers_length == 1){
            tokens[tokenIndex].buyBook[priceInWei].offers_key = 1;
            //we have a new buy order - increase the counter so we can set the getOrderBook array later
            tokens[tokenIndex].amountBuyPrices++;

            //lowerPrice and higherPrice have to be set
            uint curBuyPrice = tokens[tokenIndex].curBuyPrice;
            uint lowestBuyPrice = tokens[tokenIndex].lowestBuyPrice;

            if(lowestBuyPrice == 0 || lowestBuyPrice > priceInWei){
                if(curBuyPrice == 0) {
                    //there is not buy order yet , we inser the first one...
                    tokens[tokenIndex].curBuyPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                }else {
                    //or the lowest one
                    tokens[tokenIndex].buyBook[lowestBuyPrice].lowerPrice = priceInWei;
                    tokens[tokenIndex].buyBook[priceInWei].higherPrice = lowestBuyPrice;
                    tokens[tokenIndex].buyBook[priceInWei].lowerPrice = 0;
                }
                tokens[tokenIndex].lowestBuyPrice = priceInWei;
            }else if(curBuyPrice < priceInWei){
                //the offer to buy is the highest one, we dont neew to  find the right spot
                tokens[tokenIndex].buyBook[curBuyPrice].higherPrice = priceInWei;
                tokens[tokenIndex].buyBook[priceInWei].higherPrice = priceInWei;
                tokens[tokenIndex].buyBook[priceInWei].lowerPrice = curBuyPrice;
                tokens[tokenIndex].curBuyPrice = priceInWei;
            }else {
                // we are somewhere in the middle, we need to find the right spot first

                uint buyPrice = tokens[tokenIndex].curBuyPrice;
                bool weFoundIt = false;
                while (buyPrice > 0 && !weFoundIt){
                    if(buyPrice < priceInWei && tokens[tokenIndex].buyBook[buyPrice].higherPrice > priceInWei){
                        //set the new order-book entry higher/lowerPrice first right
                        tokens[tokenIndex].buyBook[priceInWei].lowerPrice = buyPrice;
                        tokens[tokenIndex].buyBook[priceInWei].higherPrice = tokens[tokenIndex].buyBook[buyPrice].higherPrice;
                        //set the higherPriced order-book entries lowerprice to the current price
                        tokens[tokenIndex].buyBook[tokens[tokenIndex].buyBook[buyPrice].higherPrice].lowerPrice = priceInWei;
                        //set the lowerPriced order-book entries higherPrice to the curent price
                        tokens[tokenIndex].buyBook[buyPrice].higherPrice = priceInWei;

                        //stop the while loop
                        weFoundIt = true;
                    }
                    buyPrice = tokens[tokenIndex].buyBook[buyPrice].lowerPrice;
                }
            }
        }
    }





    ////////////////////////////
    // NEW ORDER - ASK ORDER //
    ///////////////////////////
    function sellToken(string symbolName, uint priceInWei, uint amount) {
        uint8 tokenNameIndex = getSymbolIndex(symbolName);
        uint etherAfterSell = amount * priceInWei;
        require(tokenNameIndex > 0);//, "Token not supported for sell");
        require (amount <= tokenBalanceForAddress[msg.sender][tokenNameIndex]);//, "Token balance insufficient for sell");
        require(tokenBalanceForAddress[msg.sender][tokenNameIndex] + (amount * priceInWei) > tokenBalanceForAddress[msg.sender][tokenNameIndex]);//, "Could not increase token balance");
        require(balanceEthForAddress[msg.sender] + etherAfterSell > balanceEthForAddress[msg.sender]);
        //subtract the amount of tokens
        tokenBalanceForAddress[msg.sender][tokenNameIndex] -= amount;

        if(tokens[tokenNameIndex].amountBuyPrices == 0 || tokens[tokenNameIndex].curBuyPrice < priceInWei){
            addSellOffer(tokenNameIndex, priceInWei, amount, msg.sender);
            LimitSellOrderCreated(tokenNameIndex, msg.sender,amount,priceInWei, tokens[tokenNameIndex].sellBook[priceInWei].offers_length);
        }else{
            revert();
        }

    }

    function addSellOffer(uint8 tokenIndex, uint priceInWei, uint amount, address who) internal {
        tokens[tokenIndex].sellBook[priceInWei].offers_length++;
        tokens[tokenIndex].sellBook[priceInWei].offers[tokens[tokenIndex].buyBook[priceInWei].offers_length] = Offer(amount, who);

        if(tokens[tokenIndex].sellBook[priceInWei].offers_length == 1){
            tokens[tokenIndex].sellBook[priceInWei].offers_key = 1;

            tokens[tokenIndex].amountSellPrices++;

            uint curSellPrice = tokens[tokenIndex].curSellPrice;
            uint highestSellPrice = tokens[tokenIndex].highestSellPrice;

            if(highestSellPrice == 0 || highestSellPrice < priceInWei){
                if(curSellPrice == 0){
                    tokens[tokenIndex].curSellPrice = priceInWei;
                    tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
                    tokens[tokenIndex].sellBook[priceInWei].lowerPrice = 0;
                }else{
                    tokens[tokenIndex].sellBook[highestSellPrice].higherPrice = priceInWei;
                    tokens[tokenIndex].sellBook[priceInWei].lowerPrice = highestSellPrice;
                    tokens[tokenIndex].sellBook[priceInWei].higherPrice = 0;
                }
                tokens[tokenIndex].highestSellPrice = priceInWei;
            }else if(curSellPrice > priceInWei){
                tokens[tokenIndex].sellBook[curSellPrice].lowerPrice = priceInWei;
                tokens[tokenIndex].sellBook[priceInWei].higherPrice = curSellPrice;
                tokens[tokenIndex].sellBook[priceInWei].lowerPrice = 0;
                tokens[tokenIndex].curSellPrice = priceInWei;
            }else {
                uint sellPrice = tokens[tokenIndex].curSellPrice;
                bool weFoundIt = false;
                while(sellPrice > 0 && !weFoundIt){
                    if(sellPrice < priceInWei && tokens[tokenIndex].sellBook[sellPrice].higherPrice > priceInWei){
                        tokens[tokenIndex].sellBook[priceInWei].lowerPrice = sellPrice;
                        tokens[tokenIndex].sellBook[priceInWei].higherPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice;
                        
                        tokens[tokenIndex].sellBook[tokens[tokenIndex].sellBook[sellPrice].higherPrice].lowerPrice = priceInWei;

                        tokens[tokenIndex].sellBook[sellPrice].higherPrice = priceInWei;

                        weFoundIt = true;

                    }
                    sellPrice = tokens[tokenIndex].sellBook[sellPrice].higherPrice; 
                }
            }
        }
    }



    //////////////////////////////
    // CANCEL LIMIT ORDER LOGIC //
    //////////////////////////////
    function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {
    }



}