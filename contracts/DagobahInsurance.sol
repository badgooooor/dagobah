// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

import {DagobahIBToken} from "./DagobahIBToken.sol";
import {DagobahPositionToken} from "./DagobahPositionToken.sol";

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

    // Mapping deal id -> dealTokenAddr token id.
    mapping(uint64 => uint256) public dealTokenId;

    // Events.
    event FeeRateUpdated(address sender, uint256 feeRate);

    constructor() payable {
        DagobahIBToken ibToken = new DagobahIBToken("ibToken", "DGib");
        DagobahPositionToken positionToken = new DagobahPositionToken("positionToken", "DBT");

        ibTokenAddr = address(ibToken);
        dealTokenAddr = address(positionToken);

        registryAddr = address(this);
    }

    // - Client pays FIL tokens
    // - Get deal information, check deal token, and mint token position
    function issue(uint64 _dealId) public payable returns (uint256) {
        require(msg.value >= 0.25 ether, "DagobahRegistry: Minimum FIL required.");
        require(dealTokenId[_dealId] != 0, "DagobahRegistry: Position is already opened.");

        uint64 dealProviderId = getDealProvider(_dealId);
        uint64 dealSize = getDealSize(_dealId);

        // Mint token with deal provider, deal size.
        DagobahPositionToken positionToken = DagobahPositionToken(dealTokenAddr);
        positionToken.mint(msg.sender, _dealId, dealProviderId, dealSize);
        return 1;
    }

    // @todo claim fn.
    // @todo get remaining fee in position.
    // @todo get refil position.

    function setFeeRate(uint256 _feeRate) public onlyOwner {
        feeRate = _feeRate;
        emit FeeRateUpdated(msg.sender, _feeRate);
    }

    // Wrapper methods for Zondax API contract call.
    // @return miner id.
    function getDealProvider(uint64 dealId) internal returns (uint64) {
        return MarketAPI.getDealProvider(dealId).provider;
    }

    // @return file size.
    function getDealSize(uint64 dealId) internal returns (uint64) {
        return MarketAPI.getDealDataCommitment(dealId).size;
    }
}
