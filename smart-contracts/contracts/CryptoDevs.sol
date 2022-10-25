// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    string _baseTokenURI;
    bool public presaleStarted;
    bool public _paused;
    uint256 public presaleEnded;
    uint256 public tokenIds;
    uint256 public maxTokenIds = 20;
    uint256 public _publicPrice = 0.01 ether;
    uint256 public _presalePrice = 0.005 ether;
    IWhitelist whitelist;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract)
        ERC721("Crypto Devs", "CDS")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp <= presaleEnded, "Presale ended");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not in the whitelist");
        require(tokenIds < maxTokenIds, "Exceeded the limit");
        require(msg.value >= _presalePrice, "Insufficient amount");

        tokenIds++;
        _safeMint(msg.sender, tokenIds);
    }

    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale has not ended");
        require(tokenIds < maxTokenIds, "Exceeded the limit");
        require(msg.value >= _publicPrice, "Insufficient amount");

        tokenIds++;
        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {
        (bool sent, ) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    fallback() external payable {
        (bool sent, ) = msg.sender.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}