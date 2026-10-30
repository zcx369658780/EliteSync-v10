"""Source-only Linux migration prepackage. Never launches a process or network call.

The emitted Composer files are candidate solver INPUTS, never resolved locks.
Real toolchain activation, source qualification and budgeted runtime need a new
Owner-authorized execution after this task's dynamic STOP.
"""
import argparse
from contextlib import contextmanager
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import time

TASK = '03c40a831ed37d8610c9a9aa2760c9a94e17269b'
TASK_ID = 'V1015_LINUX_TOOLCHAIN_BATCH_MIGRATION_20261030'
PARENT = '8941323808ce0cdfc68b9f0c3796f86400a75d43'
ROOT_NAME = 'v1015-unified-linux-toolchain-20261030'
COMPOSER_BLOB = 'd30ee1bb2af2bafb0416fa07b6005d53d6ab4f56'
LOCK_BLOB = '66327f584d3961c2b53391bb012047dda9cc9d23'


class Gate(ValueError):
    pass


def need(condition, reason):
    if not condition:
        raise Gate(reason)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(raw):
    return hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()


def canonical(value):
    return (json.dumps(value, indent=2, sort_keys=True, ensure_ascii=True) + '\n').encode()


def local(path):
    path = Path(os.path.abspath(path))
    for part in [path, *path.parents]:
        need(not part.is_symlink(), 'REPARSE_OR_SYMLINK')
        if part.exists():
            st = part.lstat()
            need(not getattr(st, 'st_file_attributes', 0) & 0x400, 'REPARSE_OR_SYMLINK')
    return path


def input_pair(backend):
    backend = local(backend)
    composer = local(backend / 'composer.json')
    lock = local(backend / 'composer.lock')
    need(composer.stat().st_nlink == lock.stat().st_nlink == 1, 'SOURCE_HARDLINK')
    raw = composer.read_bytes()
    lock_raw = lock.read_bytes()
    need(blob(raw) == COMPOSER_BLOB and blob(lock_raw) == LOCK_BLOB,
         'FIXED_PARENT_COMPOSER_INPUT_CHANGED')
    return json.loads(raw), json.loads(lock_raw), raw, lock_raw


def read_private(path):
    path = local(path)
    info = path.stat()
    need(stat.S_ISREG(info.st_mode) and info.st_nlink == 1, 'SOURCE_HARDLINK_OR_NONFILE')
    return path.read_bytes()


def profile(current, major):
    """Prepare documented constraints; no dependency solver is imitated here."""
    need(major in (12, 13), 'FRAMEWORK_NOT_AUTHORIZED')
    value = copy.deepcopy(current)
    value['require']['php'] = '~8.4.0'
    value['require']['laravel/framework'] = '^' + str(major) + '.0'
    if major == 13:
        # Official 13.x upgrade guide and laravel/laravel 13.x composer.json.
        value['require']['laravel/tinker'] = '^3.0'
        value['require-dev']['phpunit/phpunit'] = '^12.0'
        value['require-dev']['nunomaduro/collision'] = '^8.6'
    value['scripts'] = {}
    value['config']['allow-plugins'] = {}
    value['config'].pop('platform', None)
    return value


def validate_profile(value, current, major):
    need(value == profile(current, major), 'PROFILE_NOT_EXACT_DOCUMENTED_TRANSFORM')
    need(not value['scripts'] and not value['config']['allow-plugins'], 'COMPOSER_HOOKS_ENABLED')
    need('platform' not in value['config'], 'SYNTHETIC_PLATFORM_FORBIDDEN')
    return 'SOLVER_INPUT_ONLY'


def dependency_inventory(current, old_lock):
    """Inventory every old transitive with its actual constraints and provenance."""
    entries = []
    names = set()
    for section in ('packages', 'packages-dev'):
        for package in old_lock[section]:
            name = package['name']
            need(name not in names, 'DUPLICATE_LOCK_PACKAGE')
            names.add(name)
            source = package.get('source', {})
            entries.append(dict(name=name, locked_version=package['version'],
                                old_lock_section=section, require=package.get('require', {}),
                                conflict=package.get('conflict', {}),
                                source=source, dist=package.get('dist', {}),
                                license=package.get('license', []),
                                root_constraint=current.get('require', {}).get(name,
                                    current.get('require-dev', {}).get(name)),
                                candidate_status='OLD_LOCK_ONLY_NOT_TARGET_RESOLUTION'))
    return sorted(entries, key=lambda value: value['name'])


SURFACES = {
    'mysql_mariadb_upsert': r'->upsert\s*\(',
    'csrf_legacy_alias': r'\b(?:VerifyCsrfToken|ValidateCsrfToken)\b',
    'queue_event_renames': r'\b(?:JobAttempted|QueueBusy|exceptionOccurred)\b',
    'cache_serialization': r'\bCache::(?:put|remember|forever|rememberForever)\s*\(',
    'custom_cache_or_queue_driver': r'(?:Cache|Queue)::extend\s*\(',
    'legacy_global_array_helpers': r'\b(?:array_first|array_last)\s*\(',
    'container_nullable_defaults': r'\?Carbon(?:Immutable)?\s+\$\w+\s*=\s*null',
    'model_uuid_trait': r'\bHasUuids\b',
    'workerman_entry': r'\bWorker::runAll\s*\(',
}


def surface_inventory(backend):
    entries = []
    for folder in ('app', 'bootstrap', 'config', 'routes', 'tests'):
        base = local(backend / folder)
        for file in sorted(base.rglob('*.php')):
            file = local(file)
            raw = read_private(file)
            text = raw.decode('utf-8')
            for key, pattern in SURFACES.items():
                hits = [index for index, line in enumerate(text.splitlines(), 1)
                        if re.search(pattern, line)]
                if hits:
                    entries.append(dict(surface=key, path=file.relative_to(backend).as_posix(),
                                        lines=hits, blob=blob(raw),
                                        result='STATIC_TOUCHPOINT_NOT_RUNTIME_FAILURE'))
    return entries


def build_prepackage(backend):
    backend = local(backend)
    current, old_lock, raw, lock_raw = input_pair(backend)
    profiles = {str(major): profile(current, major) for major in (13, 12)}
    for major, value in profiles.items():
        validate_profile(value, current, int(major))
    packages = dependency_inventory(current, old_lock)
    framework = next(x for x in packages if x['name'] == 'laravel/framework')
    return dict(schema=1, task_blob=TASK, sole_parent=PARENT,
                state='BLOCKED_LINUX_EXECUTOR_NOT_AVAILABLE',
                qualification='REGISTERED_WSL_AND_CLIENT_ONLY_LOCAL_ENGINE_UNAVAILABLE',
                execute_enabled=False, active_composer_changed=False,
                composer_lock_status='LOCK_RESOLUTION_PENDING_OLD_LARAVEL11_RETAINED',
                source=dict(composer_blob=blob(raw), composer_sha256=sha(raw),
                            lock_blob=blob(lock_raw), lock_sha256=sha(lock_raw),
                            locked_framework=framework['locked_version']),
                profiles=profiles, packages=packages,
                touchpoints=surface_inventory(backend),
                decision=dict(primary='LARAVEL13_PHP84_UNRESOLVED',
                              fallback='LARAVEL12_PHP84_NOT_ATTEMPTED',
                              owner_final_direction='PENDING_ASTRA_AND_OWNER'),
                runtime={key: 'NOT_RUN_GATE_CLOSED' for key in
                         ['PHP', 'COMPOSER_VALIDATE', 'SOLVER', 'VENDOR', 'LINT',
                          'FEATURE_UNIT', 'API', 'MARIADB', 'HTTP', 'MIGRATION',
                          'SEED', 'RESTART_PERSISTENCE']})


def runtime_execute(*_args, **_kwargs):
    # This invocation is terminally blocked; no JSON flag can turn it into a runner.
    raise Gate('LINUX_EXECUTOR_INSTALL_AUTHORIZATION_REQUIRED_RUNTIME_NOT_IMPLEMENTED_IN_PREPACKAGE')


def monotonic_tick():
    if os.name == 'nt':
        import ctypes
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.GetTickCount64.restype = ctypes.c_uint64
        return kernel.GetTickCount64()
    return int(time.monotonic() * 1000)


@contextmanager
def exclusive_ledger(path):
    """On Windows deny all concurrent writers/deleters, including noncooperators."""
    if os.name == 'nt':
        import ctypes
        import msvcrt
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.CreateFileW.argtypes = [ctypes.c_wchar_p, ctypes.c_uint32, ctypes.c_uint32,
                                      ctypes.c_void_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_void_p]
        kernel.CreateFileW.restype = ctypes.c_void_p
        handle = kernel.CreateFileW(str(path), 0xc0000000, 1, None, 3, 0x00200000, None)
        need(handle != ctypes.c_void_p(-1).value, 'LEDGER_EXCLUSIVE_OPEN')
        try:
            fd = msvcrt.open_osfhandle(handle, os.O_RDWR | os.O_BINARY)
        except BaseException:
            kernel.CloseHandle.argtypes = [ctypes.c_void_p]
            kernel.CloseHandle(handle)
            raise
        with os.fdopen(fd, 'r+b') as file:
            yield file
    else:
        # Current persistence target is Windows. POSIX uses cooperative flock.
        import fcntl
        with path.open('r+b') as file:
            fcntl.flock(file.fileno(), fcntl.LOCK_EX)
            yield file


def check_window(first):
    need(type(first.get('tick_start')) is int
         and 0 <= monotonic_tick() - first['tick_start'] < 14400000, 'TASK_WINDOW')


def write_prepackage(backend, task_root):
    """Emit task-owned source artifacts after durable PREPARE; never execute them."""
    root = local(task_root)
    need(root.name == ROOT_NAME and root.is_dir(), 'TASK_ROOT_REQUIRED')
    ledger = local(root / 'execution_ledger.jsonl')
    need(ledger.is_file() and ledger.stat().st_nlink == 1, 'LEDGER_REQUIRED')
    original_ledger = ledger.stat()
    raw = ledger.read_bytes()
    need(raw.endswith(b'\n'), 'TORN_LEDGER_TAIL')
    rows = [json.loads(line) for line in raw.splitlines()]
    need(rows and rows[0].get('task_id') == TASK_ID and rows[0].get('task_blob') == TASK
         and rows[0].get('sole_parent') == PARENT
         and rows[0].get('attempt_id') == 'attempt-0001', 'LEDGER_AUTHORITY')
    st = root.stat()
    need(rows[0].get('workspace') == dict(file_id=st.st_ino, volume=st.st_dev), 'TASK_ROOT_REPLACED')
    need(not any(row.get('action') == 'TERMINAL_STOP' for row in rows), 'TASK_STOPPED')
    check_window(rows[0])
    backend = local(backend)
    need(backend.is_relative_to(root / 'source'), 'SOURCE_OUTSIDE_TASK_ROOT')
    output = local(root / 'linux-prepackage')
    need(not output.exists(), 'PREPACKAGE_ALREADY_EXISTS')
    value = build_prepackage(backend)
    files = {'prepackage.json': canonical(value)}
    for major, manifest in value['profiles'].items():
        files['composer-laravel' + major + '-php84.input.json'] = canonical(manifest)
    prepare = dict(seq=len(rows) + 1, action='PREPARE_SOURCE_ONLY_PREPACKAGE_WRITE',
                   paths=['linux-prepackage/' + name for name in files],
                   hashes={name: sha(data) for name, data in files.items()}, runtime=0)
    with exclusive_ledger(ledger) as file:
        # Source scanning may be lengthy. Recheck under the SAME original handle
        # before PREPARE and hold it through output writes; no path reopen to append.
        info = os.fstat(file.fileno())
        need((info.st_ino, info.st_dev) == (original_ledger.st_ino, original_ledger.st_dev)
             and info.st_nlink == 1, 'LEDGER_REPLACED_DURING_SCAN')
        current = file.read()
        need(current.endswith(b'\n'), 'TORN_LEDGER_TAIL')
        current_rows = [json.loads(line) for line in current.splitlines()]
        need(not any(row.get('action') == 'TERMINAL_STOP' for row in current_rows), 'TASK_STOPPED')
        need(current == raw, 'LEDGER_CHANGED_DURING_SCAN')
        current_root = local(root).stat()
        need((current_root.st_ino, current_root.st_dev) == (st.st_ino, st.st_dev), 'TASK_ROOT_REPLACED')
        check_window(rows[0])
        file.write(canonical(prepare).replace(b'\n', b'') + b'\n')
        file.flush()
        os.fsync(file.fileno())
        output = local(output)
        output.mkdir()
        for name, data in files.items():
            check_window(rows[0])
            with (output / name).open('xb') as artifact:
                artifact.write(data)
                artifact.flush()
                os.fsync(artifact.fileno())
            need((output / name).read_bytes() == data, 'PREPACKAGE_WRITE_READBACK')
    return dict(state=value['state'], files=len(files), execute_enabled=False)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', nargs='?', default='inspect', choices=['inspect', 'prepackage', 'execute'])
    parser.add_argument('--source-root', type=Path)
    parser.add_argument('--task-root', type=Path)
    args = parser.parse_args(argv)
    if args.action == 'execute':
        runtime_execute()
    if args.source_root is None:
        need(args.action == 'inspect', 'SOURCE_ROOT_REQUIRED')
        print(json.dumps(dict(state='SOURCE_ONLY_PREPACKAGE', execute_enabled=False)))
        return 0
    if args.action == 'prepackage':
        need(args.task_root is not None, 'TASK_ROOT_REQUIRED')
        result = write_prepackage(args.source_root, args.task_root)
    else:
        result = build_prepackage(args.source_root)
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
