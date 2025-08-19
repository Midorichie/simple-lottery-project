;; Simple Lottery Contract - Phase 3
;; Uses a SIP-010 fungible token for ticket purchases and prize distribution
;; Enhanced with configurable max participants, better security, and bug fixes

;; Import the SIP-010 trait
(use-trait ft-trait .sip-010-trait.sip-010-trait)

;; Error codes
(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-NOT-ACTIVE (err u101))
(define-constant ERR-LOTTERY-ENDED (err u102))
(define-constant ERR-NO-PARTICIPANTS (err u103))
(define-constant ERR-TRANSFER-FAILED (err u104))
(define-constant ERR-BALANCE-FAILED (err u105))
(define-constant ERR-MAX-PARTICIPANTS-REACHED (err u106))
(define-constant ERR-INVALID-MAX-PARTICIPANTS (err u107))
(define-constant ERR-ALREADY-PARTICIPATED (err u108))
(define-constant ERR-INSUFFICIENT-BALANCE (err u109))
(define-constant ERR-INVALID-TICKET-PRICE (err u110))
(define-constant ERR-UNAUTHORIZED-TOKEN (err u111))
(define-constant ERR-INVALID-PRINCIPAL (err u112))
(define-constant ERR-INVALID-AMOUNT (err u113))

;; Constants
(define-constant ZERO-PRINCIPAL 'SP000000000000000000002Q6VF78)

;; Contract variables
(define-data-var owner principal tx-sender)
(define-data-var ticket-price uint u10)
(define-data-var lottery-active bool true)
(define-data-var max-participants uint u1000)
(define-data-var lottery-round uint u1)
(define-data-var participant-count uint u0)

;; Use maps instead of lists for better Clarity compatibility
(define-map participants { round: uint, index: uint } principal)
(define-map participant-indices { round: uint, participant: principal } uint)

;; The token contract principal (to be set via constructor / update)
(define-data-var token-contract principal tx-sender)

;; Security: Track participant status to prevent duplicate entries
(define-map participant-status { round: uint, participant: principal } bool)

;; ----------------------------------------
;; Input validation helpers
;; ----------------------------------------

(define-private (is-valid-principal (principal-to-check principal))
  (not (is-eq principal-to-check ZERO-PRINCIPAL))
)

(define-private (is-valid-amount (amount uint))
  (> amount u0)
)

(define-private (is-valid-max-participants (max uint))
  (and (> max u0) (<= max u10000))
)

;; ----------------------------------------
;; Helpers
;; ----------------------------------------
(define-read-only (is-owner (who principal))
  (is-eq who (var-get owner))
)

;; Check if participant already joined current round
(define-read-only (has-participated (participant principal))
  (is-some (map-get? participant-indices { round: (var-get lottery-round), participant: participant }))
)

;; Validate token contract exists and implements SIP-010
(define-private (validate-token-contract (token <ft-trait>))
  (and 
    (is-valid-principal (contract-of token))
    (is-ok (contract-call? token get-name))
  )
)

;; ----------------------------------------
;; Admin functions
;; ----------------------------------------

(define-public (transfer-ownership (new-owner principal))
  (begin
    ;; Input validation
    (asserts! (is-valid-principal new-owner) ERR-INVALID-PRINCIPAL)
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    (asserts! (not (is-eq new-owner (var-get owner))) ERR-INVALID-PRINCIPAL)
    
    (var-set owner new-owner)
    (ok true)
  )
)

(define-public (set-ticket-price (new-price uint))
  (begin
    ;; Input validation
    (asserts! (is-valid-amount new-price) ERR-INVALID-TICKET-PRICE)
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    
    (var-set ticket-price new-price)
    (ok true)
  )
)

(define-public (set-max-participants (new-max uint))
  (begin
    ;; Input validation
    (asserts! (is-valid-max-participants new-max) ERR-INVALID-MAX-PARTICIPANTS)
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    
    (var-set max-participants new-max)
    (ok true)
  )
)

(define-public (set-token-contract (contract principal))
  (begin
    ;; Input validation
    (asserts! (is-valid-principal contract) ERR-INVALID-PRINCIPAL)
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    (asserts! (not (is-eq contract (var-get token-contract))) ERR-INVALID-PRINCIPAL)
    
    (var-set token-contract contract)
    (ok true)
  )
)

(define-public (emergency-pause)
  (begin
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    (var-set lottery-active false)
    (ok true)
  )
)

(define-public (start-new-lottery)
  (begin
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    (var-set lottery-active true)
    (var-set participant-count u0)
    (var-set lottery-round (+ (var-get lottery-round) u1))
    (ok true)
  )
)

;; ----------------------------------------
;; Public functions
;; ----------------------------------------

(define-public (buy-ticket (token <ft-trait>))
  (let (
    (price (var-get ticket-price))
    (current-count (var-get participant-count))
    (max-allowed (var-get max-participants))
    (participant tx-sender)
    (current-round (var-get lottery-round))
  )
    ;; Input validation
    (asserts! (is-valid-principal (contract-of token)) ERR-INVALID-PRINCIPAL)
    
    ;; Check if lottery is active
    (asserts! (var-get lottery-active) ERR-NOT-ACTIVE)
    
    ;; Check if token contract matches authorized token
    (asserts! (is-eq (contract-of token) (var-get token-contract)) ERR-UNAUTHORIZED-TOKEN)
    
    ;; Check if participant already joined this round
    (asserts! (not (has-participated participant)) ERR-ALREADY-PARTICIPATED)
    
    ;; Check if max participants reached
    (asserts! (< current-count max-allowed) ERR-MAX-PARTICIPANTS-REACHED)
    
    ;; Check participant's token balance and transfer tokens
    (let ((balance-response (contract-call? token get-balance participant)))
      (match balance-response 
        balance (begin
          ;; Check if balance is sufficient
          (asserts! (>= balance price) ERR-INSUFFICIENT-BALANCE)
          
          ;; Transfer tokens from participant to contract
          (let ((transfer-result (contract-call? token transfer price participant (as-contract tx-sender))))
            (match transfer-result 
              success (begin
                ;; Add participant to map
                (map-set participants { round: current-round, index: current-count } participant)
                ;; Track participant index
                (map-set participant-indices { round: current-round, participant: participant } current-count)
                ;; Mark participant as joined for this round  
                (map-set participant-status { round: current-round, participant: participant } true)
                ;; Increment participant count
                (var-set participant-count (+ current-count u1))
                (ok true)
              )
              error-code ERR-TRANSFER-FAILED
            )
          )
        )
        error-code ERR-BALANCE-FAILED
      )
    )
  )
)

(define-public (end-lottery (token <ft-trait>))
  (let (
    (participant-count-val (var-get participant-count))
    (current-round (var-get lottery-round))
  )
    ;; Input validation
    (asserts! (is-valid-principal (contract-of token)) ERR-INVALID-PRINCIPAL)
    
    ;; Only owner can end lottery
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    
    ;; Check if lottery is active
    (asserts! (var-get lottery-active) ERR-NOT-ACTIVE)
    
    ;; Check if token contract matches
    (asserts! (is-eq (contract-of token) (var-get token-contract)) ERR-UNAUTHORIZED-TOKEN)
    
    ;; Check if there are participants
    (asserts! (> participant-count-val u0) ERR-NO-PARTICIPANTS)
    
    ;; Use block-height + current round for better randomness
    (let ((random-seed (+ block-height current-round)))
      (let ((winner-index (mod random-seed participant-count-val)))
        (let ((winner (unwrap-panic (map-get? participants { round: current-round, index: winner-index }))))
          ;; Get contract's token balance
          (let ((balance-response (contract-call? token get-balance (as-contract tx-sender))))
            (match balance-response 
              prize-balance (begin
                ;; Transfer prize to winner
                (let ((prize-transfer (as-contract (contract-call? token transfer prize-balance tx-sender winner))))
                  (match prize-transfer
                    success (begin
                      (var-set lottery-active false)
                      (ok winner)
                    )
                    error-code ERR-TRANSFER-FAILED
                  )
                )
              )
              error-code ERR-BALANCE-FAILED
            )
          )
        )
      )
    )
  )
)

;; Emergency withdrawal function for owner
(define-public (emergency-withdraw (token <ft-trait>) (amount uint))
  (begin
    ;; Input validation
    (asserts! (is-valid-principal (contract-of token)) ERR-INVALID-PRINCIPAL)
    (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
    (asserts! (is-owner tx-sender) ERR-NOT-OWNER)
    
    (var-set lottery-active false)
    (as-contract (contract-call? token transfer amount tx-sender (var-get owner)))
  )
)

;; ----------------------------------------
;; Read-only functions
;; ----------------------------------------

(define-read-only (get-participants)
  ;; Return list of participants for current round (up to first 100 for gas efficiency)
  (let ((current-round (var-get lottery-round))
        (count (var-get participant-count)))
    (map get-participant-at-index (generate-index-list (if (> count u100) u100 count)))
  )
)

;; Helper to get participant at index
(define-read-only (get-participant-at-index (index uint))
  (map-get? participants { round: (var-get lottery-round), index: index })
)

;; Helper to generate list of indices
(define-read-only (generate-index-list (count uint))
  (if (<= count u10)
    (if (>= count u1) (list u0) (list))
    (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9) ;; Simplified for demo
  )
)

(define-read-only (get-participant-count)
  (var-get participant-count)
)

(define-read-only (get-owner)
  (var-get owner)
)

(define-read-only (get-ticket-price)
  (var-get ticket-price)
)

(define-read-only (get-max-participants)
  (var-get max-participants)
)

(define-read-only (is-active)
  (var-get lottery-active)
)

(define-read-only (get-lottery-round)
  (var-get lottery-round)
)

(define-read-only (get-token-contract)
  (var-get token-contract)
)

(define-read-only (get-lottery-info)
  {
    owner: (var-get owner),
    ticket-price: (var-get ticket-price),
    max-participants: (var-get max-participants),
    current-participants: (var-get participant-count),
    is-active: (var-get lottery-active),
    lottery-round: (var-get lottery-round),
    token-contract: (var-get token-contract)
  }
)

;; Get specific participant by index
(define-read-only (get-participant-by-index (index uint))
  (map-get? participants { round: (var-get lottery-round), index: index })
)
