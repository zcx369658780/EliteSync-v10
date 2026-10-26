# Local offline v10.1.5 debug entry

Use Python 3.11+ and existing local Gradle 8.14, Java, Flutter, Pub/Gradle caches
and Android SDK. This entry never bootstraps tools and accepts no extra build
flags. It builds the ordinary local R1 debug APK, without ICE or retention probes.

```
python apps/android/scripts/offline_debug.py --manifest <trusted-inventory.json> --sha256 <inventory-sha256> --receipt-dir <new-receipt-directory>
```

The caller supplies an independently pinned inventory derived from a known
successful compatible build/cache snapshot. Do not generate one from an unknown
or incomplete cache and call it complete. The inventory has schema 1,
`gradleVersion: "8.14"`, an absolute task-owned `workRoot`, and `roots` for
`gradle`, `cache`, `flutter`, `pub`, `java`, `android`, `project`.
`inventory` contains `{root, path, sha256}` for every required runtime/cache file;
`definitions` pins `{path, sha256}` for the build/dependency definitions relative
to `project`. `knownCompleteCacheProvenance` identifies the successful build and
source/dependency identity. Paths must be real, absolute and free of shell
metacharacters; writable tool/cache/project roots must belong to `workRoot`.

The expected manifest hash is a separate argument, not read from the manifest.
Missing bytes, changed hashes/definitions, missing inventory scopes or unsafe
paths reject before Gradle starts. This validates the caller's complete pinned
snapshot; it does not solve an arbitrary dynamic Gradle dependency graph. A
changed dependency graph needs a new trusted compatible inventory. Any remaining
resolver failure is a real failed offline build, never a download fallback.

Both outer Android and nested AAR builds directly use the validated distribution.
The ordinary R1 Gradle path requires its explicit local binary and checks active
version/distribution hashes. The nested build also disables JVM auto-download.
Private AAR publication omits only the Javadoc classifier because AGP's Dokka
external-link resolver is independent of Gradle offline; runtime AARs are retained.
The project-owned init runs after Flutter's AAR init. Vendor source is unchanged.

On Windows, the entry samples its process descendants and their TCP/UDP tables.
Observed non-loopback TCP, any task UDP endpoint, observer failure or download
log stops/fails the owned build tree. These are separate evidence classes:

| Stop reason | Supported observation |
|---|---|
| `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE` | Task PID owns a UDP endpoint. Remote destination and actual datagram transmission are unproven. |
| `NON_LOOPBACK_TCP_ENDPOINT_OBSERVED` | Sampled TCP remote endpoint/state is non-loopback. Payload transfer is unproven. |
| `DOWNLOAD_ATTEMPT_OBSERVED` | A log matches the current download-attempt recognition rules, including final logs after exit. |
| `OBSERVER_FAILED` | Observation failed or the root process was not observable; fail closed even if the child has since exited. Details are recorded separately. Capability failure before launch rejects preflight with the same category prefix. |
| `None` | No classified signal in this sample, not proof of no network. |

In default mode, UDP and non-loopback TCP still stop the owned tree; renaming evidence does not
permit continuation or a retry. Loopback Gradle IPC is permitted. Final
stdout/stderr are scanned again after process exit. There is no automatic retry.
Raw process/network observations may contain local identifiers and stay LOCAL_ONLY.
Sampling can miss short-lived/failed attempts between snapshots; **absolute
process-tree no-network is NOT_PROVEN**, even when no attempt was observed.

Run guard/lifecycle unit tests with `python apps/android/scripts/test_offline_debug.py`.
They use pure classification functions, temporary byte fixtures and fully mocked
observer/Popen/taskkill collaborators. A process-local audit hook rejects real
process, socket and native DLL access, including escapes caught by tested code.
They do not substitute for real build or device evidence. The 2026-10-26 UDP
semantics task authorizes only these isolated checks/static review: no real entry,
Gradle/Flutter/AAR/Kotlin/APK/device run. The earlier actual build remains stopped
and incomplete; its original labels, logs, exit codes and partial are retained.

## Owner's 2026-10-26 single-build revalidation

Only the separately dispatched task with Blob
`6c09cca14b120cb0eb39cc2909e84a7203d252ed` authorizes one ordinary build using
`--single-attempt-authorized`. Default behavior above remains conservative.
The independently pinned manifest must declare `singleAttemptAuthorization`
with that `taskBlob`, integer `maxStarts: 1`, `testsExit: 0`, `staticExit: 0`.
The caller first verifies the actual isolated/static receipts and source hashes;
this declaration is a local attestation, not authentication of Owner authority.

In that mode, UDP endpoint observations alone are recorded and counted without
stopping; destination/datagram transmission remain unproven. Download logs and
non-loopback TCP have priority over UDP, and observation failures/malformed rows
still fail closed. Private samples retain the classification and stop decision.
Counters count sampled endpoint rows, not unique sockets, packets or datagrams.

Before Popen, the entry exclusively creates
`<workRoot>/single-offline-build-20261026.claim.json`. A second claim or reuse of
that work root via default mode is rejected. A failed spawn retains the claim;
it never authorizes a retry. Failed validation/preflight does not start Gradle.
A preexisting APK is rejected in this mode to avoid mistaking an old artifact
for the newly generated result. Do not delete the marker or change roots to
repeat a spent authorization. The authorized nested AAR work belongs to the
same one outer assembleDebug attempt; it is not another authorized root attempt.
