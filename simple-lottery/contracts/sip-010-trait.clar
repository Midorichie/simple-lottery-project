;; SIP-010 Fungible Token Trait Definition

(define-trait sip-010-trait
  (
    (transfer (uint principal principal) (response bool uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-decimals () (response uint uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-name () (response (string-ascii 32) uint))
  )
)
