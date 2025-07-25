;; BakingChain: Baking and Pastry Mastery Reward System
;; Version: 1.0.0

;; Constants
(define-constant BAKERY_CAPACITY u1800000)
(define-constant BASE_BAKING_REWARD u22)
(define-constant PASTRY_BONUS u8)
(define-constant MAX_BAKER_LEVEL u12)
(define-constant ERR_INVALID_BAKING_ACTIVITY u1)
(define-constant ERR_NO_BAKING_TOKENS u2)
(define-constant ERR_BAKERY_CAPACITY_EXCEEDED u3)
(define-constant BLOCKS_PER_BAKING_SEASON u1728)
(define-constant STARTER_PRESERVATION_MULTIPLIER u4)
(define-constant MIN_PRESERVATION_PERIOD u864)
(define-constant EARLY_BAKING_PENALTY u15)

;; Data Variables
(define-data-var total-baking-tokens-distributed uint u0)
(define-data-var total-baking-activities uint u0)
(define-data-var bakery-supervisor principal tx-sender)

;; Data Maps
(define-map baker-activities principal uint)
(define-map baker-baking-tokens principal uint)
(define-map baking-activity-start-time principal uint)
(define-map baker-pastry-level principal uint)
(define-map baker-last-activity principal uint)
(define-map baker-preserved-starter principal uint)
(define-map baker-preservation-start-block principal uint)

;; Public Functions
(define-public (start-baking-activity (baking-duration uint))
  (let
    (
      (baker tx-sender)
    )
    (asserts! (> baking-duration u0) (err ERR_INVALID_BAKING_ACTIVITY))
    (map-set baking-activity-start-time baker burn-block-height)
    (ok true)
  ))

(define-public (complete-baking-batch (baking-duration uint))
  (let
    (
      (baker tx-sender)
      (start-block (default-to u0 (map-get? baking-activity-start-time baker)))
      (blocks-baking (- burn-block-height start-block))
      (last-activity-block (default-to u0 (map-get? baker-last-activity baker)))
      (pastry-level (default-to u0 (map-get? baker-pastry-level baker)))
      (capped-pastry (if (<= pastry-level MAX_BAKER_LEVEL) pastry-level MAX_BAKER_LEVEL))
      (baking-reward (+ BASE_BAKING_REWARD (* capped-pastry PASTRY_BONUS)))
    )
    (asserts! (and (> start-block u0) (>= blocks-baking baking-duration)) (err ERR_INVALID_BAKING_ACTIVITY))
    
    (map-set baker-activities baker (+ (default-to u0 (map-get? baker-activities baker)) u1))
    (map-set baker-baking-tokens baker (+ (default-to u0 (map-get? baker-baking-tokens baker)) baking-reward))
    
    (if (< (- burn-block-height last-activity-block) BLOCKS_PER_BAKING_SEASON)
      (map-set baker-pastry-level baker (+ pastry-level u1))
      (map-set baker-pastry-level baker u1)
    )
    
    (map-set baker-last-activity baker burn-block-height)
    (var-set total-baking-activities (+ (var-get total-baking-activities) u1))
    (var-set total-baking-tokens-distributed (+ (var-get total-baking-tokens-distributed) baking-reward))
    
    (asserts! (<= (var-get total-baking-tokens-distributed) BAKERY_CAPACITY) (err ERR_BAKERY_CAPACITY_EXCEEDED))
    (ok baking-reward)
  ))

(define-public (claim-baking-rewards)
  (let
    (
      (baker tx-sender)
      (token-balance (default-to u0 (map-get? baker-baking-tokens baker)))
    )
    (asserts! (> token-balance u0) (err ERR_NO_BAKING_TOKENS))
    (map-set baker-baking-tokens baker u0)
    (ok token-balance)
  ))

;; Starter Preservation Features
(define-public (preserve-starter (amount uint))
  (let
    (
      (baker tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_BAKING_ACTIVITY))
    (asserts! (>= (var-get total-baking-tokens-distributed) amount) (err ERR_BAKERY_CAPACITY_EXCEEDED))
    
    (map-set baker-preserved-starter baker amount)
    (map-set baker-preservation-start-block baker burn-block-height)
    (var-set total-baking-tokens-distributed (- (var-get total-baking-tokens-distributed) amount))
    (ok amount)
  ))

(define-public (release-preserved-starter)
  (let
    (
      (baker tx-sender)
      (preserved-amount (default-to u0 (map-get? baker-preserved-starter baker)))
      (preservation-start-block (default-to u0 (map-get? baker-preservation-start-block baker)))
      (blocks-preserved (- burn-block-height preservation-start-block))
      (penalty (if (< blocks-preserved MIN_PRESERVATION_PERIOD) (/ (* preserved-amount EARLY_BAKING_PENALTY) u100) u0))
      (final-amount (- preserved-amount penalty))
    )
    (asserts! (> preserved-amount u0) (err ERR_NO_BAKING_TOKENS))
    
    (map-set baker-preserved-starter baker u0)
    (map-set baker-preservation-start-block baker u0)
    (var-set total-baking-tokens-distributed (+ (var-get total-baking-tokens-distributed) final-amount))
    (ok final-amount)
  ))

;; Read-Only Functions
(define-read-only (get-baking-activity-count (user principal))
  (default-to u0 (map-get? baker-activities user)))

(define-read-only (get-baking-token-balance (user principal))
  (default-to u0 (map-get? baker-baking-tokens user)))

(define-read-only (get-pastry-level (user principal))
  (default-to u0 (map-get? baker-pastry-level user)))

(define-read-only (get-bakery-stats)
  {
    total-baking-activities: (var-get total-baking-activities),
    total-baking-tokens-distributed: (var-get total-baking-tokens-distributed)
  })

;; Private Functions
(define-private (is-bakery-supervisor)
  (is-eq tx-sender (var-get bakery-supervisor)))