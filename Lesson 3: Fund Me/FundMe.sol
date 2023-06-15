// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {

    using SafeMathChainlink for uint256;

    mapping(address=>uint256) public addressToBalance; // current balance of funded addresses
    address[] public funders; // array of funders addresses
    bool containAddress;
    address public owner; // SC owner address

    constructor() public {
        owner = msg.sender;
    }
    
    function fund() public payable {

        //minimum quantity to be funded
        uint256 minToFund = 10**16;

        require(msg.value >= minToFund, "You need to pay more ETH");

        addressToBalance[msg.sender] += msg.value;
        
        containAddress = false; //reset containAddress

        //verify if address is already in the funders array, otherwise add it
        for (uint256 i=0; i < funders.length; i++) {
            if (msg.sender == funders[i]) {
                containAddress = true;
                break;
            }
        }
        if (containAddress == false) {funders.push(msg.sender);}

    }

    // function to get version in Sepolia Testnet ETH/USD price
    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
        0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        return priceFeed.version();
    }

    // function to get Sepolia Testnet ETH/USD price
    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
        0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        (,int256 answer,,,) = priceFeed.latestRoundData();
        
        return uint256(answer/(10**8));
    }

    function getConversionRate (uint256 ethAmount) public view returns(uint256) {
       uint256 ethPrice = getPrice();

       return (ethPrice*ethAmount);
    }

    // with this modifier we make sure that only the owner can execute this function
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the Owner");
        _;
    }

    function withdraw() public payable onlyOwner{
        msg.sender.transfer(address(this).balance);

        // iterate throgh all the mappings and make them 0
        for (uint i=0; i < funders.length; i++) {
            addressToBalance[funders[i]] = 0;
        }

        funders = new address[](0); // initialize funders array to 0
    }
    
}
