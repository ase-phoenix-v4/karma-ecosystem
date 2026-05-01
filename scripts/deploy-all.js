const hre = require("hardhat");
const fs = require("fs");

async function main() {
    console.log("🚀 KARMA ECOSYSTEM — DEPLOY\n");
    
    const [deployer] = await hre.ethers.getSigners();
    console.log(`Deployer: ${deployer.address}\n`);
    
    const deployments = {};
    
    // Deploy KARMA Token
    console.log("📦 KARMA Token...");
    const KarmaToken = await hre.ethers.getContractFactory("contracts/tokens/KarmaToken.sol:KarmaToken");
    const karmaToken = await KarmaToken.deploy(deployer.address);
    await karmaToken.waitForDeployment();
    deployments.KarmaToken = await karmaToken.getAddress();
    console.log(`  ✅ ${deployments.KarmaToken}`);
    
    // Deploy KarmaSwap
    console.log("📦 KarmaSwap...");
    const KarmaSwap = await hre.ethers.getContractFactory("contracts/defi/KarmaSwap.sol:KarmaSwap");
    const karmaSwap = await KarmaSwap.deploy();
    await karmaSwap.waitForDeployment();
    deployments.KarmaSwap = await karmaSwap.getAddress();
    console.log(`  ✅ ${deployments.KarmaSwap}`);
    
    // Deploy Bridge
    console.log("📦 MultiChainBridge...");
    const Bridge = await hre.ethers.getContractFactory("contracts/defi/MultiChainBridge.sol:MultiChainBridge");
    const bridge = await Bridge.deploy(2);
    await bridge.waitForDeployment();
    deployments.MultiChainBridge = await bridge.getAddress();
    console.log(`  ✅ ${deployments.MultiChainBridge}`);
    
    // Save
    fs.writeFileSync("deployments.json", JSON.stringify(deployments, null, 2));
    
    console.log(`\n✅ Deployed ${Object.keys(deployments).length} contracts`);
    console.log("📄 Saved to deployments.json");
}

main().catch(console.error);
