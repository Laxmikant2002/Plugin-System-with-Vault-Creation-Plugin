// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./IPlugin.sol";

/**
 * @title Core
 * @dev Core contract that manages a registry of plugins and handles plugin execution
 */
contract Core is Ownable, ReentrancyGuard {
    // Array of registered plugin addresses
    address[] private plugins;
    
    // Mapping to check if an address is a registered plugin
    mapping(address => bool) private isPlugin;
    
    // Event emitted when a plugin is added
    event PluginAdded(address indexed plugin, uint256 index);
    
    // Event emitted when a plugin is removed
    event PluginRemoved(address indexed plugin, uint256 index);

    // Add custom errors
    error InvalidPluginID();
    error PluginAlreadyRegistered();
    error IndexOutOfBounds();
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Add a new plugin to the registry
     * @param plugin The address of the plugin contract
     */
    function addPlugin(address plugin) external onlyOwner {
        if (plugin == address(0)) {
            revert InvalidPluginID();
        }
        if (isPlugin[plugin]) {
            revert PluginAlreadyRegistered();
        }

        plugins.push(plugin);
        isPlugin[plugin] = true;

        emit PluginAdded(plugin, plugins.length - 1);
    }
    
    /**
     * @dev Remove a plugin from the registry
     * @param index The index of the plugin to remove
     */
    function removePlugin(uint256 index) external onlyOwner {
        if (index >= plugins.length) {
            revert IndexOutOfBounds();
        }

        address plugin = plugins[index];
        isPlugin[plugin] = false;

        if (index < plugins.length - 1) {
            plugins[index] = plugins[plugins.length - 1];
        }
        plugins.pop();

        emit PluginRemoved(plugin, index);
    }
    
    /**
     * @dev Execute a plugin's action function
     * @param pluginId The index of the plugin in the registry
     * @param input The input value for the plugin action
     * @return The result of the plugin action
     */
    function executePlugin(uint256 pluginId, uint256 input) external nonReentrant returns (uint256) {
        if (pluginId >= plugins.length) {
            revert InvalidPluginID();
        }

        address pluginAddress = plugins[pluginId];
        if (!isPlugin[pluginAddress]) {
            revert PluginAlreadyRegistered();
        }

        IPlugin plugin = IPlugin(pluginAddress);
        return plugin.performAction(input);
    }
    
    /**
     * @dev Get the number of registered plugins
     * @return The number of plugins
     */
    function getPluginCount() external view returns (uint256) {
        return plugins.length;
    }
    
    /**
     * @dev Get the address of a plugin by its index
     * @param index The index of the plugin
     * @return The address of the plugin
     */
    function getPlugin(uint256 index) external view returns (address) {
        if (index >= plugins.length) {
            revert("Index out of bounds");
        }
        return plugins[index];
    }
}