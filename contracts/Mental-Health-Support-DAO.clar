(define-fungible-token mh-support-token)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-content-not-found (err u102))
(define-constant err-already-voted (err u103))
(define-constant err-voting-closed (err u104))
(define-constant err-not-professional (err u105))
(define-constant err-already-registered (err u106))
(define-constant err-invalid-vote (err u107))
(define-constant err-insufficient-votes (err u108))
(define-constant err-insufficient-reputation (err u109))
(define-constant err-reputation-not-found (err u110))

(define-data-var total-supply uint u0)
(define-data-var content-counter uint u0)
(define-data-var voting-period uint u1440)
(define-data-var min-vote-threshold uint u5)
(define-data-var reward-multiplier uint u10)
(define-data-var min-reputation-threshold uint u10)

(define-map content-submissions uint {
    author: principal,
    title: (string-ascii 100),
    content-hash: (string-ascii 64),
    submission-height: uint,
    vote-count: uint,
    total-reward: uint,
    anonymous: bool,
    status: (string-ascii 20)
})

(define-map content-votes {content-id: uint, voter: principal} {
    vote-value: uint,
    voted-at: uint
})

(define-map user-balances principal uint)

(define-map professionals principal {
    verified: bool,
    specialization: (string-ascii 50),
    registered-at: uint,
    total-earnings: uint
})

(define-map dao-members principal {
    joined-at: uint,
    voting-power: uint,
    contributions: uint
})

(define-map user-reputation principal {
    reputation-score: uint,
    total-votes-cast: uint,
    quality-content-count: uint,
    community-endorsements: uint,
    last-updated: uint
})

(define-read-only (get-balance (account principal))
    (default-to u0 (map-get? user-balances account)))

(define-read-only (get-total-supply)
    (var-get total-supply))

(define-read-only (get-content (content-id uint))
    (map-get? content-submissions content-id))

(define-read-only (get-professional-info (account principal))
    (map-get? professionals account))

(define-read-only (get-dao-member-info (account principal))
    (map-get? dao-members account))

(define-read-only (has-voted (content-id uint) (voter principal))
    (is-some (map-get? content-votes {content-id: content-id, voter: voter})))

(define-read-only (get-vote-info (content-id uint) (voter principal))
    (map-get? content-votes {content-id: content-id, voter: voter}))

(define-read-only (is-voting-active (content-id uint))
    (match (get-content content-id)
        content-data 
            (let ((submission-height (get submission-height content-data)))
                (< (- stacks-block-height submission-height) (var-get voting-period)))
        false))

(define-read-only (get-content-author (content-id uint))
    (match (get-content content-id)
        content-data 
            (if (get anonymous content-data) 
                none 
                (some (get author content-data)))
        none))

(define-read-only (get-voting-period)
    (var-get voting-period))

(define-read-only (get-reward-multiplier)
    (var-get reward-multiplier))

(define-read-only (get-vote-threshold)
    (var-get min-vote-threshold))

(define-read-only (get-content-counter)
    (var-get content-counter))

(define-read-only (get-user-reputation (user principal))
    (default-to {
        reputation-score: u0,
        total-votes-cast: u0,
        quality-content-count: u0,
        community-endorsements: u0,
        last-updated: u0
    } (map-get? user-reputation user)))

(define-read-only (get-reputation-score (user principal))
    (get reputation-score (get-user-reputation user)))

(define-read-only (has-min-reputation (user principal))
    (>= (get-reputation-score user) (var-get min-reputation-threshold)))

(define-private (mint-tokens (recipient principal) (amount uint))
    (begin
        (try! (ft-mint? mh-support-token amount recipient))
        (map-set user-balances recipient (+ (get-balance recipient) amount))
        (var-set total-supply (+ (var-get total-supply) amount))
        (ok true)))

(define-private (transfer-internal (sender principal) (recipient principal) (amount uint))
    (let ((sender-balance (get-balance sender)))
        (asserts! (>= sender-balance amount) err-insufficient-balance)
        (try! (ft-transfer? mh-support-token amount sender recipient))
        (map-set user-balances sender (- sender-balance amount))
        (map-set user-balances recipient (+ (get-balance recipient) amount))
        (ok true)))

(define-private (update-reputation (user principal) (reputation-change uint) (activity-type (string-ascii 20)))
    (let ((current-rep (get-user-reputation user)))
        (let ((new-score (+ (get reputation-score current-rep) reputation-change)))
            (map-set user-reputation user (merge current-rep {
                reputation-score: new-score,
                last-updated: stacks-block-height
            }))
            (ok new-score))))



(define-public (submit-content (title (string-ascii 100)) (content-hash (string-ascii 64)) (anonymous bool))
    (let ((content-id (+ (var-get content-counter) u1)))
        (begin
            (map-set content-submissions content-id {
                author: tx-sender,
                title: title,
                content-hash: content-hash,
                submission-height: stacks-block-height,
                vote-count: u0,
                total-reward: u0,
                anonymous: anonymous,
                status: "pending"
            })
            (var-set content-counter content-id)
            (ok content-id))))

(define-public (vote-on-content (content-id uint) (vote-value uint))
    (let ((content-data (unwrap! (get-content content-id) err-content-not-found)))
        (begin
            (asserts! (is-voting-active content-id) err-voting-closed)
            (asserts! (not (has-voted content-id tx-sender)) err-already-voted)
            (asserts! (and (>= vote-value u1) (<= vote-value u10)) err-invalid-vote)
            (map-set content-votes {content-id: content-id, voter: tx-sender} {
                vote-value: vote-value,
                voted-at: stacks-block-height
            })
            (map-set content-submissions content-id 
                (merge content-data {vote-count: (+ (get vote-count content-data) u1)}))
            (let ((voter-rep (get-user-reputation tx-sender)))
                (map-set user-reputation tx-sender (merge voter-rep {
                    total-votes-cast: (+ (get total-votes-cast voter-rep) u1)
                })))
            (unwrap! (update-reputation tx-sender u1 "vote") err-insufficient-reputation)
            (ok true))))

(define-public (finalize-voting (content-id uint))
    (let ((content-data (unwrap! (get-content content-id) err-content-not-found)))
        (begin
            (asserts! (not (is-voting-active content-id)) err-voting-closed)
            (asserts! (>= (get vote-count content-data) (var-get min-vote-threshold)) err-insufficient-votes)
            (let ((reward-amount (* (get vote-count content-data) (var-get reward-multiplier)))
                  (author (get author content-data)))
                (begin
                    (try! (mint-tokens author reward-amount))
                    (map-set content-submissions content-id 
                        (merge content-data {total-reward: reward-amount, status: "rewarded"}))
                    (let ((author-rep (get-user-reputation author)))
                        (map-set user-reputation author (merge author-rep {
                            quality-content-count: (+ (get quality-content-count author-rep) u1)
                        })))
                    (unwrap! (update-reputation author u5 "content-reward") err-insufficient-reputation)
                    (ok reward-amount))))))

(define-public (register-professional (specialization (string-ascii 50)))
    (begin
        (asserts! (is-none (get-professional-info tx-sender)) err-already-registered)
        (map-set professionals tx-sender {
            verified: false,
            specialization: specialization,
            registered-at: stacks-block-height,
            total-earnings: u0
        })
        (ok true)))

(define-public (verify-professional (professional principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let ((prof-data (unwrap! (get-professional-info professional) err-not-professional)))
            (begin
                (map-set professionals professional 
                    (merge prof-data {verified: true}))
                (ok true)))))

(define-public (reward-professional (professional principal) (amount uint))
    (let ((prof-data (unwrap! (get-professional-info professional) err-not-professional)))
        (begin
            (asserts! (get verified prof-data) err-not-professional)
            (try! (mint-tokens professional amount))
            (map-set professionals professional 
                (merge prof-data {total-earnings: (+ (get total-earnings prof-data) amount)}))
            (ok true))))

(define-public (join-dao)
    (begin
        (asserts! (is-none (get-dao-member-info tx-sender)) err-already-registered)
        (map-set dao-members tx-sender {
            joined-at: stacks-block-height,
            voting-power: u1,
            contributions: u0
        })
        (ok true)))

(define-public (transfer (recipient principal) (amount uint))
    (transfer-internal tx-sender recipient amount))

(define-public (moderate-content (content-id uint) (new-status (string-ascii 20)))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let ((content-data (unwrap! (get-content content-id) err-content-not-found)))
            (begin
                (map-set content-submissions content-id 
                    (merge content-data {status: new-status}))
                (ok true)))))

(define-public (update-voting-period (new-period uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set voting-period new-period)
        (ok true)))

(define-public (update-reward-multiplier (new-multiplier uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set reward-multiplier new-multiplier)
        (ok true)))

(define-public (update-vote-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set min-vote-threshold new-threshold)
        (ok true)))

(define-public (emergency-pause (content-id uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (let ((content-data (unwrap! (get-content content-id) err-content-not-found)))
            (begin
                (map-set content-submissions content-id 
                    (merge content-data {status: "paused"}))
                (ok true)))))

(define-public (get-user-balance (user principal))
    (ok (get-balance user)))

(define-public (get-content-status (content-id uint))
    (match (get-content content-id)
        content-data (ok (get status content-data))
        err-content-not-found))

(define-public (calculate-user-rewards (user principal))
    (match (get-dao-member-info user)
        member-data (ok (* (get contributions member-data) (var-get reward-multiplier)))
        (ok u0)))

(define-public (increase-voting-power (member principal) (additional-power uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (match (get-dao-member-info member)
            member-data 
                (begin
                    (map-set dao-members member 
                        (merge member-data {voting-power: (+ (get voting-power member-data) additional-power)}))
                    (ok true))
            (err u111))))

(define-public (update-member-contributions (member principal))
    (match (get-dao-member-info member)
        member-data 
            (begin
                (map-set dao-members member 
                    (merge member-data {contributions: (+ (get contributions member-data) u1)}))
                (ok true))
        (begin
            (map-set dao-members member {
                joined-at: stacks-block-height,
                voting-power: u1,
                contributions: u1
            })
            (ok true))))

(define-public (get-dao-stats)
    (ok {
        total-supply: (var-get total-supply),
        content-count: (var-get content-counter),
        voting-period: (var-get voting-period)
    }))

(define-public (endorse-user (target-user principal))
    (begin
        (asserts! (has-min-reputation tx-sender) err-insufficient-reputation)
        (asserts! (not (is-eq tx-sender target-user)) err-invalid-vote)
        (let ((target-rep (get-user-reputation target-user)))
            (begin
                (map-set user-reputation target-user (merge target-rep {
                    community-endorsements: (+ (get community-endorsements target-rep) u1)
                }))
                (unwrap! (update-reputation target-user u3 "endorsement") err-insufficient-reputation)
                (ok true)))))

(define-public (reputation-weighted-vote (proposal-id uint) (support bool))
    (let ((voter-reputation (get-reputation-score tx-sender)))
        (begin
            (asserts! (has-min-reputation tx-sender) err-insufficient-reputation)
            (let ((weighted-power (/ (* voter-reputation u2) u10)))
                (ok weighted-power)))))

(define-public (get-reputation-tier (user principal))
    (let ((score (get-reputation-score user)))
        (if (>= score u100)
            (ok "expert")
            (if (>= score u50)
                (ok "advanced")
                (if (>= score u20)
                    (ok "intermediate")
                    (if (>= score u5)
                        (ok "beginner")
                        (ok "newcomer")))))))

(define-public (update-reputation-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set min-reputation-threshold new-threshold)
        (ok true)))
