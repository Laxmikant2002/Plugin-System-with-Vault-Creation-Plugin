# Solidity Modular Plugin System with Vault Creation Plugin

## Objective
This project demonstrates a modular, plugin-based architecture for Solidity smart contracts. The `Core` contract enables dynamic extension of functionality through plugins, such as a simple multiplier plugin and a vault creation plugin.

## Features
- **Core Contract**: Manages a registry of plugins and dynamically dispatches calls to them.
- **Plugin Interface**: Standardized interface (`IPlugin`) for all plugins.
- **Example Plugin**: Multiplies an input by a constant factor.
- **Vault Creation Plugin**: Creates and manages vaults with unique identifiers.

## Requirements
- Solidity version: `0.8.20`
- Libraries: OpenZeppelin's `Ownable` and `ReentrancyGuard`

## Project Structure
```
contracts/
  Core.sol            # Main contract managing plugins
  IPlugin.sol         # Plugin interface
  ExamplePlugin.sol   # Simple multiplier plugin
  VaultPlugin.sol     # Vault creation plugin
  MaliciousPlugin.sol # Plugin for testing reentrancy

test/
  PluginSystem.test.js # Test suite for the system

hardhat.config.js     # Hardhat configuration
package.json          # Project dependencies and scripts
```

## Setup Instructions

### Prerequisites
- Node.js and npm installed
- Hardhat installed globally or locally in the project

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd Plugin-System
   ```
2. Install dependencies:
   ```bash
   npm install
   ```

### Compilation
Compile the smart contracts:
```bash
npx hardhat compile
```

### Testing
Run the test suite:
```bash
npx hardhat test
```

## Deployment
1. Deploy the `Core` contract:
   ```javascript
   const Core = await ethers.getContractFactory("Core");
   const core = await Core.deploy();
   await core.deployed();
   console.log("Core deployed to:", core.address);
   ```
2. Deploy plugins and register them with the `Core` contract:
   ```javascript
   const ExamplePlugin = await ethers.getContractFactory("ExamplePlugin");
   const examplePlugin = await ExamplePlugin.deploy();
   await examplePlugin.deployed();
   await core.addPlugin(examplePlugin.address);

   const VaultPlugin = await ethers.getContractFactory("VaultPlugin");
   const vaultPlugin = await VaultPlugin.deploy();
   await vaultPlugin.deployed();
   await core.addPlugin(vaultPlugin.address);
   ```

## Usage
1. Execute a plugin action:
   ```javascript
   const result = await core.executePlugin(0, 5); // Calls ExamplePlugin
   console.log("Result:", result.toString());
   ```
2. Create a vault:
   ```javascript
   const vaultId = await core.executePlugin(1, 100); // Calls VaultPlugin
   console.log("Vault ID:", vaultId.toString());
   ```

## Testing Details
The test suite verifies:
- Only the owner can manage plugins.
- Plugins execute correctly and return expected results.
- Vaults are created with unique IDs.
- Reentrancy attacks are prevented.

## Additional Notes
- The project uses OpenZeppelin's `Ownable` for access control and `ReentrancyGuard` for reentrancy protection.
- The `MaliciousPlugin` contract is included to test reentrancy protection.

## License
This project is licensed under the MIT License.