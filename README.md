# Solidity Modular Plugin System

This project implements a modular plugin system for Solidity smart contracts, allowing for dynamic extension of functionality through plugins.

## Features

- Core contract that maintains a registry of plugins
- Standardized plugin interface (IPlugin)
- Example plugin demonstrating simple functionality
- Vault creation plugin for managing vaults
- Access control for plugin management
- Comprehensive test suite

## Contracts

- `Core.sol`: Main contract that manages the plugin registry
- `IPlugin.sol`: Interface that all plugins must implement
- `ExamplePlugin.sol`: Simple plugin that multiplies input by 2
- `VaultPlugin.sol`: Plugin for creating and managing vaults

## Setup

1. Install dependencies:
```bash
npm install
```

2. Compile contracts:
```bash
npm run compile
```

3. Run tests:
```bash
npm test
```

## Usage

### Deploying Contracts

1. Deploy the Core contract
2. Deploy your plugins
3. Register plugins with the Core contract using `addPlugin`

### Example Usage

```javascript
// Deploy contracts
const core = await Core.deploy();
const examplePlugin = await ExamplePlugin.deploy();
const vaultPlugin = await VaultPlugin.deploy();

// Register plugins
await core.addPlugin(examplePlugin.address);
await core.addPlugin(vaultPlugin.address);

// Use plugins
const result = await core.executePlugin(0, 5); // ExamplePlugin: returns 10
const vaultId = await core.executePlugin(1, 100); // VaultPlugin: creates vault with initial balance 100
```

## Testing

The test suite verifies:
- Plugin registration and management
- Example plugin functionality
- Vault creation and management
- Access control

Run the tests with:
```bash
npm test
```

## Security Considerations

- Only the contract owner can manage plugins
- Plugins are isolated from each other
- Input validation is performed for all operations
- Events are emitted for important state changes

## License

MIT 