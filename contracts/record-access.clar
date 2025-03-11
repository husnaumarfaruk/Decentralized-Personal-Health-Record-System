;; Record Access Contract
;; Controls permissions for viewing and updating health data

(define-map access-permissions
  { patient-id: (buff 32), provider-id: principal }
  {
    can-read: bool,
    can-write: bool,
    granted-at: uint,
    expires-at: uint
  }
)

(define-read-only (get-access-permission (patient-id (buff 32)) (provider-id principal))
  (map-get? access-permissions { patient-id: patient-id, provider-id: provider-id })
)

(define-public (grant-access (patient-id (buff 32)) (provider-id principal) (can-read bool) (can-write bool) (duration uint))
  (ok (map-set access-permissions
    { patient-id: patient-id, provider-id: provider-id }
    {
      can-read: can-read,
      can-write: can-write,
      granted-at: block-height,
      expires-at: (+ block-height duration)
    }
  ))
)

(define-public (revoke-access (patient-id (buff 32)) (provider-id principal))
  (ok (map-delete access-permissions { patient-id: patient-id, provider-id: provider-id }))
)

(define-read-only (check-access (patient-id (buff 32)) (provider-id principal))
  (match (get-access-permission patient-id provider-id)
    permission (and
      (or (get can-read permission) (get can-write permission))
      (< block-height (get expires-at permission))
    )
    false
  )
)

