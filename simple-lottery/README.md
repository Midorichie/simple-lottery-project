# Simple Lottery Project

A simple lottery system on Stacks built with [Clarity](https://clarity-lang.org).  
Phase 2 introduces a fungible token (LOT) that participants use to buy lottery tickets. The contract follows the [SIP-010 fungible token trait](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md).

---

## Contracts

- **lottery.clar**  
  The main lottery logic. Players buy tickets using LOT tokens, and the contract randomly selects a winner when the lottery ends.

- **token.clar**  
  Implements the `LOT` fungible token (SIP-010 compliant). Used for ticket purchases and prize payouts.

- **sip-010-trait.clar**  
  Trait definition for SIP-010 fungible tokens. Both `lottery` and `token` depend on this.

---

## Setup

1. Install [Clarinet](https://docs.hiro.so/clarinet).
2. Clone this repository and enter the project folder:
   ```sh
   git clone <your-repo-url>
   cd simple-lottery-project
Run a syntax check:

sh
Copy
Edit
clarinet check
Usage
Deploying Contracts
Clarinet will deploy contracts in this order:

sip-010-trait

token

lottery

Token Contract (token.clar)
Mint LOT tokens:

clarity
Copy
Edit
(contract-call? .token mint u1000 tx-sender)
Check balance:

clarity
Copy
Edit
(contract-call? .token get-balance tx-sender)
Lottery Contract (lottery.clar)
Set ticket price (owner only):

clarity
Copy
Edit
(contract-call? .lottery set-ticket-price u10)
Set token contract (owner only):

clarity
Copy
Edit
(contract-call? .lottery set-token-contract .token)
Buy ticket:

clarity
Copy
Edit
(contract-call? .lottery buy-ticket)
End lottery (owner only):

clarity
Copy
Edit
(contract-call? .lottery end-lottery)
→ Transfers all LOT tokens in the prize pool to the randomly selected winner.

View participants:

clarity
Copy
Edit
(contract-call? .lottery get-participants)
Security Enhancements in Phase 2
Enforces a maximum of 1000 participants.

Uses SIP-010 trait for secure token interactions.

Explicit owner-only functions for administrative actions.

Error handling for failed transfers and empty participant lists.

Next Steps (Phase 3 idea)
Add support for multiple rounds of lotteries.

Allow configurable max participants.

Integrate with a frontend for users to interact easily.
