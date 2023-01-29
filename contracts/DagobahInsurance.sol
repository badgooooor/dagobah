// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

/**
 *  @dev Contract module act as point of contact.
 */
contract DagobahRegistry is Ownable {
    // Data
    // - treasury contract.
    // - pricing contract,
    // - keep deal infromation in meta data?
    // - API interface contract?
    // - fee contract or FEE constant

    // Address of registry.
    address public registryAddr;
    // Address of interest-bearing token contract.
    address public ibTokenAddr;

    // Address of deal contract.
    address public dealTokenAddr;

    // Fee rate.
    uint256 public feeRate = 1;

    // Events.
    event FeeRateUpdated(address sender, uint256 feeRate);

    constructor(address _ibTokenAddr, address _dealTokenAddr, uint256 _feeRate) {
        ibTokenAddr = _ibTokenAddr;
        dealTokenAddr = _dealTokenAddr;
        feeRate = _feeRate;
        registryAddr = address(this);
    }

    function setFee(uint256 _feeRate) public onlyOwner {
        feeRate = _feeRate;
        emit FeeRateUpdated(msg.sender, _feeRate);
    }

    // METHODS
    // Issue
    // - Issue an insurance.
    // Renewal
    // - Refill opened insurance? or renew via new issue?
    // - Get expiry timestamp.
    // Decay
    // - Get token fee left.

    // Wrapper methods for Zondax API contract call.
    // @return miner id.
    function getDealProvider(uint64 dealId) internal returns (uint64) {
        return MarketAPI.getDealProvider(dealId).provider;
    }

    // @return file size.
    function getDealSize(uint64 dealId) internal returns (uint64) {
        return MarketAPI.getDealDataCommitment(dealId).size;
    }

    // @return deal start epoch and end epoch
    function getDealTerm(uint64 dealId) internal returns (MarketTypes.GetDealTermReturn memory) {
        return MarketAPI.getDealTerm(dealId);
    }

    // @return activation epoch (int64) and termination epoch (int64).
    function getDealActivation(
        uint64 dealId
    ) internal returns (MarketTypes.GetDealActivationReturn memory) {
        return MarketAPI.getDealActivation(dealId);
    }
}
