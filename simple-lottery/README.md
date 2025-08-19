# 🎟️ Simple Lottery (Clarity on Stacks)

## Overview
This is a simple lottery smart contract built with **Clarity** on the **Stacks blockchain**.  
Users can buy lottery tickets using STX, and at the end of the lottery, a random winner is selected from the participants.  

The **entire pool** goes to the contract owner, who is responsible for managing payouts.

---

## Features
- Users buy tickets with STX.
- Stores all participants on-chain.
- Owner can end the lottery and select a random winner.
- Winner is chosen using `block-height` as a pseudo-random generator.
- Owner can reset lottery for new rounds.

---

## Requirements
- [Clarinet](https://github.com/hirosystems/clarinet)  
- Git  

---

## Setup
Clone the repository:
```bash
git clone <your-repo-url>
cd simple-lottery
