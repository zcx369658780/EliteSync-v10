# R1 real MariaDB barrier regression

This harness exercises the real Laravel HTTP kernel, routes, bearer-token middleware,
controllers, persistent MariaDB, and local private-file response. It does not replace
authorization code or change transaction isolation. It does not start services or
operate the phone, firewall, RTC, or production environment.

Only the exact local `elitesync_v10_1_1_dev` MySQL connection at loopback port 43322,
with Laravel `APP_ENV=local`, is accepted. Back up that development DB first.

1. Put `{"suite_path":"ABSOLUTE_LOCAL_ONLY_SUITE_PATH"}` in a private JSON file.
   Run `PHP worker.php fixture PRIVATE_JSON`. This creates 21 isolated fixture pairs
   (42 explicitly synthetic normal users), 21 FRIENDS posts and real tiny PNGs,
   tokens, and the nine initial unlike likes. It prints counts only. The suite
   contains tokens and must remain LOCAL_ONLY. Fixtures are retained, never reset
   or deleted. Re-run with a new output path for a new baseline/fixed suite.
2. Prepare a LOCAL_ONLY observer JSON with `observer_dsn`, `observer_user`, and
   `observer_password`. The observer must be allowed to read `INNODB_LOCK_WAITS`
   and `INNODB_TRX`. No grants are performed by this harness.
3. Run `python run.py --php ABSOLUTE_PHP --suite PRIVATE_SUITE
   --observer-config PRIVATE_OBSERVER_JSON --output NEW_EVIDENCE_DIRECTORY`.

Each run includes three actions (cover GET, like, unlike), three revocations
(FRIENDS→SELF, unfriend, block), nine races, nine revoke-before-request controls,
and three legitimate positive controls. Every race first holds the sorted user
locks, then starts a genuine request. The SQL listener records the initial target
read and attempted user lock. An independent observer must see the exact reader
connection waiting on the revoker connection before the revocation route runs
and commits. The resulting user-lock acquisition proves the commit handoff;
the revoker's post-commit acknowledgment can arrive after the reader resumes.

Raw stdout/stderr, process exit codes, timestamped barriers, actual isolation,
response status/type/length/hash, synthetic body-marker detection, and post-specific
like/event/notification snapshots are retained. The binary response is actually
streamed, retained as `response.LOCAL_ONLY.bin`, and hashed. No private body or bearer token is copied into result JSON.
`config.LOCAL_ONLY.json` contains credentials and must not enter the review bundle.

Exit 1 preserves a failed security assertion or harness error. Inspect individual
results: 500s, missing barriers, deadlocks, and process errors are never accepted
as denial. Positive controls require real bytes/body and the intended effects.
Negative controls require 403/404, no private bytes/body, and no interaction or
notification/event change. After each real request, the worker rejects any open
transaction and reads persisted post audience/deletion, friendship state/revision,
and both block directions. Negative controls also require the corresponding
committed SELF/REMOVED/REVOKED+block state; positives require the retained live
FRIENDS post, ACTIVE friendship, and no blocks. Exit 0 requires every case and race barrier to pass.
Every reader must report actual session REPEATABLE-READ; a different isolation
level fails the runner without changing DB configuration. The final PNG is a
valid CRC-checked 32x32 RGB image, usable for the APP render control.

For the original-controller comparison only, `--prepend LOCAL_ONLY_BOOTSTRAP`
adds PHP's auto_prepend_file to reader/revoker workers. The bootstrap loads the
two unmodified controllers exported from the exact reviewed commit before the
kernel boots. Record those blobs and file hashes; it must not implement a
replacement authorization algorithm. Omit this option for the fixed candidate.

Run ordinary PHPUnit Feature tests only through the fail-closed testing config
and Tests\\TestCase SQLite-memory guard. This persistent MariaDB harness does not
extend that base class and never invokes RefreshDatabase or migrations.
