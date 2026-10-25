# Application-owned LiveKit 2.10.0 patch

This runtime source is copied from the existing locked `livekit_client` 2.10.0
package, not a dependency upgrade. The upstream package archive SHA-256 recorded
in the original application lock is
`9160950ff87d1946959e4911c16236ea7a3e74ac1987990b258132fd4ed0fca9`.
Upstream: https://github.com/livekit/client-sdk-flutter/tree/v2.10.0
The upstream `lib/src/track/local/local.dart` Git blob is
`3a3cea8c67d7ea5985df7e80f0791ba5664892dc`; its raw bytes matched the cached file.

297 runtime files are retained: lib, native/web platform sources, shared sources,
pubspec, LICENSE and NOTICE. Examples, upstream Dart tests and top-level test
fixtures are omitted. Native tests within platform directories are retained.
`UPSTREAM_FILES.sha256` pins the original bytes of every retained file.
`ELITESYNC_PATCH.diff` contains the complete two-file upstream delta; all other
retained runtime files are byte-identical. Existing license headers, LICENSE and
NOTICE are preserved. No shared SDK or cache is modified.

Local version: `2.10.0+elitesync.1`, selected by the application's path dependency.
The only behavior patch is in `lib/src/track/local/local.dart`:

- Detach a snapshot before asynchronous capture cleanup.
- Check group identity before an old cancel removes an options mapping.
- Memoize each group's stop and clear its callbacks synchronously.
- Await all in-flight track cleanup, including renderer cancellation, without
  stopping a replacement group through an old cancellation callback.

Real PCM capture and frame delivery remain enabled. Native platform stop error
handling is unchanged; this patch does not prove all platform failures recover.
Application regression: `test/features/rtc/domain/services/rtc_pcm_capture_cleanup_test.dart`.
