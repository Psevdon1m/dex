# Exchange Contract

This Solidity contract represents an exchange for trading ERC20 tokens. It allows users to deposit and withdraw Ether and ERC20 tokens, create buy and sell orders, and view the order book.

## General Structure

The contract is structured using various structs and linked mappings to represent linked list stucture for order books to manage offers, and tokens. The key structs used are:

- `Offer`: Represents an offer with an amount and the address of the offer creator.
- `OrderBook`: Represents the order book for a specific price range, including the higher and lower prices, a mapping of offers, and additional information about the offers.
- `Token`: Represents a token with its token contract address, symbol name, buy order book, sell order book, and related data.

## Events

The contract emits various events to notify external systems about specific actions or state changes. The events include:

- `tokenAddedToSystem`: Indicates when a new token is added to the system.
- `DepositForTokenReceived`: Notifies when a user deposits ERC20 tokens into the exchange.
- `WitdhrawalToken`: Notifies when a user withdraws ERC20 tokens from the exchange.
- `DepositForEthReceived`: Notifies when a user deposits Ether into the exchange.
- `WithdrawalEth`: Notifies when a user withdraws Ether from the exchange.
- `LimitSellOrderCreated`: Indicates the creation of a limit sell order.
- `SellOrderFulfilled`: Notifies when a sell order is fulfilled.
- `SellOrderCanceled`: Notifies when a sell order is canceled.
- `LimitBuyOrderCreated`: Indicates the creation of a limit buy order.
- `BuyOrderFulfilled`: Notifies when a buy order is fulfilled.
- `BuyOrderCanceled`: Notifies when a buy order is canceled.

## Functions

The contract provides various functions to perform actions within the exchange, including:

- Deposit and withdrawal of Ether: Users can deposit and withdraw Ether using the `depositEther` and `withdrawEther` functions.
- Token management: The contract allows adding tokens to the system using the `addToken` function and checks for token existence with the `hasToken` function.
- Deposit and withdrawal of tokens: Users can deposit and withdraw ERC20 tokens using the `depositToken` and `withdrawToken` functions.
- Balance information: Users can retrieve their token balances using the `getBalance` function.
- Order book queries: Users can retrieve the buy and sell order books for a specific token using the `getBuyOrderBook` and `getSellOrderBook` functions, respectively.
- Buy and sell orders: Users can create buy and sell orders using the `buyToken` and `sellToken` functions.

Please note that this contract is based on the Solidity version 0.4.13.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
