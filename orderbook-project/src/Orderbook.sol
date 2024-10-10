// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract OrderBook {
    struct Order {
        address user;
        uint256 price;
        uint256 quantity;
        bool isBuyOrder;
        uint256 timestamp;
    }
    

    IERC20 public tokenA;
    IERC20 public tokenB;

    Order[] public buyOrders;
    Order[] public sellOrders;
    Order[] public executedOrders;

    event NewOrder(address indexed user, uint256 price, uint256 quantity, bool isBuyOrder);
    event OrderExecuted(address indexed buyer, address indexed seller, uint256 price, uint256 quantity);

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function placeBuyOrder(uint256 price, uint256 quantity) external {
        require(quantity > 0, "Quantity must be greater than 0");
        buyOrders.push(Order(msg.sender, price, quantity, true, block.timestamp));
        emit NewOrder(msg.sender, price, quantity, true);
        matchOrders();
    }

    function placeSellOrder(uint256 price, uint256 quantity) external {
        require(quantity > 0, "Quantity must be greater than 0");
        sellOrders.push(Order(msg.sender, price, quantity, false, block.timestamp));
        emit NewOrder(msg.sender, price, quantity, false);
        matchOrders();
    }

    function matchOrders() internal {
        // Loop through buy and sell orders to find matching ones
        for (uint256 i = 0; i < buyOrders.length; i++) {
            for (uint256 j = 0; j < sellOrders.length; j++) {
                if (buyOrders[i].price >= sellOrders[j].price && buyOrders[i].quantity == sellOrders[j].quantity) {
                    executeOrder(i, j);
                    break;
                }
            }
        }
    }

    function executeOrder(uint256 buyIndex, uint256 sellIndex) internal {
        Order memory buyOrder = buyOrders[buyIndex];
        Order memory sellOrder = sellOrders[sellIndex];

        // Execute token transfer
        require(tokenA.transferFrom(buyOrder.user, sellOrder.user, buyOrder.quantity), "Token A transfer failed");
        require(tokenB.transferFrom(sellOrder.user, buyOrder.user, sellOrder.quantity), "Token B transfer failed");

        // Record the executed order
        executedOrders.push(buyOrder);
        executedOrders.push(sellOrder);

        emit OrderExecuted(buyOrder.user, sellOrder.user, buyOrder.price, buyOrder.quantity);

        // Remove the matched orders
        removeOrder(buyOrders, buyIndex);
        removeOrder(sellOrders, sellIndex);
    }

    function removeOrder(Order[] storage orders, uint256 index) internal {
        require(index < orders.length, "Index out of bounds");
        orders[index] = orders[orders.length - 1];
        orders.pop();
    }

function getReadableExecutedOrders() external view returns (address[] memory, address[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
    uint256 length = executedOrders.length;
    address[] memory buyers = new address[](length / 2); // Puisque chaque exécution a 2 ordres (acheteur et vendeur)
    address[] memory sellers = new address[](length / 2);
    uint256[] memory prices = new uint256[](length / 2);
    uint256[] memory quantities = new uint256[](length / 2);
    uint256[] memory timestamps = new uint256[](length / 2);

    for (uint256 i = 0; i < length / 2; i++) {
        buyers[i] = executedOrders[i * 2].user;
        sellers[i] = executedOrders[i * 2 + 1].user;
        prices[i] = executedOrders[i * 2].price;
        quantities[i] = executedOrders[i * 2].quantity;
        timestamps[i] = executedOrders[i * 2].timestamp;
    }

    return (buyers, sellers, prices, quantities, timestamps);
}


    // Utility to view current orders
    function getReadableBuyOrders() external view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
    uint256 length = buyOrders.length;
    address[] memory users = new address[](length);
    uint256[] memory prices = new uint256[](length);
    uint256[] memory quantities = new uint256[](length);
    uint256[] memory timestamps = new uint256[](length);

    for (uint256 i = 0; i < length; i++) {
        users[i] = buyOrders[i].user;
        prices[i] = buyOrders[i].price;
        quantities[i] = buyOrders[i].quantity;
        timestamps[i] = buyOrders[i].timestamp;
    }
    return (users, prices, quantities, timestamps);
}


function getReadableSellOrders() external view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
    uint256 length = sellOrders.length;
    address[] memory users = new address[](length);
    uint256[] memory prices = new uint256[](length);
    uint256[] memory quantities = new uint256[](length);
    uint256[] memory timestamps = new uint256[](length);

    for (uint256 i = 0; i < length; i++) {
        users[i] = sellOrders[i].user;
        prices[i] = sellOrders[i].price;
        quantities[i] = sellOrders[i].quantity;
        timestamps[i] = sellOrders[i].timestamp;
    }
    return (users, prices, quantities, timestamps);
}

}
