const { BN, ether, expectRevert, expectEvent } = require("@openzeppelin/test-helpers");
const { expect } = require("chai");
const RealestateToken = artifacts.require("RealestateToken");

//Testing RealestateToken.sol
contract("RealestateToken", function(accounts) {
    const admin = accounts[0];
    const agent = accounts[1];
    const purchaser = accounts[2];
    const renter = accounts[3];
    const hacker = accounts[4];
    const legit = accounts[5];

    //Before each unit test  
    beforeEach(async function() {
        this.realestateTokenInstance = await RealestateToken.new(agent);
    });

    it("Testing mint() function", async function() {
        //store token id returned by function
        const token = await this.realestateTokenInstance.mint.call(purchaser, { from: agent });
        //mint
        await this.realestateTokenInstance.mint(purchaser, { from: agent });

        //Verify totalSupply equal to 1
        let totalSupply = await this.realestateTokenInstance.totalSupply();
        expect(totalSupply).to.be.bignumber.equal(new BN(1));

        //Verifying modifier is effective
        await expectRevert(this.realestateTokenInstance.mint(hacker, { from: hacker }), "Not an agent!");

        //Verifying
        const legitimacy = await this.realestateTokenInstance.verifyLegitimacy.call(purchaser, token);
        expect(legitimacy).to.be.equal(true);
    });

    it("Testing burn() function", async function() {
        //store token id returned by function
        const token = await this.realestateTokenInstance.mint.call(purchaser, { from: agent });
        //mint
        await this.realestateTokenInstance.mint(purchaser, { from: agent });
        //burn
        await this.realestateTokenInstance.burn(token, { from: agent });

        //Verify totalSupply equal to 0
        let totalSupply = await this.realestateTokenInstance.totalSupply();
        expect(totalSupply).to.be.bignumber.equal(new BN(0));
    });

    it("Testing verifyLegitimacy() function", async function() {
        //store token id returned by function
        const token = await this.realestateTokenInstance.mint.call(legit, { from: agent });

        //mint
        await this.realestateTokenInstance.mint(legit, { from: agent });

        //Verifying legitimacy
        const legitimacy = await this.realestateTokenInstance.verifyLegitimacy.call(legit, token);
        expect(legitimacy).to.be.equal(true);
    });
});