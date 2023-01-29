// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 *  @dev Token contract represent shares of insurance module.
 */
contract DagobahIBToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Dagobah IB token", "DIib") {}
}
