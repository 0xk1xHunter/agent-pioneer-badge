// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AgentPioneerBadge} from "../src/AgentPioneerBadge.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @notice Minimal ERC-721 mimicking the Agent ID contract's balanceOf.
///         Real Agent ID is non-transferable; the mock keeps a simple
///         mint-to-address helper for tests only.
contract MockAgentId is ERC721 {
    uint256 private _nextId = 1;

    constructor() ERC721("Mock Agent ID", "MAID") {}

    function mintTo(address to) external returns (uint256 tokenId) {
        tokenId = _nextId++;
        _mint(to, tokenId);
    }
}

contract AgentPioneerBadgeTest is Test {
    AgentPioneerBadge public badge;
    MockAgentId public agentId;

    address public holder = makeAddr("holder");
    address public nonHolder = makeAddr("nonHolder");
    address public secondHolder = makeAddr("secondHolder");

    function setUp() public {
        agentId = new MockAgentId();
        badge = new AgentPioneerBadge(address(agentId));
        agentId.mintTo(holder);
        agentId.mintTo(secondHolder);
    }

    function test_NameAndSymbol() public view {
        assertEq(badge.name(), "Agent Pioneer Badge");
        assertEq(badge.symbol(), "APB");
    }

    function test_HolderCanClaimOnce() public {
        vm.prank(holder);
        badge.claim();
        assertEq(badge.balanceOf(holder), 1);
        assertEq(badge.ownerOf(1), holder);
        assertEq(badge.totalMinted(), 1);
        assertTrue(badge.claimed(holder));
    }

    function test_NonHolderReverts() public {
        vm.prank(nonHolder);
        vm.expectRevert(AgentPioneerBadge.NotAgentIdHolder.selector);
        badge.claim();
    }

    function test_SecondClaimReverts() public {
        vm.prank(holder);
        badge.claim();
        vm.prank(holder);
        vm.expectRevert(AgentPioneerBadge.AlreadyClaimed.selector);
        badge.claim();
    }

    function test_HolderWithTwoAgentIdsStillGetsOneBadge() public {
        // Holder owns 2 Agent IDs: per-wallet rule still allows exactly 1 badge.
        agentId.mintTo(holder);
        assertEq(agentId.balanceOf(holder), 2);
        vm.prank(holder);
        badge.claim();
        assertEq(badge.balanceOf(holder), 1);
        vm.prank(holder);
        vm.expectRevert(AgentPioneerBadge.AlreadyClaimed.selector);
        badge.claim();
    }

    function test_SupplyCapEnforced() public {
        // Mint 999 badges to 999 distinct holders, then the 1000th, then cap.
        for (uint256 i = 0; i < 999; i++) {
            address h = makeAddr(string(abi.encodePacked("cap-holder-", i)));
            agentId.mintTo(h);
            vm.prank(h);
            badge.claim();
        }
        assertEq(badge.totalMinted(), 999);
        vm.prank(secondHolder);
        badge.claim();
        assertEq(badge.totalMinted(), 1000);

        address late = makeAddr("late-holder");
        agentId.mintTo(late);
        vm.prank(late);
        vm.expectRevert(AgentPioneerBadge.MaxSupplyReached.selector);
        badge.claim();
    }

    function test_ClaimMintsSequentialTokenIds() public {
        vm.prank(holder);
        badge.claim();
        vm.prank(secondHolder);
        badge.claim();
        assertEq(badge.ownerOf(1), holder);
        assertEq(badge.ownerOf(2), secondHolder);
    }

    function test_ZeroAgentIdAddressReverts() public {
        vm.expectRevert(AgentPioneerBadge.ZeroAddress.selector);
        new AgentPioneerBadge(address(0));
    }
}
