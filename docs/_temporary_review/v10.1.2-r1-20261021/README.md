# R1 evidence scope

Primary source 88ffeccce4042f13ce4edccf7604b835b06c8f2d. Actual execution by Codex; non-author read-only review is not independent runtime execution or Astra acceptance.

Only redacted text copies. Raw SQL, credentials, HTTP receipts, UI XML/screenshots, APK and device logs remain LOCAL_ONLY. Original bytes/SHA256 and redacted bytes/SHA256 are separate. No results/exit codes replaced.

RR primary proof is attempt04 only: specific INNODB_LOCK_WAITS reader/writer pairs plus requested users PRIMARY lock_data, no global wait count. SQL uses prepared placeholders. Writer revokes through actual product Controller/service in a surrounding held transaction; reader is actual authenticated HTTP. B2 writer has CurrentQuestionnaire and peer User locks before product EXIT; reader demonstrably waits on peer User.

Preserved failures: attempt01 exact-filter failure and writer timeout; attempt02 marker namespace mismatch; attempt03 query placeholders made value matching invalid. A v2 writer accidentally reused race-contact marker paths, so attempt01 held/committed marker files cannot establish its original timing and are excluded; its raw failed command/stdout/stderr remain. Attempt03/04 are disjoint. Fixture-race-03 exit255 used wrong cwd; corrected 03b succeeded.

Persistence attempt01 used incorrect CN/MC table names; Laravel console rendered the exception but returned exit0. It is FAILED and not a persistence PASS. First restart then hit ready-state error; outer runner exit1 retained. Corrected v2 validates parsed JSON, explicit exception exit1 and nine exact table hashes; second controlled restart PASS.

APP input first attempt had a credential-entry error, then real synthetic login succeeded after resetting password field. Initial UI snapshots and credential/raw HTTP remain local. Pre-existing synthetic session logout showed server revocation not yet confirmed; no claim that response was confirmed.

APK/APP checks use fixed final source and owned AVD only, no phone/RTC/network window. APP summary explicitly distinguishes observed UI, API/DB facts and Widget-only regressions. Original delivery and failures remain historical.
