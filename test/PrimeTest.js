const { expect } = require("chai");
const hre = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
const {
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");


describe("Prime", function() {

    async function deployPrimeFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();
    
        const Prime = await ethers.getContractFactory("Prime");
        const prime = await Prime.deploy();
    
        return { Prime, prime, owner, otherAccount };
    }

    describe("mint function", function () {
        it("Should mint 1000 PRIME", async function () {
            const { Prime, prime, owner, otherAccount } = await loadFixture(deployPrimeFixture);
            const ownerBalance = await prime.balanceOf(owner.address);

            await prime.transfer(otherAccount.address, 1000);
            let otherAccountBalance = await prime.balanceOf(otherAccount.address)
            
            expect(otherAccountBalance).to.equal(1000);

        })
    })

})

describe("Vault", function() {

    async function deployPrimeFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, addr1] = await ethers.getSigners();
    
        const Prime = await ethers.getContractFactory("Prime");
        const prime = await Prime.deploy();

        const Pusd = await ethers.getContractFactory("PUSD");
        const pusd = await Pusd.deploy();

        const Vault = await ethers.getContractFactory("Vault");
        const vault = await Vault.deploy(prime.address, pusd.address);
    
        return { Prime, prime, Pusd, pusd, Vault, vault, owner, addr1 };
    }

    describe("deposit and withdraw", function () {
        it("Should mint 1000 PRIME for address1", async function () {
            const { prime, owner, addr1 } = await loadFixture(deployPrimeFixture);

            await prime.transfer(addr1.address, 1000);
            let addr1Balance = await prime.balanceOf(addr1.address)
            
            expect(addr1Balance).to.equal(1000);

        })

        it("deposit 100 PRIME ", async function () {
            const { prime, pusd, vault, owner, addr1 } = await loadFixture(deployPrimeFixture);
            const ownerBalance = await prime.balanceOf(owner.address);

            await prime.transfer(addr1.address, 1000);
            await prime.connect(addr1).approve(vault.address, 100);
            await vault.connect(addr1).deposit(addr1.address, 100);
            
            let addr1VaultBalance = await vault.depositAmount(addr1.address);
            
            let addr1PrimeBalance = await prime.balanceOf(addr1.address)
            
            expect(addr1VaultBalance).to.equal(100);
            expect(addr1PrimeBalance).to.equal(900);

        })

        it("deposit 100 PRIME after one year", async function () {
            const { prime, pusd, vault, owner, addr1 } = await loadFixture(deployPrimeFixture);
            const ownerBalance = await prime.balanceOf(owner.address);

            await prime.transfer(addr1.address, 1000);
            await prime.connect(addr1).approve(vault.address, 100);
            await vault.connect(addr1).deposit(addr1.address, 100);
            
            
            const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
            const oneYearTime = (await time.latest()) + ONE_YEAR_IN_SECS;

            await time.increaseTo(oneYearTime);
            await prime.connect(addr1).approve(vault.address, 100);
            await vault.connect(addr1).deposit(addr1.address, 100);

            let addr1VaultDepositAmount = await vault.depositAmount(addr1.address);
            let addr1VaultInterestAmount = await vault.depositInterestAmount(addr1.address);

            console.log(addr1VaultDepositAmount);
            expect(addr1VaultDepositAmount).to.equal(200);
            console.log(addr1VaultInterestAmount);
            expect(addr1VaultInterestAmount).to.equal(1);
        })

        it("deposit 1000 PRIME and withdraw interest amount after two year", async function () {
            const { prime, pusd, vault, owner, addr1 } = await loadFixture(deployPrimeFixture);
            const ownerBalance = await prime.balanceOf(owner.address);

            await prime.transfer(addr1.address, 2000);
            await prime.connect(addr1).approve(vault.address, 1000);
            await vault.connect(addr1).deposit(addr1.address, 1000);
            await pusd.mint(vault.address, 1000);
            
            
            const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
            const twoYearTime = (await time.latest()) + ONE_YEAR_IN_SECS*2;

            await time.increaseTo(twoYearTime);

            await vault.connect(addr1).withdrawInterest(addr1.address);

            let addr1PUSDAmount = await pusd.balanceOf(addr1.address);

            expect(addr1PUSDAmount).to.equal(20);
        })
    })

   



})

