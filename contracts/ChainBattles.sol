// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// Contract Deployed:  0x781d5b1Ea3D9a9D3A406C0DAD512a22b3B9eC131

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 randomseed = 0;
    struct Attributes {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }
    mapping(uint256 => Attributes) public tokenIdtoLevels;

    constructor() ERC721("Chain Battles", "CHBTLS") {}

    //FUNCTION - getRandom
    // A function to create random numbers by using
    // block.timestamp and block.difficulty
    function getRandom(uint256 number) public returns (uint256) {
        if (randomseed > 100) {
            randomseed = 0;
        }
        randomseed++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        randomseed,
                        msg.sender
                    )
                )
            ) % number;
    }

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        //It's concatanate strings to create nft
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="start">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="start">',
            "Level: ",
            getLevels(tokenId).level.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="start">',
            "Speed: ",
            getLevels(tokenId).speed.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="start">',
            "Strength: ",
            getLevels(tokenId).strength.toString(),
            "</text>",
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="start">',
            "life: ",
            getLevels(tokenId).life.toString(),
            "</text>",
            "</svg>"
        );
        //This will create the svg dynamicly with base34 encoder...
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    //getLevels takes tokenId and returns the levels in attribute format
    function getLevels(uint256 tokenId)
        public
        view
        returns (Attributes memory)
    {
        Attributes memory attribute;

        attribute.level = tokenIdtoLevels[tokenId].level;
        attribute.speed = tokenIdtoLevels[tokenId].speed;
        attribute.strength = tokenIdtoLevels[tokenId].strength;
        attribute.life = tokenIdtoLevels[tokenId].life;
        return (attribute);
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        //As below you can see that its just concatanate the strings to create json object
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Michellez Chain Battles",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        //increase token id so token id start from 1
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        //newItemId will start from level 0
        tokenIdtoLevels[newItemId].level = 0;
        // _setTokenURI function came from ERC721URIStorage contract...
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it!"
        );
        uint256 currentLevel = tokenIdtoLevels[tokenId].level;
        tokenIdtoLevels[tokenId].level = currentLevel + 1;
        tokenIdtoLevels[tokenId].speed += getRandom(100);
        tokenIdtoLevels[tokenId].strength += getRandom(100);
        tokenIdtoLevels[tokenId].life += getRandom(100);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
