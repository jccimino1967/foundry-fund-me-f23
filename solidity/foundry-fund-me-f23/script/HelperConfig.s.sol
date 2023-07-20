// SPDX-License-Identifier: MIT

// Funciones de este archivo :
// 1 - Despliega MOCKS ( imita una red ) en vez de una red local como anvil o ganache
// 2 - Podemos tener un registro de los contratos a traves de las diferentes redes
// SEPOLIA ETH/USD 
// MAINNET ETH/USD

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    
    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)

    struct NetworkConfig{
        address priceFeed; // Direccion del alimentador de precios
    }

    constructor() {
        
        if (block.chainid == 1115111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();    
        }

    } 

    // Si nosotros estamos en una red local como anvil, desplegamos mocks
    // Sino, tomamos la direccion del contrato existente en la red en vivo
    // MainNet, Sepolia, etc...

    function getSepoliaEthConfig() public pure returns ( NetworkConfig memory ) {
        // Direccion del alimentador de precios
        // Este es el contrato del par ETH/USD en Sepolia
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306}) ;
        return sepoliaConfig;
    }

   function getMainnetEthConfig() public pure returns ( NetworkConfig memory ) {
        // Direccion del alimentador de precios
        // Este es el contrato del par ETH/USD en Sepolia
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419}) ;
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns ( NetworkConfig memory ) {
        // Direccion del alimentador de precios
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1 - Desplegar el Mock ( contrato falso )
        // 2 - Retornar la direccion del contrato falso
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;

    }

}