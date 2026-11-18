# Agent Pioneer Badge

A free, gas-only ERC-721 badge for the earliest **SPACE ID Agent ID** holders on BNB Chain. Any wallet holding an Agent ID can claim exactly one badge, directly from the contract — no payment, no allowlist, no signup.

Built for the **Agent ID Hackathon** (Binance).

## Live

- **Claim page:** https://muse.ai/s/agent-pioneer-badge-ixf6xn56xntpt6/jxlcgidC1MtVAOLm5Dkr5DOE_qqwoOAvUlv_8go_gA0
- **Contract (BSC):** [`0x6FBBe75e2111f8216737f5cf07D35b4F2474db95`](https://bscscan.com/address/0x6FBBe75e2111f8216737f5cf07D35b4F2474db95) — source verified on BscScan (Exact Match)
- **Demo video:** https://youtu.be/5qH2OWhVIJg

## How Agent ID is used

The contract reads the SPACE ID Agent ID contract (`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`) on-chain. `claim()` checks `balanceOf(caller) > 0` on that contract, so only Agent ID holders can claim — the Agent ID itself is the identity credential and the access control. One badge per wallet, enforced by a `claimed` mapping. Max supply is 1,000.

## Contract

- `contracts/AgentPioneerBadge.sol` — OpenZeppelin ERC-721, Solidity 0.8.38, no optimizer, EVM Osaka.
- Immutable by design: **no owner, no pause, no upgrade, no withdraw, no fees.** The only state-changing function is `claim()`.
- `claim()` reverts with `NotAgentIdHolder()` for non-holders, `AlreadyClaimed()` on a second claim, and `MaxSupplyReached()` after 1,000 badges.

## Tests

```bash
forge test
```

9 tests, all passing (claim flow, gate, one-per-wallet, supply cap, gas).

## Claim page

`frontend/index.html` is the self-contained claim page (no external dependencies): it detects an injected wallet, checks Agent ID ownership, and calls `claim()` on the contract.

## License

MIT
