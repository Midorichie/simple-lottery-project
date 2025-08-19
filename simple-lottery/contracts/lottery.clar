;; Simple Lottery Contract
;; SPDX-License-Identifier: MIT

;; ------------------------------
;; Error codes
;; ------------------------------
(define-constant ERR-NOT-ACTIVE (err u100))
(define-constant ERR-NOT-OWNER (err u101))
(define-constant ERR-NO-PARTICIPANTS (err u102))
(define-constant ERR-LOTTERY-ENDED (err u103))
(define-constant ERR-LIST-FULL (err u104))

;; ------------------------------
;; Storage
;; ------------------------------
(define-data-var lottery-active bool true)
(define-data-var ticket-price uint u10) ;; 10 STX per ticket
(define-data-var participants (list 1000 principal) (list)) ;; max 1000 players
(define-data-var owner principal tx-sender)

;; ------------------------------
;; Buy a ticket
;; ------------------------------
(define-public (buy-ticket)
  (let ((current (var-get participants)))
    (if (not (var-get lottery-active)) ERR-NOT-ACTIVE
      (if (>= (len current) u1000) ERR-LIST-FULL
        (let ((price (var-get ticket-price)))
          (begin
            ;; transfer STX to contract owner
            (try! (stx-transfer? price tx-sender (var-get owner)))
            ;; safely append with as-max-len?
            (match (as-max-len? (append current tx-sender) u1000)
              new-list
                (begin
                  (var-set participants new-list)
                  (ok true)
                )
              ERR-LIST-FULL
            )
          )
        )
      )
    )
  )
)

;; ------------------------------
;; Read-only helpers
;; ------------------------------
(define-read-only (get-participants)
  (ok (var-get participants))
)

(define-read-only (get-ticket-price)
  (ok (var-get ticket-price))
)

;; ------------------------------
;; End lottery and pick a winner
;; ------------------------------
(define-public (end-lottery)
  (begin
    (if (not (is-eq tx-sender (var-get owner))) ERR-NOT-OWNER
      (if (not (var-get lottery-active)) ERR-LOTTERY-ENDED
        (let ((players (var-get participants)))
          (if (is-eq (len players) u0) ERR-NO-PARTICIPANTS
            (let (
                  ;; pseudo-random winner index using block-height
                  (index (mod block-height (len players)))
                  (winner (default-to tx-sender (element-at players index)))
                 )
              (begin
                (var-set lottery-active false)
                (ok winner)
              )
            )
          )
        )
      )
    )
  )
)

;; ------------------------------
;; Reset lottery (admin only)
;; ------------------------------
(define-public (reset-lottery)
  (begin
    (if (not (is-eq tx-sender (var-get owner))) ERR-NOT-OWNER
      (begin
        (var-set participants (list))
        (var-set lottery-active true)
        (ok true)
      )
    )
  )
)
