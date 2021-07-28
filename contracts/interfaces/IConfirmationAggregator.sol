// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IConfirmationAggregator {

    /* ========== STRUCTS ========== */

    struct SubmissionInfo {
        uint256 block; // confirmation block
        uint256 confirmations; // received confirmations count
        mapping(address => bool) hasVerified; // verifier => has already voted
    }
    struct DebridgeDeployInfo {
        address tokenAddress; //native token address
        uint256 chainId; //native chainId
        string name;
        string symbol;
        uint8 decimals;
        uint256 confirmations; // received confirmations count
        mapping(address => bool) hasVerified; // verifier => has already voted
    }

    /* ========== FUNCTIONS ========== */
    
    function submit(bytes32 _submissionId) external;

    function submitMany(bytes32[] memory _submissionIds) external;

    function getSubmissionConfirmations(bytes32 _submissionId)
        external
        view
        returns (uint256 _confirmations, bool _blockConfirmationPassed);

    function getWrappedAssetAddress(bytes32 _debridgeId)
        external
        view
        returns (address _wrappedAssetAddress);
    
    function deployAsset(bytes32 _debridgeId) 
        external 
        returns (address wrappedAssetAddress, uint256 nativeChainId);
}