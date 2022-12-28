pragma solidity ^0.8.3;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../LosGame.sol";

contract TestLosGame {
  LosGame losGame = LosGame(DeployedAddresses.LosGame());

  function testAddPlayer() public {
    address player1 = msg.sender;
    uint value = 10;
    Assert.equal(losGame.addPlayer.value(value)(), 1, "Player was not added to the contract");
    
    Assert.emits(losGame, "Added", (address player) => { return player == player1; }, "Added event was not emitted");

    Assert.reverts(losGame.addPlayer.value(value + 1)(), "invalid value");

    address player2 = address(uint160(1));
    Assert.equal(losGame.addPlayer.value(value)(), 2, "Player was not added to the contract");
    Assert.reverts(losGame.addPlayer.value(value)(), "Cannot add player to full game");
  }

  function testStartShowing() public {
    bytes32 step = hex"1234567890";
    Assert.equal(losGame.startShowing(step), true, "Player was not able to start showing their step");

    Assert.emits(losGame, "Show", (address player) => player == msg.sender, "Show event was not emitted");

    address player2 = address(uint160(1));
    Assert.reverts(losGame.startShowing(step, {from: player2}), "Not your turn to show");

    losGame.addPlayer.value(10)();
    Assert.reverts(losGame.startShowing(step), "Other player has not yet joined the game");
  }

  function testGetingResults() public {
    uint256 symbol = 3;
    string memory pad = "abcdef";
    Assert.equal(losGame.getingResults(symbol, pad), true, "Player was not able to submit their symbol and pad");

    Assert.emits(losGame, "ShowToOtherPlayers", (address player, uint256 playerSymbol) => player == msg.sender && playerSymbol == symbol, "ShowToOtherPlayers event was not emitted");

    address player2 = address(uint160(1));
    Assert.reverts(losGame.getingResults(symbol, pad, {from: player2}), "Not your turn to show results");

    Assert.reverts(losGame.getingResults(symbol + 1, pad), "Invalid symbol");
    Assert.reverts(losGame.getingResults(symbol, "invalid pad"), "Invalid pad");
  }
}
