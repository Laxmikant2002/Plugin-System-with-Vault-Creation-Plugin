// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPlugin
 * @dev Interface for plugin contracts that can be registered with the Core contract
 */
interface IPlugin {
    /**
     * @dev Executes the plugin action with the provided input and returns a result
     * @param input The input value for the plugin action
     * @return The result of the plugin action
     */
    function performAction(uint256 input) external returns (uint256);
} 