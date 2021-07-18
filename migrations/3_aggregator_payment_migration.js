const FullAggregator = artifacts.require("FullAggregator");
const LightAggregator = artifacts.require("LightAggregator");
const ILinkToken = artifacts.require("ILinkToken");
const { getLinkAddress } = require("./utils");

module.exports = async function(deployer, network) {
  if (network == "test") return;
  const debridgeInitParams = require("../assets/debridgeInitParams")[network];
  if (debridgeInitParams.type == "light") return;

  let amount = web3.utils.toWei("1");
  const link = await getLinkAddress(deployer, network);

  const linkTokenInstance = await ILinkToken.at(link);
  await linkTokenInstance.transferAndCall(
    FullAggregator.address.toString(),
    amount,
    "0x"
  );
  await linkTokenInstance.transferAndCall(
    LightAggregator.address.toString(),
    amount,
    "0x"
  );
};