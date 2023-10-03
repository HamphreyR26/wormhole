// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Implementation} from "../contracts/Implementation.sol";
import {Setup} from "../contracts/Setup.sol";
import {Wormhole} from "../contracts/Wormhole.sol";
import "forge-std/Script.sol";

contract DeployCore is Script {
    // DryRun - Deploy the system
    // dry run: forge script ./forge-scripts/DeployCore.s.sol:DeployCore --sig "dryRun()" --rpc-url $RPC
    function dryRun() public {
        _deploy();
    }

    // Deploy the system
    // deploy:  forge script ./forge-scripts/DeployCore.s.sol:DeployCore --sig "run()" --rpc-url $RPC --etherscan-api-key $ETHERSCAN_API_KEY --private-key $RAW_PRIVATE_KEY --broadcast --verify
    function run()
        public
        returns (
            address deployedAddress,
            address setupAddress,
            address implAddress
        )
    {
        vm.startBroadcast();
        (deployedAddress, setupAddress, implAddress) = _deploy();
        vm.stopBroadcast();
    }

    function _deploy()
        internal
        returns (
            address deployedAddress,
            address setupAddress,
            address implAddress
        )
    {
        Implementation impl = new Implementation();
        Setup setup = new Setup();

        address[] memory initialSigners = vm.envAddress(
            "INIT_SIGNERS_CSV",
            ","
        );
        uint16 chainId = uint16(vm.envUint("INIT_CHAIN_ID"));
        uint16 governanceChainId = uint16(vm.envUint("INIT_GOV_CHAIN_ID"));
        bytes32 governanceContract = bytes32(
            vm.envBytes32("INIT_GOV_CONTRACT")
        );
        uint256 evmChainId = vm.envUint("INIT_EVM_CHAIN_ID");

        Wormhole wormhole = new Wormhole(
            address(setup),
            abi.encodeCall(
                Setup.setup,
                (
                    address(impl),
                    initialSigners,
                    chainId,
                    governanceChainId,
                    governanceContract,
                    evmChainId
                )
            )
        );

        return (address(wormhole), address(setup), address(impl));
    }
}
