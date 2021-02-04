#  ERC721 & Bonding Curve
This experiment is a playground for the development of unique PROPERTY tokens for the Realestate. We use [Truffle](https://github.com/trufflesuite/truffle) as a development environment for compiling, testing, and deploying our contracts. They were written in [Solidity](https://github.com/ethereum/solidity).


# Idea
The idea is for an owner to purchase a retail PROPERTY whose price follows a bonding curve. An owner can only own one PROPERTY 
token, preventing anyone from gaining control of the entire mall by purchasing all the PROPERTY available
<br/><br/>


# PROPERTY Token
The PROPERTY token is created in the RealestateToken.sol file. It follows a basic ERC721 implementation with nothing unique in particular. <br/>
However, to achieve the unique one-of-a-kind ownership and restriction, the ERC721 tokenID is based a *keccak256 hash* of the owner's
address, making it impossible for an owner to mint an ERC721 token twice.
<br/><br/>

# Estate Agent
The EstateAgent houses the bonding curve function as well as purchasing and selling of PROPERTY tokens. <br />
Since the PROPERTY tokens have to be minted only when a buyer exists, the bonding curve requires a slight modification to its implementation. It allows for continuous minting of tokens but only up to a certain threshold which is declared during initialization under *_currentLimit*.

# Rental Agent
Handles the renting of PROPERTY tokens. Each rental lasts for **1 year** and will cost 1/10 of the current PROPERTY purchase price.

# Admin
Handles adding/removing admins from control of the contract


# Pre Requisites
# Install node Modules
```bash
$ npm install
```
 Usage

```bash
truffle compile --all
truffle migrate --network development
```

Make sure to have a running [Ganache](https://truffleframework.com/ganache) instance in the background.

### Test

```bash
$ npm run test
```
