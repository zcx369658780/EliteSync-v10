# v10.1.5 remaining acceptance candidate

Source a25e7c1012bce3f2a2d7048f284f17ebd8a0915c. Same frozen long task,
Task Blob fec31d6318524a40b9ff8f0dab49b60aa7fa3490. Await Astra review.
PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION.

Fix inactive audio-track disposal, Room disposal completion/failure memoization,
and publication cleanup error propagation. Generic Disposable is unchanged.
Application-owned LiveKit 2.10.0+elitesync.2 retains 292/297 upstream files
byte-for-byte; five changed files have modification notices and an exact patch.
67 related checks plus 17 separate ICE guard checks pass. Analyzer exits zero:
zero errors/warnings, 19 original unchanged upstream style infos retained.

DEVICE_NEW_RUN: call3 mic/camera controls and foreground/background are supported,
but its whole journey exited 1 after a clipped reconnect-button click. Separate
call4 reconnect plus real UI hangup exits 0; post-reconnect RTP grows for about
24 seconds and new Room.dispose/leave completion events follow UI hangup.
Separate call5 proves real media after call4 cleanup and a still-valid token
from that successful media session is rejected on its first post-revoke real
WebSocket Upgrade (403, one attempt). New host-observation bound is 10.125 s,
not a new five-second PASS. Native timestamps from separate clocks are only
corroboration. Previous Astra-accepted 0.790 s remains reused at its own identity.
Camera close code4/5 warnings and trackDispose-null messages are retained.
No exhaustive native handle census or all-platform recovery claim is made.

Finite 440/880 and magnitude-only signal observations are NOT AEC or speech
quality acceptance. Notification stale card disappeared on current-authority
refresh before an actual click; stale-card clicking is NOT_RUN, not PASS.
One synthetic message remains unchanged across the owned database restart.

Cleanup stages completed; the original closure script exited 1 on a port-rebind
check with TCP TIME_WAIT. A separate read-only check proves no listeners,
connection refusal, stopped owned processes/containers and no phone process,
active call, session family or token. SFU stopped state records exit code 1;
no claim is made that every child exited zero. Containers/volume are retained.

Gate2 is READ_ONLY, new budget/Writer/Serializer calls are zero. No D0-A rerun,
37-case suite, conditional Sandbox SDK, Producer, libs.jar or 30 resolves.
Physical 15/30 elapsed days, physical AEC and real Push remain unverified.
Raw privacy-bearing evidence is local; this package contains only sanitized
sources, results, limitations and hashes. No self acceptance or v10.1.6.
