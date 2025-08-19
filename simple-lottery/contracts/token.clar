;; A basic SIP-010 fungible token implementation for the lottery

(impl-trait .sip-010-trait.sip-010-trait)

(define-fungible-token lot)

(define-data-var total-supply uint u0)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (ft-mint? lot amount recipient)
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok true)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (ft-transfer? lot amount sender recipient)
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance lot account))
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
