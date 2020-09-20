pragma solidity ^0.4.13;


import "./owned.sol";
import "./FixedSupplyToken.sol";


contract Exchange is owned {

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
    }

    function withdrawEther(uint amountInWei) {
    }

    function getEthBalanceInWei() constant returns (uint){
    }


    //////////////////////
    // TOKEN MANAGEMENT //
    //////////////////////

    function addToken(string symbolName, address erc20TokenAddress) onlyowner {
        require(!hasToken(symbolName), "Token is already listed");
        symbolNameIndex++;
        tokens[symbolNameIndex].tokenAddress = erc20TokenAddress;
        tokens[symbolNameIndex].symbolName = symbolName;
        
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
    }

    function withdrawToken(string symbolName, uint amount) {
    }

    function getBalance(string symbolName) constant returns (uint) {
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