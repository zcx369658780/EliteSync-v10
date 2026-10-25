# Application-owned LiveKit 2.10.0 cleanup patch

Copied from the existing locked 2.10.0 runtime package, not a dependency upgrade.
Upstream: https://github.com/livekit/client-sdk-flutter/tree/v2.10.0
Original package archive SHA-256:
`9160950ff87d1946959e4911c16236ea7a3e74ac1987990b258132fd4ed0fca9`.
Original local.dart Git blob: `3a3cea8c67d7ea5985df7e80f0791ba5664892dc`;
the cached file matched its official raw bytes.

The 297 retained upstream files are pinned in UPSTREAM_FILES.sha256. 292 remain
byte-identical. The complete five-file difference is in ELITESYNC_PATCH.diff.
LICENSE, NOTICE and original headers remain; each modified upstream file carries
an EliteSync modification notice. Dart tests/examples and top-level fixtures are
omitted; native platform tests within copied runtime directories remain.
One locally authored package test under test/ exercises the real publication
failure chain; it is additional local evidence, not one of the upstream 297 files.

Local path version: 2.10.0+elitesync.2. No shared cache or SDK is modified.

- AudioTrack snapshots capture ownership, stops a group once, protects replacement
  groups from late cancellation, and awaits in-flight capture stop.
- AudioTrack disposal also closes capture on inactive tracks, rejects registration
  during/after disposal and memoizes its completion/failure. A native stop failure
  remains visible even after the group has left the active map.
- The dedicated Native.stopAudioRenderer helper rethrows platform stop errors.
  Native start retains its explicit false result; failed start creates no listener.
- Track events are disposed in finally when stop fails.
- Room alone memoizes its disposal, attempts all owned cleanup stages, and reports
  the first error to awaiters after continuing the remaining stages. Later stage
  failures are also classified in the SDK log. Generic Disposable is unchanged.

Repeated AudioTrack/Room disposal shares the first completion result (including
true) or the same failure. This differs from the upstream already-disposed false
shortcut; true is not an exhaustive native-resource success certificate.
Real PCM delivery remains enabled. The tests replace transport/Engine boundaries,
not capture or Room algorithms. They do not prove every native platform failure
recovers or constitute a complete native handle census.
The application uses stopLocalTrackOnUnpublish=true. The added direct Room step
uses only stopCapture when that option is false. The unchanged upstream
publication disposer may still dispose a local track in that configuration;
this patch does not claim to repair or prove the full false-option contract.
