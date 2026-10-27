"""Pinned local Gradle 8.14 debug entry; caller supplies a trusted cache inventory.

No wrapper/bootstrap fallback. Missing/mismatched inventory bytes fail before a
build subprocess. Windows process/socket samples are bounded observations, not
proof that every short-lived network attempt is visible.
"""
import argparse
import hashlib
import ipaddress
import json
import os
from pathlib import Path
import re
import subprocess
import time
import zipfile
from owned_aar_init import OwnedInitError, verify_inventory as verify_owned_inventory

ROOT_NAMES = {'gradle', 'cache', 'flutter', 'pub', 'java', 'android', 'project'}
PINNED_BIN = 'af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab'
SINGLE_ATTEMPT_TASK_BLOB = '6c09cca14b120cb0eb39cc2909e84a7203d252ed'
SINGLE_ATTEMPT_MARKER = 'single-offline-build-20261026.claim.json'


class PreflightError(ValueError):
    pass


def sha256(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def require(ok, code):
    if not ok:
        raise PreflightError(code)


def checked_path(value):
    require(isinstance(value, str) and not re.search(r'[&|<>%!"`^()\r\n]', value), 'UNSAFE_PATH')
    p = Path(value)
    require(p.is_absolute() and '..' not in p.parts, 'ABSOLUTE_PATH')
    require(p.exists(), 'MISSING_PATH')
    for ancestor in [p, *p.parents]:
        require(not ancestor.is_symlink() and not getattr(ancestor.lstat(), 'st_file_attributes', 0) & 1024,
                'REDIRECTED_PATH')
    return p


def preflight(manifest, expected_sha256):
    require(re.fullmatch(r'[0-9a-f]{64}', expected_sha256 or '') is not None, 'MANIFEST_HASH')
    require(sha256(manifest) == expected_sha256, 'MANIFEST_HASH')
    config = json.loads(Path(manifest).read_text(encoding='utf-8'))
    require(config.get('schema') == 1 and config.get('gradleVersion') == '8.14', 'GRADLE_VERSION')
    require(set(config.get('roots', {})) == ROOT_NAMES, 'ROOT_SCOPES')
    roots = {name: checked_path(value) for name, value in config['roots'].items()}
    work = checked_path(config['workRoot'])
    for name in ['gradle', 'cache', 'flutter', 'pub', 'project']:
        require(roots[name].is_relative_to(work), 'WRITABLE_ROOT_OUTSIDE_WORK')
    inventory = config.get('inventory', [])
    require(any(x.get('root') == 'gradle' and x.get('path') == 'bin/gradle.bat' for x in inventory), 'GRADLE_BIN')
    seen = set()
    for item in inventory:
        name, relative = item['root'], item['path']
        p = Path(relative)
        require(name in roots and not p.is_absolute() and '..' not in p.parts and relative not in ('', '.'), 'RELATIVE_PATH')
        target = roots[name] / p
        require(target.is_file(), 'MISSING_FILE:' + name + '/' + relative)
        checked_path(str(target))
        require(sha256(target) == item['sha256'], 'FILE_HASH:' + name + '/' + relative)
        seen.add(name)
    require(seen == ROOT_NAMES, 'EMPTY_SCOPE')
    # The caller's entire known-complete runtime/cache snapshot is checked above.
    # Build/dependency definitions are pinned separately, so a changed graph
    # cannot silently reuse an attestation for a different source tree.
    for item in config.get('definitions', []):
        p = Path(item['path'])
        require(not p.is_absolute() and '..' not in p.parts, 'DEFINITION_PATH')
        target = roots['project'] / p
        require(target.is_file() and sha256(target) == item['sha256'], 'DEFINITION_CHANGED')
    require(sha256(roots['gradle'] / 'bin/gradle.bat') == PINNED_BIN, 'PINNED_GRADLE_BIN')
    require((roots['gradle'] / 'lib/gradle-core-8.14.jar').is_file(), 'GRADLE_RUNTIME_VERSION')
    receipt = roots['gradle'] / 'lib/gradle-base-services-8.14.jar'
    require(receipt.is_file(), 'GRADLE_RUNTIME_VERSION')
    try:
        with zipfile.ZipFile(receipt) as archive:
            version = archive.read('org/gradle/build-receipt.properties').decode('utf-8')
        require(re.search(r'(?m)^versionNumber=8\.14\s*$', version) is not None, 'GRADLE_RUNTIME_VERSION')
    except (zipfile.BadZipFile, KeyError, UnicodeError) as error:
        raise PreflightError('GRADLE_RUNTIME_VERSION') from error
    require(config.get('knownCompleteCacheProvenance'), 'CACHE_PROVENANCE')
    try:
        verify_owned_inventory(config, roots)
    except (OwnedInitError, OSError) as error:
        raise PreflightError(str(error)) from error
    return config, roots, work


def external_tcp(address):
    return not ipaddress.ip_address(address).is_loopback


def download_observed(log):
    return re.search(r'(?im)^\s*(?:Downloading\b|Fetching packages\b|Could not (?:GET|HEAD) [\'\"]?https?://)', log) is not None


def observation_stop_reason(sockets, log, *, observer_failed=False):
    """Classify sampled evidence, not packet transmission or absolute safety.

    UDP owner-PID rows expose no remote destination and do not prove that a
    datagram was sent.
    TCP remote/state rows likewise do not prove payload transfer. The separate
    policy keeps default stops and the Owner's explicit one-attempt exception.
    None means only no signal in this sample.
    """
    if observer_failed:
        return 'OBSERVER_FAILED'
    udp_endpoint = non_loopback_tcp = False
    try:
        for endpoint in sockets:
            if endpoint['protocol'] == 'UDP':
                if endpoint['remote'] is not None:
                    return 'OBSERVER_FAILED'
                udp_endpoint = True
            elif endpoint['protocol'] == 'TCP':
                non_loopback_tcp |= external_tcp(endpoint['remote'])
            else:
                return 'OBSERVER_FAILED'
    except (KeyError, TypeError, ValueError):
        return 'OBSERVER_FAILED'
    if download_observed(log):
        return 'DOWNLOAD_ATTEMPT_OBSERVED'
    if non_loopback_tcp:
        return 'NON_LOOPBACK_TCP_ENDPOINT_OBSERVED'
    if udp_endpoint:
        return 'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE'
    return None


def policy_stop_reason(signal, *, single_attempt_authorized=False):
    """Only this explicitly authorized mode permits an unknown UDP signal alone."""
    if signal is None or (signal == 'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE' and single_attempt_authorized):
        return None
    if signal in {'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE', 'NON_LOOPBACK_TCP_ENDPOINT_OBSERVED',
                  'DOWNLOAD_ATTEMPT_OBSERVED', 'OBSERVER_FAILED'}:
        return signal
    return 'OBSERVER_FAILED'


def claim_single_build(work, authorization):
    """Consume the task's single reservation atomically before starting Gradle.

    The independently pinned caller manifest declares the Owner task and passed
    validation. This is a local replay guard, not authentication of the Owner.
    A failed spawn also retains the reservation; it never permits a retry.
    """
    require(isinstance(authorization, dict) and authorization.get('taskBlob') == SINGLE_ATTEMPT_TASK_BLOB
            and type(authorization.get('maxStarts')) is int and authorization['maxStarts'] == 1
            and type(authorization.get('testsExit')) is int and authorization['testsExit'] == 0
            and type(authorization.get('staticExit')) is int and authorization['staticExit'] == 0,
            'SINGLE_BUILD_VALIDATION')
    marker = work / SINGLE_ATTEMPT_MARKER
    try:
        with marker.open('x', encoding='utf-8') as stream:
            json.dump({'taskBlob': SINGLE_ATTEMPT_TASK_BLOB, 'reservedStarts': 1, 'entryPid': os.getpid()}, stream)
    except FileExistsError as error:
        raise PreflightError('SINGLE_BUILD_BUDGET_ALREADY_CLAIMED') from error
    return marker


def accepted_exit(code, reason, log):
    return code == 0 and reason is None and not download_observed(log)


def execute(manifest, expected_sha256, receipt_dir, *, single_attempt_authorized=False):
    config, roots, work = preflight(manifest, expected_sha256)
    if os.name != 'nt':
        raise PreflightError('WINDOWS_ONLY')
    try:
        from windows_build_observer import Observer
        observer = Observer()
        observer.sample(os.getpid())  # Verify read capability before launching Gradle.
    except Exception as error:
        raise PreflightError('OBSERVER_FAILED:' + type(error).__name__) from error
    observer.known.clear()
    require(not (work / SINGLE_ATTEMPT_MARKER).exists(), 'SINGLE_BUILD_BUDGET_ALREADY_CLAIMED')
    apk = roots['project'] / 'apps/android/app/build/outputs/apk/debug/app-debug.apk'
    if single_attempt_authorized:
        require(not apk.exists(), 'PREEXISTING_APK')
    output = Path(receipt_dir)
    output.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    for key in ['JAVA_TOOL_OPTIONS', '_JAVA_OPTIONS', 'JDK_JAVA_OPTIONS', 'JAVA_OPTS', 'GRADLE_OPTS']:
        env.pop(key, None)
    for key in list(env):
        if key.startswith('ORG_GRADLE_PROJECT_') or key in ['GRADLE_RO_DEP_CACHE', 'ANDROID_PREFS_ROOT', 'ANDROID_SDK_HOME']:
            env.pop(key, None)
    env.update({'JAVA_HOME': str(roots['java']), 'GRADLE_USER_HOME': str(roots['cache']),
                'FLUTTER_ROOT': str(roots['flutter']), 'FLUTTER_HOME': str(roots['flutter']),
                'PUB_CACHE': str(roots['pub']), 'ANDROID_HOME': str(roots['android']),
                'ANDROID_SDK_ROOT': str(roots['android']), 'ANDROID_USER_HOME': str(work / 'android-user'),
                'TEMP': str(work / 'tmp'), 'TMP': str(work / 'tmp'),
                'FLUTTER_SUPPRESS_ANALYTICS': 'true', 'DART_SUPPRESS_ANALYTICS': 'true', 'CI': 'true'})
    (work / 'tmp').mkdir(exist_ok=True)
    command = [str(roots['gradle'] / 'bin/gradle.bat'), ':app:assembleDebug', '--offline',
               '--console=plain', '--no-daemon', '--max-workers=2', '--gradle-user-home', str(roots['cache']),
               '-Dorg.gradle.java.installations.auto-download=false', '-Porg.gradle.java.installations.auto-download=false',
               '-Porg.gradle.java.installations.auto-detect=false',
               '-PflutterDartDefines=ELITESYNC_V1015_LOCAL_BUILD=true,ELITESYNC_V1015_R1_LOCAL_BUILD=true',
               '-PrelationshipDualDeviceBuild=true', '-PlocalOfflineGradleBin=' + str(roots['gradle'] / 'bin/gradle.bat')]
    record = {'command': command, 'manifestSha256': expected_sha256, 'gradleVersion': '8.14',
              'preflightPassed': True, 'ordinaryDebug': True, 'wrapperFallback': False,
              'networkClaim': 'SAMPLED_TASK_TCP_UDP_ONLY_ABSOLUTE_NO_NETWORK_NOT_PROVEN',
              'singleAttemptAuthorized': single_attempt_authorized,
              'udpPolicy': 'OBSERVE_ONLY' if single_attempt_authorized else 'STOP',
              'cacheProvenance': config['knownCompleteCacheProvenance']}
    if single_attempt_authorized:
        marker = claim_single_build(work, config.get('singleAttemptAuthorization'))
        record.update({'singleAttemptReservation': str(marker), 'reservedStarts': 1})
    (output / 'invocation.json').write_text(json.dumps(record, indent=2))
    started = time.monotonic(); reason = None; samples = 0; observer_failure_detail = None
    udp_samples = udp_observations = 0
    with (output / 'stdout.txt').open('xb') as stdout, (output / 'stderr.txt').open('xb') as stderr, \
            (output / 'process-network-private.jsonl').open('x', encoding='utf-8') as observations:
        process = subprocess.Popen(command, cwd=roots['project'] / 'apps/android', env=env,
                                   stdout=stdout, stderr=stderr, creationflags=subprocess.CREATE_NO_WINDOW)
        (output / 'process.json').write_text(json.dumps({'pid': process.pid}))
        try:
            while process.poll() is None:
                before = time.monotonic()
                processes, sockets = observer.sample(process.pid)
                log = (output / 'stdout.txt').read_text(errors='replace') + (output / 'stderr.txt').read_text(errors='replace')
                signal = observation_stop_reason(sockets, log)
                reason = policy_stop_reason(signal, single_attempt_authorized=single_attempt_authorized)
                udp_count = sum(isinstance(x, dict) and x.get('protocol') == 'UDP' for x in sockets)
                udp_samples += bool(udp_count); udp_observations += udp_count
                observations.write(json.dumps({'hostMonotonic': before, 'processes': processes, 'sockets': sockets,
                                              'classification': signal, 'stopReason': reason, 'udpEndpointCount': udp_count}) + '\n')
                observations.flush(); samples += 1
                if reason is None and before - started > 1200:
                    reason = 'BUILD_TIMEOUT'
                if reason:
                    break
                time.sleep(.1)
        except ProcessLookupError:
            reason = observation_stop_reason([], '', observer_failed=True)
            observer_failure_detail = 'ROOT_PROCESS_NOT_OBSERVABLE'
        except Exception as error:
            reason = observation_stop_reason([], '', observer_failed=True)
            observer_failure_detail = type(error).__name__
        finally:
            if reason and process.poll() is None:
                stopped = subprocess.run(['taskkill', '/PID', str(process.pid), '/T', '/F'], capture_output=True)
                (output / 'stop.stdout.txt').write_bytes(stopped.stdout)
                (output / 'stop.stderr.txt').write_bytes(stopped.stderr)
            code = process.wait(timeout=30)
    final_log = (output / 'stdout.txt').read_text(errors='replace') + (output / 'stderr.txt').read_text(errors='replace')
    if download_observed(final_log):
        reason = reason or observation_stop_reason([], final_log)
    record.update({'exit': code, 'stopReason': reason, 'networkSamples': samples,
                   'samplesWithUdpEndpoints': udp_samples, 'udpEndpointObservations': udp_observations,
                   'observerFailureDetail': observer_failure_detail,
                   'downloadLogObserved': download_observed(final_log),
                   'observedTaskPids': sorted(observer.known),
                   'elapsedSeconds': time.monotonic() - started, 'processExitConfirmed': True,
                   'stdoutSha256': sha256(output / 'stdout.txt'), 'stderrSha256': sha256(output / 'stderr.txt'),
                   'observationsSha256': sha256(output / 'process-network-private.jsonl'),
                   'samplingLimit':'Short-lived/failed attempts between samples and non-socket networking are not excluded; UDP destination and datagram transmission are unproven. Only the explicit single-attempt mode records UDP alone without stopping.'})
    if accepted_exit(code, reason, final_log):
        if not apk.is_file():
            reason = 'BUILD_ARTIFACT_MISSING'
        else:
            record.update({'apk': str(apk), 'apkBytes': apk.stat().st_size, 'apkSha256': sha256(apk)})
    record.update({'stopReason': reason, 'buildProcessesStarted': 1,
                   'stage': 'BUILD_COMPLETED' if code == 0 and reason is None else 'BUILD_FAILED_OR_STOPPED'})
    (output / 'result.json').write_text(json.dumps(record, indent=2))
    print(json.dumps(record))
    return code if reason is None else 90


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--sha256', required=True)
    parser.add_argument('--receipt-dir', type=Path, required=True)
    parser.add_argument('--single-attempt-authorized', action='store_true',
                        help='Owner task 20261026 only: reserve one build; record UDP alone without stopping')
    args = parser.parse_args()
    try:
        raise SystemExit(execute(args.manifest, args.sha256, args.receipt_dir,
                                 single_attempt_authorized=args.single_attempt_authorized))
    except PreflightError as error:
        print(json.dumps({'stage': 'PREFLIGHT_REJECTED', 'reason': str(error), 'buildProcessesStarted': 0}))
        raise SystemExit(2)
