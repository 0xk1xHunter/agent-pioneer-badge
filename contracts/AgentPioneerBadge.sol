// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title Agent Pioneer Badge
/// @notice Free ERC-721 badge, claimable once per Agent ID holder.
///         A caller is a holder iff balanceOf(caller) > 0 on the
///         SPACE ID Agent ID contract (0x60b9262456de011f7d15a54cdd8c48baaa8b022f).
///         Gas only — no mint price, no fees, no admin functions.
///         Immutable: no owner, no pause, no upgrade, no withdraw.
contract AgentPioneerBadge is ERC721 {
    /// @notice SPACE ID Agent ID contract (ERC-721, non-transferable).
    IERC721 public immutable agentId;

    /// @notice Maximum badges that can ever exist.
    uint256 public constant MAX_SUPPLY = 1000;

    /// @notice Number of badges minted so far. Token IDs run 1..MAX_SUPPLY.
    uint256 public totalMinted;

    /// @notice True once an address has claimed its one badge.
    mapping(address => bool) public claimed;

    error ZeroAddress();
    error NotAgentIdHolder();
    error AlreadyClaimed();
    error MaxSupplyReached();

    constructor(address agentId_) ERC721("Agent Pioneer Badge", "APB") {
        if (agentId_ == address(0)) revert ZeroAddress();
        agentId = IERC721(agentId_);
    }

    /// @notice Claim the caller's single free badge. Gas only.
    function claim() external {
        if (agentId.balanceOf(msg.sender) == 0) revert NotAgentIdHolder();
        if (claimed[msg.sender]) revert AlreadyClaimed();
        if (totalMinted >= MAX_SUPPLY) revert MaxSupplyReached();

        claimed[msg.sender] = true;
        totalMinted += 1;
        _safeMint(msg.sender, totalMinted);
    }
}
