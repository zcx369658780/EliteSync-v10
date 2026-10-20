# Non-author R1 source review

Reviewer: separate GPT-6.1 Sol high helper; read-only, not the R1 controller author.
No remaining blocking source findings. Media and interaction lookup now precede
the transaction; sorted coordinated user locks precede the first authorization
snapshot. Locked identities and attachment participant candidates are rechecked.
Owner deletion participates in User -> Post ordering. The initially found
admin/report actor-first conflict was closed by the ordered UserGovernance target
query. New tests check the low-id-owner/high-id-admin query shape and audit.

The runner observes exact reader-to-revoker INNODB_LOCK_WAITS before releasing the
revocation barrier, checks committed authority and effect state after transaction
end, and accepts only explicit 403/404 denials. Actual reader RR is now part of
PASS. Baseline prepend only loads the exact original controllers in workers.

Limits: static review does not independently execute Windows/DB/device receipts.
The matrix is cover-focused, not a complete chat-attachment or admin-delete race
matrix. SQLite identity/query-order tests do not prove server lock waits. Original
failures, PNG and APK probe failures, DB incident, recovery and rebuilt fixtures
must remain disclosed. This is not Astra acceptance.
