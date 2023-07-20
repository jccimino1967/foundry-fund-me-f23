// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {

    uint256 testNumero = 1;
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 (17ceros)
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    address USER = makeAddr("user");

    FundMe public fundMe;
    HelperConfig public helperConfig;

    function setUp() external {
        testNumero = 2;
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe,helperConfig) = deployFundMe.run(); 
        vm.deal(USER,STARTING_BALANCE);
        
    }

    function testMinimunDollarIsFive() public {
        assertEq( fundMe.MINIMUM_USD(), 5e18);

    }

    function testDemo() public {
        console.log(testNumero);
        console.log("Hola!");
        assertEq(testNumero,2);
    }

    function testOwnerIsMsgSender() public {
        console.log(address(this));
        console.log(msg.sender);
        console.log(fundMe.getOwner());
        // assertEq(fundMe.i_owner(), address(this));   
        assertEq(fundMe.getOwner(), msg.sender );                 
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 vversion = fundMe.getVersion();
        console.log(vversion);
        console.log(4);
        assertEq( vversion, 4 );
    }
    
    function testFundFailsWithoutEnougthETH() public {
        vm.expectRevert(); // O sea, que la linea de abajo deberia hacer Revert
        // Assert(TX falla/Revert)
        fundMe.fund(); // Asi, sin valores, se asume un fund(0)
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // La proxima TX sera enviada por USER 
                        // Se configura USER solo para testing
        fundMe.fund{value: SEND_VALUE }();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE }();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithDraw() public funded {
        //vm.prank(USER);
        //fundMe.fund{value: SEND_VALUE };

        //vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithAsSingleFunder() public funded {
        // Arrange - Ordenar
        // Por ejemplo, cual es el balance antes del retiro
        uint256 startingOwnerBalance = fundMe.getOwner().balance;  // Balance del dueño
        uint256 startingFundMeBalance = address(fundMe).balance;   // Balance del contrato Fundme

        // Act - Actuar
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = ( gasStart - gasEnd ) * tx.gasprice;

        console.log(gasStart);  // Cantidad de gas que tenemos al comienzo de la funcion
        console.log(gasEnd);    // Cantidad al terminar
        console.log(gasUsed);
        console.log(tx.gasprice);




        // Assert - Afirmar
        uint256 endingOwnerBalance =  fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0); // Para el cero no se necesitan numeros magicos
        assertEq(startingFundMeBalance+startingOwnerBalance, endingOwnerBalance);
    }

    function testWithDrawFromMultipleFunders() public funded {
        
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        // Act
        for(uint160 i = startingFunderIndex; i > numberOfFunders; i++ ) {
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance =  fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert - Afirmar
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);

    }

 function testWithDrawFromMultipleFundersCheaper() public funded {
        
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        // Act
        for(uint160 i = startingFunderIndex; i > numberOfFunders; i++ ) {
            // vm.prank new address
            // vm.deal new address
            // address()
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance =  fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw1();
        vm.stopPrank();

        // Assert - Afirmar
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);

    }
}