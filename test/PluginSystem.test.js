const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Plugin System", function () {
  let core;
  let examplePlugin;
  let vaultPlugin;
  let owner;
  let user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    // Deploy Core contract
    const Core = await ethers.getContractFactory("Core");
    core = await Core.deploy();
    await core.waitForDeployment();

    // Deploy ExamplePlugin
    const ExamplePlugin = await ethers.getContractFactory("ExamplePlugin");
    examplePlugin = await ExamplePlugin.deploy();
    await examplePlugin.waitForDeployment();

    // Deploy VaultPlugin
    const VaultPlugin = await ethers.getContractFactory("VaultPlugin");
    vaultPlugin = await VaultPlugin.deploy();
    await vaultPlugin.waitForDeployment();
  });

  describe("Plugin Management", function () {
    it("Should allow owner to add plugins", async function () {
      await core.addPlugin(await examplePlugin.getAddress());
      expect(await core.getPluginCount()).to.equal(1);
    });

    it("Should not allow non-owner to add plugins", async function () {
      await expect(
        core.connect(user).addPlugin(await examplePlugin.getAddress())
      ).to.be.revertedWithCustomError(core, "OwnableUnauthorizedAccount");
    });

    it("Should allow owner to remove plugins", async function () {
      await core.addPlugin(await examplePlugin.getAddress());
      await core.removePlugin(0);
      expect(await core.getPluginCount()).to.equal(0);
    });
  });

  describe("Example Plugin", function () {
    beforeEach(async function () {
      await core.addPlugin(await examplePlugin.getAddress());
    });

    it("Should multiply input by 2", async function () {
      // For this test, we'll directly call the plugin to verify its functionality
      const result = await examplePlugin.performAction(5);
      expect(result).to.equal(10);
    });
  });

  describe("Vault Plugin", function () {
    beforeEach(async function () {
      await core.addPlugin(await vaultPlugin.getAddress());
    });

    it("Should create a new vault and emit VaultCreated event", async function () {
      const initialBalance = 100;
      const tx = await core.connect(owner).executePlugin(0, initialBalance);
      const receipt = await tx.wait();

      // Find the VaultCreated event in the logs
      const vaultCreatedEvent = receipt.logs.find(log => {
        try {
          const parsedLog = vaultPlugin.interface.parseLog(log);
          return parsedLog && parsedLog.name === "VaultCreated";
        } catch (e) {
          return false;
        }
      });
      
      expect(vaultCreatedEvent).to.not.be.undefined;

      // Parse the event data
      const parsedLog = vaultPlugin.interface.parseLog(vaultCreatedEvent);
      const vaultId = parsedLog.args.vaultId;
      
      const [vaultOwner, balance, createdAt] = await vaultPlugin.getVault(vaultId);
      expect(vaultOwner).to.equal(await owner.getAddress());
      expect(balance).to.equal(initialBalance);
      expect(createdAt).to.be.gt(0);
    });

    it("Should create multiple vaults with unique IDs", async function () {
      const tx1 = await core.executePlugin(0, 100);
      const tx2 = await core.executePlugin(0, 200);
      
      const receipt1 = await tx1.wait();
      const receipt2 = await tx2.wait();

      const event1 = receipt1.logs.find(log => {
        try {
          const parsedLog = vaultPlugin.interface.parseLog(log);
          return parsedLog && parsedLog.name === "VaultCreated";
        } catch (e) {
          return false;
        }
      });

      const event2 = receipt2.logs.find(log => {
        try {
          const parsedLog = vaultPlugin.interface.parseLog(log);
          return parsedLog && parsedLog.name === "VaultCreated";
        } catch (e) {
          return false;
        }
      });

      const vaultId1 = vaultPlugin.interface.parseLog(event1).args.vaultId;
      const vaultId2 = vaultPlugin.interface.parseLog(event2).args.vaultId;
      
      expect(vaultId1).to.not.equal(vaultId2);
      expect(await vaultPlugin.getVaultCount()).to.equal(2);
    });

    it("Should revert when executing a plugin with an invalid ID", async function () {
      await expect(core.executePlugin(999, 5)).to.be.revertedWithCustomError(core, "InvalidPluginID");
    });

    it("Should not allow adding the same plugin twice", async function () {
      await core.addPlugin(await examplePlugin.getAddress());
      await expect(core.addPlugin(await examplePlugin.getAddress())).to.be.revertedWithCustomError(core, "PluginAlreadyRegistered");
    });

    it("Should revert when trying to remove a plugin with an invalid index", async function () {
      // Try to remove a plugin at index 0 when no plugins are registered
      await expect(core.removePlugin(0)).to.be.revertedWithCustomError(core, "IndexOutOfBounds");
    });

    it("Should prevent reentrancy attacks", async function () {
      const MaliciousPlugin = await ethers.getContractFactory("MaliciousPlugin");
      const maliciousPlugin = await MaliciousPlugin.deploy(await core.getAddress());
      await maliciousPlugin.waitForDeployment();

      await core.addPlugin(await maliciousPlugin.getAddress());
      await expect(core.executePlugin(0, 0)).to.be.reverted;
    });
  });
});