const Administration = artifacts.require("Administration");
const RealestateToken = artifacts.require("RealestateToken");
const EstateAgent = artifacts.require("EstateAgent");
const RentalAgent = artifacts.require("RentalAgent");
const agent = '0x16069FC3d1E8D65EEA472C97E8408d7a53bc2127'; //ONE OF YOUR LOCAL BLOCKCHAIN ADDRESS

module.exports = function(deployer, network, accounts) {
    if (network !== 'development' && network !== 'coverage') {
        let admin = accounts[0];
        deployer.then(async() => {
            //Always deploy EstateAgent first
            await deployer.deploy(EstateAgent, 1200, 1);

            //Wait till deployed
            this.estateAgent = await EstateAgent.deployed();

            //Get the address of the deployed token contract within EstateAgent
            let tokenAddress = await this.estateAgent.token.call({ from: admin });
            this.token = await RealestateToken.at(tokenAddress);

            //Use both the address in RentalAgent contract
            await deployer.deploy(RentalAgent, this.token.address, EstateAgent.address);
        });
    }
};