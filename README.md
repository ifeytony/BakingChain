# BakingChain

A decentralized baking and pastry mastery reward system for incentivizing culinary baking excellence on Stacks blockchain.

## Features

- Baking activity tracking with duration-based rewards
- Baker pastry level progression with mastery bonus multipliers
- Baking token accumulation and redemption system
- Starter preservation mechanism with time-based penalties
- Comprehensive bakery statistics and analytics

## Smart Contract Functions

### Public Functions
- `start-baking-activity` - Begin baking session
- `complete-baking-batch` - Complete batch and earn rewards
- `claim-baking-rewards` - Claim accumulated baking tokens
- `preserve-starter` - Preserve starter for enhanced rewards
- `release-preserved-starter` - Release preserved starter with potential penalties

### Read-Only Functions
- `get-baking-activity-count` - Get user's total baking activities
- `get-baking-token-balance` - Get user's baking token balance
- `get-pastry-level` - Get user's pastry mastery level
- `get-bakery-stats` - Get overall bakery statistics

## Reward System
- Base reward: 22 tokens per batch
- Pastry bonus: 8 tokens per level (max level 12)
- Starter preservation multiplier: 4x for preserved starter
- Bakery capacity: 1.8M total tokens

## Usage

Deploy the contract to create a baking system where bakers can track their culinary activities, earn rewards, and preserve starter for enhanced benefits.

## License

MIT