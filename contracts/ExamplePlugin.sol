// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IPlugin.sol";

/**
 * @title ExamplePlugin
 * @dev A simple example plugin that multiplies the input by a constant factor
 */
contract ExamplePlugin is IPlugin {
    uint256 private constant MULTIPLIER = 2;
    
    /**
     * @dev Multiplies the input by a constant factor
     * @param input The input value to multiply
     * @return The result of the multiplication
     */
    function performAction(uint256 input) external pure override returns (uint256) {
        return input * MULTIPLIER;
    }
} 