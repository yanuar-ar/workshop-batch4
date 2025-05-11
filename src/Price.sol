// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract Price {
    address quoteFeed = 0x6ce185860a4963106506C203335A2910413708e9; // BTC/USD
    address baseFeed = 0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3; // USDC/USD

    function getPrice() public view returns (uint256) {
        // BTC/USD
        (, int256 quotePrice,,,) = IAggregatorV3(quoteFeed).latestRoundData();
        // USDC/USD
        (, int256 basePrice,,,) = IAggregatorV3(baseFeed).latestRoundData();

        // formula harga BTC dalam USDC = quotePrice * 1e6 / basePrice
        return uint256(quotePrice) * 1e6 / uint256(basePrice);
    }
}
