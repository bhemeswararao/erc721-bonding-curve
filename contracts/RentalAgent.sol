// SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import './EstateAgent.sol';
import './RealestateToken.sol';

contract RentalAgent is Administration{

    //TEMPORARY Multiplier to get price in 10 Finney
    uint256 private _multiplier = 10000000000000000;

    //Holds current detals about the PROPERTY
    struct PropertyDetails {
        address rightfulOwner;
        address rentedTo;
        uint256 rentalEarned;
        uint256 expiryBlock;
    }

    //Mapping of tokenId to PropertyDetails
    mapping(uint256 => PropertyDetails) public propertyInfo;

    //Holds the address of the deployed token
    RealestateToken public token;

    //Holds the address of the EstateAgent
    EstateAgent public estateAgent;

    event SetToken(address _newContract);
    event SetAgent(address _newContract);
    event Deposit(address from, uint256 tokenId);
    event Rented(address renter, uint256 tokenId, uint256 rentPrice);
    event ClaimRent(address owner, uint256 amount, uint256 toClaim);
    event Withdraw(address to, uint256 tokenId);

    constructor(RealestateToken _token, EstateAgent _estateAgent) public {
        token = _token;
        estateAgent = _estateAgent;
    }

    /**
     * @dev Set token address
     * @param _token the address of the newly deployed PROPERTY token
     * In case if token address ever changes, we can set this contract to point there
     */
    function setToken(RealestateToken _token) external onlyAdmin {
        token = _token;
        emit SetToken(address(_token));
    }

    /**
     * @dev Set EstateAgent address
     * @param _estateAgent the address of the EstateAgent
     */
    function setAgent(EstateAgent _estateAgent) external onlyAdmin {
        estateAgent = _estateAgent;
        emit SetAgent(address(_estateAgent));
    }

    /**
    * @dev Deposit the PROPERTY token to this contract
    * @param tokenId ID of the token to check
    * @notice need to write an approve method
    **/
    function deposit(uint256 tokenId) public {
        require(token.verifyLegitimacy(msg.sender, tokenId) == true, "Fake token!");
        token.transferFrom(msg.sender, address(this), tokenId);

        //Register the rightful owner if first time user
        if(propertyInfo[tokenId].rightfulOwner == address(0)){
            propertyInfo[tokenId] = PropertyDetails(msg.sender, msg.sender, 0, 0);
        }
        emit Deposit(msg.sender, tokenId);
    }

    /**
    * @dev Withdraw the PROPERTY token from this contract
    * @param tokenId ID of the token to check
    * @notice this will withdraw both the rental earned and the PROPERTY token
    **/
    function withdrawProperty(uint256 tokenId) public {
        require(
            propertyInfo[tokenId].expiryBlock < block.number &&
            propertyInfo[tokenId].rightfulOwner == msg.sender, "Token is rented / Not owner!"
        );
        address payable owner = msg.sender;
        claimRent(owner, tokenId);
        token.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /**
    * @dev Allows users to rent a PROPERTY token of choice
    * @param tokenId ID of the token to check
    * @notice rent cost 1/10 of the price to buy new & lasts for 1 year (2252571 blocks)
    **/
    function rent(uint256 tokenId) public payable{
        require(propertyInfo[tokenId].expiryBlock < block.number, "Token is already rented!");
        uint256 priceFinney = estateAgent.price(token.totalSupply()+1) * _multiplier;
        uint256 rentPrice = priceFinney / 10; //In wei
        require(msg.value >= (rentPrice * 1 wei), "Not enough funds!");
        propertyInfo[tokenId].rentedTo = msg.sender;
        propertyInfo[tokenId].rentalEarned += rentPrice;
        propertyInfo[tokenId].expiryBlock = block.number + 2252571;
        emit Rented(msg.sender, tokenId, rentPrice);
    }

    /**
    * @dev Claim the rent earned
    * @param tokenId id of the PROPERTY token
    * @notice Owner can claim rent right on Day 1 of renting
    **/
    function claimRent(address payable owner, uint256 tokenId) public {
        require(propertyInfo[tokenId].rightfulOwner == owner, "Not owner!");
        uint256 toClaim = propertyInfo[tokenId].rentalEarned;
        require(balance() >= toClaim, "Not enough funds to pay!");
        propertyInfo[tokenId].rentalEarned -= toClaim;
        owner.transfer(toClaim * 1 wei);
        emit ClaimRent(owner, tokenId, toClaim);
    }

    /**
    * @dev Check who has the rights to use the token currently
    * @param tokenId ID of the token to check
    * @return the address of who can use the PROPERTY
    **/
    function checkDelegatedOwner(uint256 tokenId) public view returns (address) {
        //Check if the token is being rented
        if(propertyInfo[tokenId].expiryBlock >= block.number){
            //Since rented, the current owner (have the right to use the PROPERTY) is the renter
            return propertyInfo[tokenId].rentedTo;
        } else {
            //Token is not rented, it either exists in this contract, or is held by the owner
            address currentOwner = token.ownerOf(tokenId);
            if(currentOwner == address(this)){
                //Token is here! Time to check propertyInfo
                return propertyInfo[tokenId].rightfulOwner;
            } else {
                return currentOwner;
            }
        }
    }

    /**
     * @dev Get balance
     * @return balance in RentalAgent contract
     */
    function balance() public view returns(uint256){
        address self = address(this);
        return self.balance;
    }
}
