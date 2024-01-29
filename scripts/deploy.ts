import { ethers } from "hardhat";
import { parseEther } from "ethers/lib/utils";
import { network } from "hardhat";

async function main() {
  let subscriptionId = 8938;
  let vrfCoordinatorAddr = "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625"; // Sepolia
  let keyHash = "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c"; // Sepolia
  if(network.config.chainId == 31337) {
    console.log("Local deployment");
    // Deploy vrfCoordinator mock
    let contractFactory = await ethers.getContractFactory("VRFCoordinatorV2Mock");
    let baseFee = "100000000000000000";
    let gasPriceLink = 1000000000;
    console.log("Deploying VRFCoordinator mock...")
    let vrfCoordinatorV2Mock = await contractFactory.deploy(baseFee, gasPriceLink);
    await vrfCoordinatorV2Mock.deployed();
    console.log(`Deployed contract to: ${vrfCoordinatorV2Mock.address}`);
    vrfCoordinatorAddr = vrfCoordinatorV2Mock.address;

    // create VRFV2 Subscription
    const trx = await vrfCoordinatorV2Mock.createSubscription();
    const transactionReceipt = await trx.wait();
    subscriptionId = transactionReceipt.events[0].args.subId;
    // Fund the subscription
    await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, parseEther("1"));
  }
  
  // Deploy NFT Minter
  let nftMinterFactory = await ethers.getContractFactory("NFTMinter");
  console.log("Deploying NFTMinter...")
  let nftMinter = await nftMinterFactory.deploy(subscriptionId, vrfCoordinatorAddr, keyHash);
  await nftMinter.deployed();
  console.log(`Deployed contract to: ${nftMinter.address}`);

  // Add consumer to coordinator
  if(network.config.chainId == 31337) {
    const vrfCoordinatorV2Mock = await ethers.getContractAt("VRFCoordinatorV2Mock", vrfCoordinatorAddr);
    await vrfCoordinatorV2Mock.addConsumer(subscriptionId, nftMinter.address);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
