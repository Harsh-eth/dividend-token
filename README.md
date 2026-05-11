# ERC20 Dividend Token

## What it does
A mintable ERC20 token where holders receive ETH dividend 
payments proportional to their token balance.

## Features
- Mint tokens by depositing ETH (1:1 ratio)
- Burn tokens to get ETH back
- Record dividends — distributed proportionally to all holders
- Withdraw dividends — preserved even after burning or transferring
- Efficient holder tracking — array + mapping pattern
- Swap-and-pop removal — O(1) gas efficiency

## Functions
- mint() — pay ETH, receive tokens
- burn(address dest) — burn tokens, send ETH to dest
- transfer / approve / transferFrom — standard ERC20
- recordDividend() — distribute ETH to all holders
- getWithdrawableDividend(address) — check pending dividends
- withdrawDividend(address dest) — claim your dividends
- getNumTokenHolders() — total holder count
- getTokenHolder(uint index) — holder address by index

## Security
- CEI pattern on all ETH transfers
- Swap-and-pop for O(1) holder removal
- SafeMath throughout (pragma 0.7.0)
- Dividend preserved after burn or transfer

## Live Deployment
Network: Base Mainnet
Address: 0x6B6105868fC74A054CED08fcc0Aa3AF0B81d888B
https://basescan.org/address/0x6B6105868fC74A054CED08fcc0Aa3AF0B81d888B
