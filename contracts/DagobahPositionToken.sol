// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";

/**
 *  @dev Token contract represent deal of issued insurance.
 */
contract DagobahPositionToken is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint64) public dealIds;
    mapping(uint256 => uint64) public dealProviders;
    mapping(uint256 => uint64) public dealSizes;
    mapping(uint256 => int64) public dealStart;
    mapping(uint256 => int64) public dealEnd;

    mapping(uint256 => bool) public tokenClaimable;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    // Mint
    function mint(
        address owner,
        uint64 dealId,
        uint64 dealProvider,
        uint64 dealSize
    ) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();

        dealIds[newItemId] = dealId;
        dealProviders[newItemId] = dealProvider;
        dealSizes[newItemId] = dealSize;
        _mint(owner, newItemId);

        return newItemId;
    }

    // @todo check if token is able to claim.
    function checkclaimable(uint256 tokenId) public returns (bool) {
        uint64 dealId = dealIds[tokenId];

        bool isDealActiveBeforeStartEpoch = _isDealActiveBeforeStartEpoch(dealId);
        bool isDealTerminatedBeforeEndEpoch = _isDealTerminatedBeforeEndEpoch(dealId);

        bool result = !isDealActiveBeforeStartEpoch || !isDealTerminatedBeforeEndEpoch;
        if (result) {
            tokenClaimable[tokenId] = true;
        }

        return result;
    }

    function _isDealActiveBeforeStartEpoch(uint64 dealId) internal returns (bool) {
        MarketTypes.GetDealTermReturn memory dealTerm = getDealTerm(dealId);
        MarketTypes.GetDealActivationReturn memory dealActivation = getDealActivation(dealId);

        // Check if miner activated before deal start epoch.
        bool result = dealTerm.start > dealActivation.activated;
        return result;
    }

    function _isDealTerminatedBeforeEndEpoch(uint64 dealId) internal returns (bool) {
        MarketTypes.GetDealTermReturn memory dealTerm = getDealTerm(dealId);
        MarketTypes.GetDealActivationReturn memory dealActivation = getDealActivation(dealId);

        if (dealActivation.terminated != 0) {
            bool result = dealTerm.end > dealActivation.terminated;
            return result;
        } else {
            return false;
        }
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
