// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IPlugin.sol";

/**
 * @title MaliciousPlugin
 * @dev A plugin that attempts to reenter the Core contract during execution
 */
contract MaliciousPlugin is IPlugin {
    address private immutable core;
    
    constructor(address _core) {
        core = _core;
    }
    
    function performAction(uint256) external override returns (uint256) {
        // Try to reenter the Core contract
        IPlugin(core).performAction(0);
        return 0;
    }
} 