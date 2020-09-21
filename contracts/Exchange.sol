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
        uint256 lowestSellPrice;
        uint256 amountSellPrices;
     }

    event tokenAddedToSystem(uint _SymbolIndex, string _token, uint _timestamp);

     //Deposit/Withdrawal events
    event DepositForTokenReceived(address indexed _from, uint indexed _symbolIndex, uint amount, uint _timestamp);
    event WitdhrawalToken(address indexed _to, uint indexed _symbolIndex, uint _amount, uint _timestamp);
    event DepositForEthReceived( address indexed _from, uint _amount, uint _timestamp);
    event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);

    //Trading events
    event LimitSellOrderCreated(uint indexed _symbolIndex, address indexed _who, uint _amountTokensm uint _priceInWei, uint _orderKey);
    event SellOrderFulfilled(uint endexed _symbolIndex, uint _amount, uint _priceInWei, uint _orderKey);
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
        require(balanceEthForAddress[msg.sender] =+ msg.value >= balanceEthForAddress[msg.sender]);
        balanceEthForAddress[msg.sender] =+ msg.value;
        emit DepositForEthReceived( msg.sender, msg.value, now);

    }

    function withdrawEther(uint amountInWei) {
        require(balanceEthForAddress[msg.sender] >= amountInWei);
        balanceEthForAddress[msg.sender] -= amountInWei;
        msg.sender.transfer(amountInWei);
        emit WithdrawalEth(msg.sender, amountInWei, now);
        
    }

    function getEthBalanceInWei() constant returns (uint){
        return balanceEthForAddress[msg.sender];
    }


    //////////////////////
    // TOKEN MANAGEMENT //
    //////////////////////

    function addToken(string symbolName, address erc20TokenAddress) onlyowner {
        require(!hasToken(symbolName), "Token is already listed");
        symbolNameIndex++;
        tokens[symbolNameIndex].tokenAddress = erc20TokenAddress;
        tokens[symbolNameIndex].symbolName = symbolName;
        emit tokenAddedToSystem(symbolNameIndex, symbolName, now)
        
    }

    function hasToken(string symbolName) constant returns (bool) {

        uint8 indes = getSymobolIndex(symbolName);
        if(index == 0){
            return false;
        }
        
        return true;
    }


    function getSymbolIndex(string symbolName) internal returns (uint8) {

        for(uint8 = 1; i <= symbolNameIndex; i++) {
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
        require(amount > 0, "Please deposit positive amount");
        uint8 index = getSymbolIndex(symbolName);
        require(index > 0, "Token is not listed on the exchange");
        require(tokens[index].tokenContract != address(0))
        require(tokenBalanceForAddress[msg.sender][index] += amount > tokenBalanceForAddress[msg.sender][index]);
        ERC20Interface token = ERC20Interface (tokens[index].tokenContract);
        if(token.transferFrom(msg.sender, address(this), amount)){
            tokenBalanceForAddress[msg.sender][index] += amount;
            emit DepositForTokenReceived(msg.sender, index, amount, now);
        }
        
        
    }

    function withdrawToken(string symbolName, uint amount) {
        require(amount > 0, "Please withdraw positive amount");
        uint8 index = getSymbolIndex(symbolName);
        require(index > 0, "Token is not listed on the exchange");
        require(tokens[index].tokenContract != address(0))
        require(tokenBalanceForAddress[msg.sender][index] -= amount < tokenBalanceForAddress[msg.sender][index]);
        ERC20Interface token = ERC20Interface (tokens[index].tokenContract);
        require(tokenBalanceForAddress[msg.sender][index] >= amount);
        if(token.transfer(msg.sender, amount)){
            tokenBalanceForAddress[msg.sender][index] -= amount;
            emit WitdhrawalToken(msg.sender, index, amount, now);
        }
    }

    function getBalance(string symbolName) constant returns (uint) {
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
    }





    ////////////////////////////
    // NEW ORDER - ASK ORDER //
    ///////////////////////////
    function sellToken(string symbolName, uint priceInWei, uint amount) {
    }



    //////////////////////////////
    // CANCEL LIMIT ORDER LOGIC //
    //////////////////////////////
    function cancelOrder(string symbolName, bool isSellOrder, uint priceInWei, uint offerKey) {
    }



}