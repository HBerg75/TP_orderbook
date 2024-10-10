// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// Un simple contrat ERC20 qui permet de mint des tokens pour les tests
contract TestToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
