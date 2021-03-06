//SPDX-License-Identifier: MIT
pragma solidity ^0.6.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/** @title Realestate PROPERTY token
  * @notice PROPERTY follows an ERC721 implementation
  * @dev Only one address can hold one PROPERTY token as the tokenID is a hash of the buyer's address
  */
contract RealestateToken is ERC721 {
    //Holds address of the EstateAgent
    address private _agent;

    //Ensures only the EstateAgent can mint/burn token
    modifier onlyAgent {
        require(msg.sender == _agent, "Not an agent!");
        _;
    }

    constructor(address agent) ERC721("Realestate Property Token", "PROPERTY") public {
        _agent = agent;
    }

    /**
     * @dev Mint a token
     * @param purchaser address who purchase the PROPERTY token
     * @notice only the EstateAgent can call this function to prevent scams
     * @return id of the token minted
     */
    function mint(address purchaser) public onlyAgent returns(uint256){
        uint256 tokenId = uint256(keccak256(abi.encodePacked(purchaser)));
        _safeMint(purchaser, tokenId, "");
        return (tokenId);
    }

    /**
     * @dev Burn a token
     * @param tokenId id of the token to burn
     */
    function burn(uint256 tokenId) public onlyAgent{
        _burn(tokenId);
    }

    /**
     * @dev Verify if a token is legitimate (bought through the EstateAgent)
     * @param sender the address which initiated the action
     * @param tokenId id of the token to check
     */
    function verifyLegitimacy(address sender, uint256 tokenId) public view returns (bool) {
        return _exists(tokenId) && ownerOf(tokenId) == sender;
    }
}