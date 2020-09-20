const FixedSupplyToken = artifacts.require('FixedSupplyToken');
const Exchange = artifacts.require('Exchange');

module.exports = function(deployer){
    deployer.deploy(FixedSupplyToken);
    deployer.deploy(Exchange);
};
