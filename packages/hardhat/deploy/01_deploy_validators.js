
const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  const adminAddr = '0xF618a8F94be558cc9cc2a2db4f7c2c1CAC77d3bF'; // or deployer

  await deploy("Validators", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    // args: [ "Hello", ethers.utils.parseEther("1.5") ],
    args: [adminAddr], // Pass deployer's address as the argument
    log: true,
    // waitConfirmations: 5,
  });

};
module.exports.tags = ["Validators"];
