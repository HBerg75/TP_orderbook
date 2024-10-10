// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/Orderbook.sol";
import "./TestToken.sol";

contract OrderBookTest is Test {
    OrderBook orderBook;
    TestToken tokenA;
    TestToken tokenB;
    
    address user1 = address(0x123);
    address user2 = address(0x456);

    function setUp() public {
        tokenA = new TestToken("Token A", "TKA");
        tokenB = new TestToken("Token B", "TKB");

        orderBook = new OrderBook(address(tokenA), address(tokenB));

        tokenA.mint(user1, 1000 ether);
        tokenB.mint(user2, 1000 ether);
    }

    function testPlaceBuyOrder() public {
        vm.startPrank(user1);
        tokenA.approve(address(orderBook), 10 ether);
        orderBook.placeBuyOrder(15, 10);
        vm.stopPrank();

        (address[] memory users, uint256[] memory prices, uint256[] memory quantities, ) = orderBook.getReadableBuyOrders();
        assertEq(users.length, 1);
        assertEq(users[0], user1);
        assertEq(prices[0], 15);
        assertEq(quantities[0], 10);
    }

    function testPlaceSellOrder() public {
        vm.startPrank(user2);
        tokenB.approve(address(orderBook), 10 ether);
        orderBook.placeSellOrder(15, 10);
        vm.stopPrank();

        (address[] memory users, uint256[] memory prices, uint256[] memory quantities, ) = orderBook.getReadableSellOrders();
        assertEq(users.length, 1);
        assertEq(users[0], user2);
        assertEq(prices[0], 15);
        assertEq(quantities[0], 10);
    }

    function testOrderExecution() public {
        vm.startPrank(user1);
        tokenA.approve(address(orderBook), 10 ether);
        orderBook.placeBuyOrder(15, 10);
        vm.stopPrank();

        vm.startPrank(user2);
        tokenB.approve(address(orderBook), 10 ether);
        orderBook.placeSellOrder(15, 10);
        vm.stopPrank();

        (address[] memory buyers, address[] memory sellers, uint256[] memory prices, uint256[] memory quantities, ) = orderBook.getReadableExecutedOrders();
        assertEq(buyers.length, 1);
        assertEq(sellers.length, 1);
        assertEq(buyers[0], user1);
        assertEq(sellers[0], user2);
        assertEq(prices[0], 15);
        assertEq(quantities[0], 10);
    }

    function testNoMatchWhenPricesDiffer() public {
        vm.startPrank(user1);
        tokenA.approve(address(orderBook), 10 ether);
        orderBook.placeBuyOrder(15, 10);
        vm.stopPrank();

        vm.startPrank(user2);
        tokenB.approve(address(orderBook), 10 ether);
        orderBook.placeSellOrder(20, 10);
        vm.stopPrank();

        (address[] memory buyers, , , ) = orderBook.getReadableBuyOrders();
        (address[] memory sellers, , , ) = orderBook.getReadableSellOrders();
        assertEq(buyers.length, 1);
        assertEq(sellers.length, 1);

        (address[] memory executedBuyers, , , , ) = orderBook.getReadableExecutedOrders();
        assertEq(executedBuyers.length, 0);  
    }
}
