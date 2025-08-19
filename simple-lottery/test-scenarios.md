# Testing Scenarios for Lottery Phase 3

## Setup Commands
```clarity
;; Deploy and setup
::deploy_contracts

;; Set up token contract
(contract-call? .lottery set-token-contract .token)

;; Mint tokens for testing
(contract-call? .token mint u1000 tx-sender)
(contract-call? .token mint u1000 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
(contract-call? .token mint u1000 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

## Test Case 1: Normal Operation Flow
```clarity
;; Check initial state
(contract-call? .lottery get-lottery-info)
;; Expected: lottery is active, 0 participants, round 1

;; Buy first ticket
(contract-call? .lottery buy-ticket .token)
;; Expected: (ok true)

;; Check updated state
(contract-call? .lottery get-participant-count)
;; Expected: u1

;; Check token balance decreased
(contract-call? .token get-balance tx-sender)
;; Expected: u990 (1000 - 10 ticket price)
```

## Test Case 2: Security - Duplicate Participation
```clarity
;; Buy first ticket (should work)
(contract-call? .lottery buy-ticket .token)
;; Expected: (ok true)

;; Try to buy second ticket (should fail)
(contract-call? .lottery buy-ticket .token)
;; Expected: (err u108) - ERR-ALREADY-PARTICIPATED
```

## Test Case 3: Max Participants Configuration
```clarity
;; Set low max participants for testing
(contract-call? .lottery set-max-participants u2)
;; Expected: (ok true)

;; Add first participant
(contract-call? .lottery buy-ticket .token)
;; Expected: (ok true)

;; Add second participant (different address)
(as-contract (contract-call? .lottery buy-ticket .token))
;; Expected: (ok true)

;; Try to add third participant (should fail)
(contract-call? .lottery buy-ticket .token)
;; Expected: (err u106) - ERR-MAX-PARTICIPANTS-REACHED
```

## Test Case 4: Invalid Parameters
```clarity
;; Try to set invalid ticket price
(contract-call? .lottery set-ticket-price u0)
;; Expected: (err u110) - ERR-INVALID-TICKET-PRICE

;; Try to set invalid max participants
(contract-call? .lottery set-max-participants u0)
;; Expected: (err u107) - ERR-INVALID-MAX-PARTICIPANTS

(contract-call? .lottery set-max-participants u10001)
;; Expected: (err u107) - ERR-INVALID-MAX-PARTICIPANTS
```

## Test Case 5: Insufficient Balance
```clarity
;; Create address with insufficient balance
;; (assume new address with 0 tokens)

;; Try to buy ticket without enough tokens
(contract-call? .lottery buy-ticket .token)
;; Expected: (err u109) - ERR-INSUFFICIENT-BALANCE
```

## Test Case 6: Authorization Tests
```clarity
;; Try admin function as non-owner
(as-contract (contract-call? .lottery set-ticket-price u20))
;; Expected: (err u100) - ERR-NOT-OWNER

;; Owner sets ticket price (should work)
(contract-call? .lottery set-ticket-price u20)
;; Expected: (ok true)
```

## Test Case 7: Lottery Ending
```clarity
;; Setup: Add participants
(contract-call? .lottery buy-ticket .token)

;; End lottery
(contract-call? .lottery end-lottery .token)
;; Expected: (ok <winner-principal>)

;; Try to buy ticket after lottery ended
(contract-call? .lottery buy-ticket .token)
;; Expected: (err u101) - ERR-NOT-ACTIVE
```

## Test Case 8: Emergency Functions
```clarity
;; Emergency pause
(contract-call? .lottery emergency-pause)
;; Expected: (ok true)

;; Try to buy ticket while paused
(contract-call? .lottery buy-ticket .token)
;; Expected: (err u101) - ERR-NOT-ACTIVE

;; Start new lottery
(contract-call? .lottery start-new-lottery)
;; Expected: (ok true)

;; Check round incremented
(contract-call? .lottery get-lottery-round)
;; Expected: u2
```

## Test Case 9: Ownership Transfer
```clarity
;; Transfer ownership
(contract-call? .lottery transfer-ownership 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
;; Expected: (ok true)

;; Check new owner
(contract-call? .lottery get-owner)
;; Expected: 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5

;; Old owner tries admin function (should fail)
(contract-call? .lottery set-ticket-price u30)
;; Expected: (err u100) - ERR-NOT-OWNER
```

## Test Case 10: Round-based Participation
```clarity
;; Buy ticket in round 1
(contract-call? .lottery buy-ticket .token)
;; Expected: (ok true)

;; Start new lottery (round 2)
(contract-call? .lottery start-new-lottery)

;; Same address should be able to participate in round 2
(contract-call? .lottery buy-ticket .token)
;; Expected: (ok true)
```

## Performance Tests

### Max Participants Test
```clarity
;; Set max participants to 1000
(contract-call? .lottery set-max-participants u1000)

;; Test with multiple participants (simulate)
;; Check gas costs and performance
```

### Large Prize Pool Test
```clarity
;; Mint large amount to contract
(contract-call? .token mint u1000000 (as-contract tx-sender))

;; Test winner selection with large prize
;; Verify correct transfer amounts
```

## Expected Results Summary

| Test Case | Expected Result | Error Code |
|-----------|----------------|------------|
| Normal flow | Success | - |
| Duplicate participation | Failure | u108 |
| Max participants reached | Failure | u106 |
| Invalid ticket price (0) | Failure | u110 |
| Invalid max participants | Failure | u107 |
| Insufficient balance | Failure | u109 |
| Non-owner admin call | Failure | u100 |
| Inactive lottery participation | Failure | u101 |
| Empty lottery end | Failure | u103 |
| Ownership transfer | Success | - |
| New round participation | Success | - |

## Debugging Tips

1. **Check error codes**: Match returned errors with documented codes
2. **Verify balances**: Ensure sufficient tokens before operations
3. **Check permissions**: Confirm caller has required privileges
4. **State verification**: Use read-only functions to check contract state
5. **Round tracking**: Verify correct round number for participant status
