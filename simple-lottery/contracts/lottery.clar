;; Simple Lottery Contract - Phase 2
;; Uses a SIP-010 fungible token for ticket purchases and prize distribution

;; Import the SIP-010 trait
(use-trait ft-trait .sip-010-trait.sip-010-trait)

;; Error codes
(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-NOT-ACTIVE (err u101))
(define-constant ERR-LOTTERY-ENDED (err u102))
(define-constant ERR-NO-PARTICIPANTS (err u103))
(define-constant ERR-TRANSFER-FAILED (err u104))
(define-constant ERR-BALANCE-FAILED (err u105))

;; Contract variables
(define-data-var owner principal tx-sender)
(define-data-var ticket-price uint u10)
(define-data-var lottery-active bool true)
(define-data-var participants (list 1000 principal) [])

;; The token contract principal (to be set via constructor / update)
(define-data-var token-contract principal 'ST000000000000000000002AMW42H.token)

;; ----------------------------------------
;; Helpers
;; ----------------------------------------
(define-read-only (is-owner (who principal))
  (is-eq who (var-get owner))
)

;; ----------------------------------------
;; Public functions
;; ----------------------------------------
(define-public (set-ticket-price (new-price uint))
  (if (not (is-owner tx-sender)) ERR-NOT-OWNER
    (begin
      (var-set ticket-price new-price)
      (ok true)
    )
  )
)

(define-public (set-token-contract (contract principal))
  (if (not (is-owner tx-sender)) ERR-NOT-OWNER
    (begin
      (var-set token-contract contract)
      (ok true)
    )
  )
)

(define-public (buy-ticket)
  (if (not (var-get lottery-active)) ERR-NOT-ACTIVE
    (let ((price (var-get ticket-price)))
      (let ((token (var-get token-contract)))
        (let ((transfer-result (contract-call? token transfer price tx-sender (as-contract tx-sender))))
          (match transfer-result success
            (begin
              (let ((current (var-get participants)))
                (if (>= (len current) u1000)
                  (err u106) ;; max participants
                  (begin
                    (var-set participants (append current tx-sender))
                    (ok true)
                  )
                )
              )
            )
            ERR-TRANSFER-FAILED
          )
        )
      )
    )
  )
)

(define-public (end-lottery)
  (if (not (is-owner tx-sender)) ERR-NOT-OWNER
    (if (not (var-get lottery-active)) ERR-LOTTERY-ENDED
      (let ((players (var-get participants)))
        (if (is-eq (len players) u0) ERR-NO-PARTICIPANTS
          (let (
                (index (mod block-height (len players)))
                (maybe-winner (element-at players index))
              )
            (match maybe-winner winner
              (begin
                (var-set lottery-active false)
                (let ((token (var-get token-contract)))
                  (let ((prize (contract-call? token get-balance (as-contract tx-sender))))
                    (match prize prize-balance
                      (begin
                        (contract-call? token transfer prize-balance (as-contract tx-sender) winner)
                        (ok winner)
                      )
                      ERR-BALANCE-FAILED
                    )
                  )
                )
              )
              ERR-NO-PARTICIPANTS
            )
          )
        )
      )
    )
  )
)

;; ----------------------------------------
;; Read-only
;; ----------------------------------------
(define-read-only (get-participants)
  (var-get participants)
)

(define-read-only (get-owner)
  (var-get owner)
)

(define-read-only (is-active)
  (var-get lottery-active)
)

;; helper: safe list indexing
(define-read-only (element-at (lst (list 1000 principal)) (i uint))
  (if (>= i (len lst))
    none
    (list-get? lst i)
  )
)
