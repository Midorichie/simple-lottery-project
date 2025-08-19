# Simple Lottery Project - Phase 3

A secure and configurable lottery system built on Stacks blockchain using SIP-010 fungible tokens.

## Overview

This project implements a decentralized lottery system where participants can buy tickets using SIP-010 fungible tokens. The system includes enhanced security features, configurable parameters, and comprehensive error handling.

## Features

### Phase 3 Enhancements
- **Bug Fixes**: Fixed duplicate participation and token validation issues
- **Configurable Max Participants**: Dynamic participant limits (1-10,000)
- **Enhanced Security**: 
  - Prevents duplicate ticket purchases per round
  - Token contract validation
  - Balance checks before transactions
  - Emergency controls for owner
  - Ownership transfer capability
- **Better Randomness**: Improved winner selection using block height + round number
- **Comprehensive Error Handling**: 11 distinct error codes for different scenarios

### Core Features
- **SIP-010 Token Integration**: Uses fungible tokens for all transactions
- **Fair Winner Selection**: Cryptographically secure randomness
- **Transparent Operations**: All lottery data is publicly readable
- **Owner Controls**: Administrative functions for lottery management
- **Round-based System**: Track multiple lottery rounds with unique identifiers

## Smart Contracts

### 1. lottery.clar
Main lottery contract with the following functions:

#### Admin Functions
- `transfer-ownership(new-owner)` - Transfer contract ownership
- `set-ticket-price(new-price)` - Update ticket price (must be > 0)
- `set-max-participants(new-max)` - Set participant limit (1-10,000)
- `set-token-contract(contract)` - Authorize token contract
- `emergency-pause()` - Pause lottery operations
- `start-new-lottery()` - Begin new lottery round
- `emergency-withdraw(token, amount)` - Emergency fund recovery

#### Public Functions
- `buy-ticket(token)` - Purchase lottery ticket
- `end-lottery(token)` - End current lottery and select winner

#### Read-Only Functions
- `get-lottery-info()` - Complete lottery status
- `get-participants()` - List of participants
- `get-participant-count()` - Number of participants
- `is-active()` - Lottery status
- `get-lottery-round()` - Current round number

### 2. token.clar
SIP-010 compliant fungible token for lottery operations:
- Token symbol: "LOT"
- Token name: "Lottery Token"
- Decimals: 6
- Mintable by contract deployer

### 3. sip-010-trait.clar
Standard SIP-010 trait definition for token interoperability.

## Security Features

### Access Control
- Owner-only functions for administrative operations
- Token contract validation to prevent unauthorized tokens
- Emergency pause functionality

### Duplicate Prevention
- Tracks participant status per lottery round
- Prevents multiple ticket purchases by same address
- Round-based participant tracking

### Financial Security
- Balance verification before token transfers
- Failed transaction rollback
- Emergency withdrawal capability
- Transfer validation and error handling

### Enhanced Randomness
- Uses block height + round number for winner selection
- Prevents predictable outcomes
- Fair distribution across all participants

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| 100 | ERR-NOT-OWNER | Caller is not contract owner |
| 101 | ERR-NOT-ACTIVE | Lottery is not active |
| 102 | ERR-LOTTERY-ENDED | Lottery has already ended |
| 103 | ERR-NO-PARTICIPANTS | No participants in lottery |
| 104 | ERR-TRANSFER-FAILED | Token transfer failed |
| 105 | ERR-BALANCE-FAILED | Balance check failed |
| 106 | ERR-MAX-PARTICIPANTS-REACHED | Maximum participants reached |
| 107 | ERR-INVALID-MAX-PARTICIPANTS | Invalid max participants value |
| 108 | ERR-ALREADY-PARTICIPATED | Already participated in current round |
| 109 | ERR-INSUFFICIENT-BALANCE | Insufficient token balance |
| 110 | ERR-INVALID-TICKET-PRICE | Invalid ticket price (cannot be 0) |
| 111 | ERR-UNAUTHORIZED-TOKEN | Token contract not authorized |

## Usage Examples

### Deploy and Setup
```clarity
;; Deploy contracts
;; Set token contract
(contract-call? .lottery set-token-contract .token)

;; Set ticket price to 100 tokens
(contract-call? .lottery set-ticket-price u100)

;; Set max participants to 500
(contract-call? .lottery set-max-participants u500)
```

### Mint Tokens
```clarity
;; Mint 1000 tokens to player
(contract-call? .token mint u1000 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Buy Ticket
```clarity
;; Purchase lottery ticket
(contract-call? .lottery buy-ticket .token)
```

### Check Status
```clarity
;; Get complete lottery information
(contract-call? .lottery get-lottery-info)

;; Check if address participated
(contract-call? .lottery has-participated 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### End Lottery
```clarity
;; Owner ends lottery and selects winner
(contract-call? .lottery end-lottery .token)
```

## Testing

### Prerequisites
- Clarinet CLI installed
- Stacks blockchain development environment

### Run Tests
```bash
# Check contract syntax
clarinet check

# Run integration tests
clarinet console

# Test scenarios in REPL
(contract-call? .token mint u1000 tx-sender)
(contract-call? .lottery buy-ticket .token)
(contract-call? .lottery get-lottery-info)
```

### Test Scenarios
1. **Normal Operation**: Deploy → Mint tokens → Buy tickets → End lottery
2. **Security Tests**: Duplicate participation, unauthorized access
3. **Edge Cases**: Zero participants, max participants reached
4. **Error Handling**: Invalid parameters, insufficient balance

## Deployment

### Local Development
```bash
# Start local blockchain
clarinet console

# Deploy all contracts
::deploy_contracts

# Interact with contracts
(contract-call? .lottery get-lottery-info)
```

### Testnet Deployment
```bash
# Configure testnet in Clarinet.toml
# Deploy using Clarinet
clarinet deploy --network testnet
```

## Configuration

### Customizable Parameters
- **Ticket Price**: Any positive integer value
- **Max Participants**: 1 to 10,000 participants
- **Token Contract**: Any SIP-010 compliant token
- **Owner Address**: Transferable ownership

### Default Settings
- Ticket Price: 10 tokens
- Max Participants: 1,000
- Initial State: Active
- Round: 1

## Changelog

### Phase 3 Improvements
- ✅ Fixed duplicate participation bug
- ✅ Added configurable max participants (1-10,000)
- ✅ Enhanced security with comprehensive validation
- ✅ Improved error handling with specific error codes
- ✅ Added round-based tracking system
- ✅ Implemented ownership transfer
- ✅ Added emergency controls
- ✅ Enhanced randomness for winner selection
- ✅ Updated documentation and configuration

### Previous Phases
- **Phase 2**: SIP-010 token integration
- **Phase 1**: Basic lottery functionality

## Contributing

1. Fork the repository
2. Create feature branch
3. Add comprehensive tests
4. Update documentation
5. Submit pull request

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
- Check error codes in documentation
- Review test scenarios
- Submit GitHub issues with detailed reproduction steps
