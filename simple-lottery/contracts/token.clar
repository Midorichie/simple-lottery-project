;; A basic SIP-010 fungible token implementation for the lottery
;; Enhanced with input validation to reduce warnings

(impl-trait .sip-010-trait.sip-010-trait)

;; Constants
(define-constant ZERO-PRINCIPAL 'SP000000000000000000002Q6VF78)
(define-constant ERR-ZERO-AMOUNT (err u1))
(define-constant ERR-INVALID-PRINCIPAL (err u2))
(define-constant ERR-SAME-SENDER-RECIPIENT (err u3))

(define-fungible-token lot)
(define-data-var total-supply uint u0)

;; ----------------------------------------
;; Input validation helpers
;; ----------------------------------------

(define-private (is-valid-principal (principal-to-check principal))
  (not (is-eq principal-to-check ZERO-PRINCIPAL))
)

(define-private (is-valid-amount (amount uint))
  (> amount u0)
)

;; ----------------------------------------
;; Public functions
;; ----------------------------------------

(define-public (mint (amount uint) (recipient principal))
  (begin
    ;; Input validation
    (asserts! (is-valid-amount amount) ERR-ZERO-AMOUNT)
    (asserts! (is-valid-principal recipient) ERR-INVALID-PRINCIPAL)
    
    (let ((mint-result (ft-mint? lot amount recipient)))
      (match mint-result
        success (begin
          (var-set total-supply (+ (var-get total-supply) amount))
          (ok true)
        )
        error (err error)
      )
    )
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    ;; Input validation
    (asserts! (is-valid-amount amount) ERR-ZERO-AMOUNT)
    (asserts! (is-valid-principal sender) ERR-INVALID-PRINCIPAL)
    (asserts! (is-valid-principal recipient) ERR-INVALID-PRINCIPAL)
    (asserts! (not (is-eq sender recipient)) ERR-SAME-SENDER-RECIPIENT)
    
    (ft-transfer? lot amount sender recipient)
  )
)

;; ----------------------------------------
;; Read-only functions
;; ----------------------------------------

(define-read-only (get-balance (account principal))
  (begin
    ;; Input validation (for consistency, though this is read-only)
    (asserts! (is-valid-principal account) ERR-INVALID-PRINCIPAL)
    (ok (ft-get-balance lot account))
  )
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-symbol)
  (ok "LOT")
)

(define-read-only (get-name)
  (ok "Lottery Token")
)
