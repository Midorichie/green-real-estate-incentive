;; Sustainability Registry Contract

(define-map property-upgrades 
  { owner: principal, property-id: uint }
  {
    upgrade-type: (string-ascii 50),
    verification-status: bool,
    timestamp: uint,
    carbon-offset: uint
  }
)

(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u1))
(define-constant err-duplicate-upgrade (err u2))
(define-constant err-invalid-upgrade (err u3))

(define-public (register-upgrade 
  (property-id uint) 
  (upgrade-type (string-ascii 50))
  (carbon-offset uint)
)
  (begin
    (asserts! 
      (is-none (map-get? property-upgrades { owner: tx-sender, property-id: property-id })) 
      err-duplicate-upgrade
    )
    
    (asserts! 
      (or 
        (is-eq upgrade-type "solar-panels")
        (is-eq upgrade-type "rainwater-harvesting")
        (is-eq upgrade-type "energy-efficient-windows")
      ) 
      err-invalid-upgrade
    )

    (map-set property-upgrades 
      { owner: tx-sender, property-id: property-id }
      {
        upgrade-type: upgrade-type,
        verification-status: false,
        timestamp: block-height,
        carbon-offset: carbon-offset
      }
    )

    (ok true)
  )
)

(define-public (verify-upgrade (owner principal) (property-id uint))
  (let 
    ((upgrade (map-get? property-upgrades { owner: owner, property-id: property-id })))
    (match upgrade
      existing-upgrade 
        (begin
          (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
          (map-set property-upgrades 
            { owner: owner, property-id: property-id }
            (merge existing-upgrade { verification-status: true })
          )
          (ok true)
        )
      (ok false)
    )
  )
)

(define-read-only (get-upgrade-details (owner principal) (property-id uint))
  (map-get? property-upgrades { owner: owner, property-id: property-id })
)
