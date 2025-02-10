;; Green Token Contract
;; Implements a custom token for sustainability rewards

(define-fungible-token green-token)
(define-constant contract-owner tx-sender)

;; Error constants
(define-constant err-insufficient-funds (err u1))
(define-constant err-unauthorized (err u2))
(define-constant err-token-transfer-failed (err u3))

;; Token metadata
(define-read-only (get-total-supply)
  (ok (ft-get-supply green-token))
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance green-token account))
)

;; Mint tokens for verified green upgrades
(define-public (mint (amount uint) (recipient principal))
  (begin
    (try! (is-authorized-caller))
    (ft-mint? green-token amount recipient)
  )
)

;; Transfer tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (as-contract (ft-transfer? green-token amount sender recipient))
  )
)

;; Authorization check
(define-private (is-authorized-caller)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (ok true)
  )
)

;; Burn mechanism for token management
(define-public (burn (amount uint) (burner principal))
  (begin
    (asserts! (is-eq tx-sender burner) err-unauthorized)
    (ft-burn? green-token amount burner)
  )
)
