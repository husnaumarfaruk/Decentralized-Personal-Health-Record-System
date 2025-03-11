;; Research Consent Contract
;; Manages patient approval for using data in studies

(define-map research-consents
  { patient-id: (buff 32), study-id: (buff 32) }
  {
    consented: bool,
    consent-date: uint,
    expiration-date: uint
  }
)

(define-read-only (get-research-consent (patient-id (buff 32)) (study-id (buff 32)))
  (map-get? research-consents { patient-id: patient-id, study-id: study-id })
)

(define-public (give-consent (patient-id (buff 32)) (study-id (buff 32)) (duration uint))
  (ok (map-set research-consents
    { patient-id: patient-id, study-id: study-id }
    {
      consented: true,
      consent-date: block-height,
      expiration-date: (+ block-height duration)
    }
  ))
)

(define-public (revoke-consent (patient-id (buff 32)) (study-id (buff 32)))
  (ok (map-delete research-consents { patient-id: patient-id, study-id: study-id }))
)

(define-read-only (check-consent (patient-id (buff 32)) (study-id (buff 32)))
  (match (get-research-consent patient-id study-id)
    consent (and
      (get consented consent)
      (< block-height (get expiration-date consent))
    )
    false
  )
)

