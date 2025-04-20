// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IPlugin.sol";

/**
 * @title VaultPlugin
 * @dev A plugin that creates and manages vaults
 */
contract VaultPlugin is IPlugin {
    // Counter for generating unique vault IDs
    uint256 private vaultCounter;
    
    // Struct to store vault information
    struct Vault {
        address owner;
        uint256 balance;
        uint256 createdAt;
    }
    
    // Mapping from vault ID to vault information
    mapping(uint256 => Vault) private vaults;
    
    // Event emitted when a new vault is created
    event VaultCreated(uint256 indexed vaultId, address indexed owner, uint256 initialBalance);
    
    /**
     * @dev Creates a new vault with the provided initial balance
     * @param initialBalance The initial balance for the vault
     * @return The ID of the newly created vault
     */
    function performAction(uint256 initialBalance) external override returns (uint256) {
        uint256 vaultId = vaultCounter++;
        
        vaults[vaultId] = Vault({
            owner: msg.sender,
            balance: initialBalance,
            createdAt: block.timestamp
        });
        
        emit VaultCreated(vaultId, msg.sender, initialBalance);
        return vaultId;
    }
    
    /**
     * @dev Get information about a specific vault
     * @param vaultId The ID of the vault
     * @return The vault information (owner, balance, creation timestamp)
     */
    function getVault(uint256 vaultId) external view returns (address, uint256, uint256) {
        Vault memory vault = vaults[vaultId];
        require(vault.owner != address(0), "Vault does not exist");
        return (vault.owner, vault.balance, vault.createdAt);
    }
    
    /**
     * @dev Get the total number of vaults created
     * @return The number of vaults
     */
    function getVaultCount() external view returns (uint256) {
        return vaultCounter;
    }
} 