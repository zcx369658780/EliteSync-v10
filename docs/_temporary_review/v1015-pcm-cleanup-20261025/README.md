# v10.1.5 PCM cleanup repair candidate

Continuation of the same frozen task. This is a Codex-reported repair candidate,
awaiting Astra independent review; whole version PARTIAL_NOT_ACCEPTED / AC05_OPEN.

Source: `1f9d1483268e957f7184625483ff6406071c1867`.
The original SDK race was reproduced before modification. The minimal upstream
delta is in PCM_UPSTREAM_PATCH.diff. APP_WIRING.diff includes dependency locking
and the AAR cache-input fix. Full sources and tests are in the source commit.

48 final related Flutter checks pass; test transport replaces native channels,
not the SDK grouping/stop algorithm. Phone evidence is a separate real run.
Same-call reconnect and a followup real media call after cleanup were observed.
The initial journey script exited 1 on UI idle acquisition and ended the call
through its real service finally path; it is not a whole-journey PASS. The focused
followup exited 0. Both calls ended through real service APIs, not UI hangup.
Audio/video counters grow; native stop events corroborate cleanup. No new CME
was found in the captured process log. This does not prove an exhaustive native
PCM handle census, Room.dispose overall success, AEC or all platform failures.

The previous Astra media/reconnect and 0.790-second revocation observation are
retained as REUSED_ACCEPTED_EVIDENCE, not newly measured here. Gate 2 and its
dependent chain were not retried. No product main integration or v10.1.6.

Only this bounded sanitized package is published. Raw logs, APKs, SQL, serials,
tokens and private audio/video are LOCAL_ONLY. Hashes do not make private raw
evidence public or independently rerun by Astra.
