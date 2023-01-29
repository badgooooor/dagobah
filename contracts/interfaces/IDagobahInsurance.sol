// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface IDagobahInsurance {
    // Insurance client : create insurance position with deal id.
    function issueInsurance(uint64 _dealId) external returns (uint);

    // Insurance client : claim insurance position with deal id.
    function claim(uint64 _dealId) external returns (uint256);

    // View : total positions.
    function totalPositions() external view returns (uint256);

    // View : total opened positions.
    function totalOpenedPositions() external view returns (uint256);

    // Get position by deal id, return token id in DagobahPosition.
    function getPosition(uint64 _dealId) external returns (uint256);

    // Get user's opened positions.
    function getClientPosition(address _clientAddr) external returns (bool);

    // Risk bearer : deposit collateral for share tokens, return shares received.
    function stake() external returns (uint256);
}
