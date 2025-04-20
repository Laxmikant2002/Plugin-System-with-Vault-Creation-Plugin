// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IPlugin.sol";

/**
 * @title MaliciousPlugin
 * @dev A plugin that attempts to reenter the Core contract during execution
 */
contract MaliciousPlugin is IPlugin {
    address private core;
    bool private hasReentered;
    
    constructor(address _core) {
        core = _core;
    }
    
    function performAction(uint256) external override returns (uint256) {
        if (!hasReentered) {
            hasReentered = true;
            // Try to reenter the Core contract
            (bool success, ) = core.call(abi.encodeWithSignature("executePlugin(uint256,uint256)", 0, 0));
            require(success, "Reentrancy failed");
        }
        return 0;
    }
} 