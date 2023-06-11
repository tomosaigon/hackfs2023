
const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  const ValidatorsContract = await ethers.getContract("Validators", deployer);

  await deploy("Collector", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [ValidatorsContract.address],
    log: true,
    // waitConfirmations: 5,
  });

};
module.exports.tags = ["Collector"];
