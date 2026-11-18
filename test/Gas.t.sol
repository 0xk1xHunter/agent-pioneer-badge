// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {AgentPioneerBadge} from "../src/AgentPioneerBadge.sol";
import {MockAgentId} from "./AgentPioneerBadge.t.sol";

/// @notice Measures exact deployment + claim gas so the README estimate
///         is a measured number, not a guess.
contract GasMeasurementTest is Test {
    function test_MeasureGas() public {
        MockAgentId agentId = new MockAgentId();
        address holder = makeAddr("gas-holder");
        agentId.mintTo(holder);

        uint256 beforeDeploy = gasleft();
        AgentPioneerBadge badge = new AgentPioneerBadge(address(agentId));
        uint256 deployGas = beforeDeploy - gasleft();
        console.log("DEPLOY_GAS", deployGas);

        uint256 beforeClaim = gasleft();
        vm.prank(holder);
        badge.claim();
        uint256 claimGas = beforeClaim - gasleft();
        console.log("CLAIM_GAS_FIRST", claimGas);

        // Sanity bounds — fail loudly if the contract ever gets bloated.
        assertLt(deployGas, 3_000_000);
        assertLt(claimGas, 200_000);
    }
}
