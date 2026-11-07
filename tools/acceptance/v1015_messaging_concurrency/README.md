# v10.1.5 real MariaDB messaging concurrency probe

This is a narrow backend acceptance harness, not an APP/WS, complete AC03, or
whole-version acceptance. It uses the unmodified Laravel HTTP kernel, bearer
middleware, routes, application services and an explicitly qualified new fixture
database. It never extends `Tests\TestCase`, runs `RefreshDatabase`, changes
isolation, migrates, creates grants, starts services, or deletes fixtures.

The caller must supply a separately authorized bounded backend with the resident
PHP/MariaDB images, task-owned immutable container IDs, a new isolated database,
an active fictional CN/MC pair and two valid fictional bearer credentials.
`/task/qualify.php` must provide `qualifyV1015MessagingConcurrency($app)` and reject
other DB/env/task identities. The worker requires the actual
`REPEATABLE-READ` session isolation without changing it.

Two cases run strictly serially:

1. Hold the sorted pair user locks, start two independent same-key POST requests,
   and independently observe both exact requesting connection IDs waiting on the
   holder's qualified `users` PRIMARY row. Release only after that witness. Both
   requests must succeed with the same message ID and key, exactly one replay,
   and one persisted message, message notification and `message_sent` event.
2. Hold the same locks in a revoker connection; start GET history and a new POST.
   After both exact waits are witnessed, the holder invokes the real MC revoke
   route and commits. Both requests must acquire locks then return404 with no
   private marker or success identity, no tracked message effects, CN still
   active and both MC purposes revoked. A same-key replay after commit must also
   be denied without changing the captured effects.

The independent observer uses only SELECT through the new DB container's
existing root client and PROCESS visibility. Its password stays in the existing
container environment, never a CLI argument or result. No privilege is granted.
Request workers continue to use only the bounded application DB user.

Lock waits and subsequent acquisition prove the commit handoff. Worker records
include DB UTC, connection IDs, PHP monotonic times and isolation; observer times
are explicitly host-clock observations. Do not compare clock domains or require
the revoker's post-commit acknowledgment to precede a resumed reader.500s,
deadlocks, missing barriers, process errors and leftover transactions fail.

`run.py --config PRIVATE_CONFIG` consumes a caller-generated LOCAL_ONLY JSON
containing task ID, Docker executable, held API/DB container IDs, database,
participants, client message key, host/container evidence paths, container config
path and the owned backend stop/outcome paths. The separate PHP config contains
only this fixture's tokens and fixed route operations. Configs and all raw
outputs stay LOCAL_ONLY. The caller's immutable input contract must bind these
scripts before launch. Errors publish the common45-second cleanup deadline and
stop request; the owning backend controller closes only its held containers.

Pure checks using Python3.11+ (no DB/device execution):

```powershell
python -B -m unittest discover -s tools/acceptance/v1015_messaging_concurrency -p 'test_*.py' -v
```

Pure fixtures validate evidence rejection; they do not establish concurrency.
Run the actual probe only under a current valid task scope/claim. Old consumed
claims and STOPs must never be reset or reused. Private bodies, tokens, SQL and
device logs are not public deliverables.
