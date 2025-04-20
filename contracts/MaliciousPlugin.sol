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
        // Try to reenter the Core contract by directly calling it
        (bool success,) = core.call(abi.encodeWithSignature("executePlugin(uint256,uint256)", 0, 0));
        // The call should fail due to the nonReentrant modifier
        require(!success, "Reentrancy was not prevented");
        return 0;
    }
} 