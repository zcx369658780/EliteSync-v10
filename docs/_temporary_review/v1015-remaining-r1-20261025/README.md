# v10.1.5 same-version R1 repair candidate

PARTIAL_NOT_ACCEPTED / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_REVIEW.
Owner manually dispatched this bounded R1 repair; no successor or main integration.

Source e7cbbe6030b033c5c9244c599bd42fcff312a8c6 adds an await to a repeated
call-scoped leave after the Room has been detached, plus two regressions.
Original code: two expected RED failures. Fixed: 22 service and 27 distinct
associated page checks pass; scoped Dart analysis reports no issues.
No vendor, backend, token, consent or upgrade source changes.

New APK installed and pulled SHA256 matches 30ca72ab1e53c55ff324ee2763d84ceab7867a7c54617e5b76bcbaa83c966a12.
R1-root call1 proves pre-revoke four-direction RTP and decoded video 66 to 226.
The READY/GO barrier excludes bootstrap from the host monotonic interval.
Commit is bracketed, not timestamped exactly. Raw observed upper bound 0.875s;
GetTickCount64 resolution 15.625ms, two-tick allowance 31.25ms, conservative
upper bound 0.90625s for listed native/lifecycle endpoints. No audible-waveform,
AEC, complete native-handle or all-platform claim. Native warnings remain.

Notification test used original unchanged APK 68e9bc37...: current visible stale
card received a real Android accessibility ACTION_CLICK after service revoke;
blocked-conversation feedback appeared, private synthetic body stayed absent,
read facts stayed unchanged. No physical tap or individual HTTP status claim.

Original call3 failure, call4 UI reconnect/hangup, call5 token 403, old 10.125s
and 0.790s evidence retain their separate identities. The new call is not a
stitched journey. Actual 15/30 days, physical 30-day purge, AEC, real Push and
Gate2 remain open/unrun. Gate2 new starts and Writer/Serializer calls are zero.

One build was aborted after its inner wrapper attempted Gradle download despite
outer offline flags (7,941,328-byte partial retained). This boundary deviation
is acknowledged, not labelled no-download. The corrected task-owned ignored
wrapper has no network fallback and calls byte-verified existing Gradle runtime;
the corrected build passes. Other preparation failures remain in the evidence.

Runtime stopped; calls/session families/access tokens zero; owned reverse mappings
restored; APK, container/volume and raw evidence retained. SFU stopped exit1 is
recorded separately from DB exit0. Non-author review was static only.

Raw device/UI logs, APK, SQL, tokens, identifiers and private evidence stay local.
These summaries and sanitized harness copies are review material, not a runtime
replay or Astra acceptance. Candidate identity is externally bound after commit.
