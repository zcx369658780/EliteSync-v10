"""Static Windows path/write policy model. No launcher, ACL, observer or runtime authority.

Facts supplied here are mocked declarations, not Windows handle-based validation.
An allowed route does not prove that Gradle or a plugin obeys it.
"""
from dataclasses import dataclass
import ntpath

TASK = 'b6519b415d827232a9dd5f9760b322ec1a7fdaaf'
CAP = 512 * 1024 * 1024

class Rejected(ValueError):
    pass

def require(ok, reason):
    if not ok:
        raise Rejected(reason)

def canonical(path):
    require(isinstance(path, str) and bool(path), 'PATH_REQUIRED')
    text = path.replace('/', '\\')
    drive, tail = ntpath.splitdrive(text)
    require(len(drive) == 2 and drive[0].isalpha() and drive[1] == ':' and tail.startswith('\\'), 'LOCAL_ABSOLUTE_DRIVE_REQUIRED')
    require(':' not in tail and not any(c in tail for c in '%~\x00<>|?*"') and not any(ord(c)<32 for c in tail), 'PATH_ALIAS_OR_STREAM')
    parts = tail.strip('\\').split('\\') if tail.strip('\\') else []
    require(all(p and p not in ('.', '..') and not p.endswith((' ', '.')) for p in parts), 'AMBIGUOUS_OR_TRAVERSING_PATH')
    reserved = {'con','prn','aux','nul',*(f'com{x}' for x in range(1,10)),*(f'lpt{x}' for x in range(1,10))}
    require(not any(p.split('.')[0].lower() in reserved for p in parts), 'DOS_DEVICE_NAME')
    return ntpath.normcase(ntpath.normpath(text))

def within(path, root):
    p, r = canonical(path), canonical(root)
    return p == r or p.startswith(r.rstrip('\\') + '\\')

@dataclass(frozen=True)
class FileFact:
    path: str
    resolved: str
    kind: str
    identity: str
    links: int = 1
    redirected_ancestors: tuple = ()

def check_fact(fact, protected_identities=()):
    require(canonical(fact.path) == canonical(fact.resolved), 'RESOLVED_PATH_ALIAS')
    require(not fact.redirected_ancestors, 'REPARSE_OR_SYMLINK_ANCESTOR')
    require(fact.kind in ('file', 'directory') and bool(fact.identity), 'UNKNOWN_FILE_IDENTITY')
    if fact.kind == 'file':
        require(fact.links == 1, 'HARDLINK_FORBIDDEN')
    require(fact.identity not in protected_identities, 'PROTECTED_FILE_ID_ALIAS')
    return canonical(fact.path)

def classify_state(relative, sealed_hash_matches=None):
    p = relative.replace('\\', '/')
    require(not p.startswith('/') and ':' not in p and all(x not in ('', '.', '..') for x in p.split('/')), 'UNSAFE_RELATIVE_PATH')
    if p in ('caches/8.14/fileHashes/fileHashes.bin', 'caches/journal-1/file-access.bin') or '/.gradle/buildOutputCleanup/' in '/' + p:
        return 'VARIABLE_RUNTIME_STATE'
    if p.startswith(('caches/8.14/groovy-dsl/', 'caches/jars-9/')):
        return 'DERIVED_GENERATED_STATE_NOT_INHERITED'
    if p.startswith('caches/modules-2/'):
        require(sealed_hash_matches is True, 'DEPENDENCY_PIN_REQUIRED')
        return 'PINNED_DEPENDENCY_READ_CANDIDATE'
    raise Rejected('UNKNOWN_CACHE_STATE')

def seed_within_cap(logical_bytes, cap=CAP):
    require(type(logical_bytes) is int and logical_bytes >= 0, 'UNKNOWN_SEED_SIZE')
    return logical_bytes <= cap

def readonly_seed_plan(root, protected_roots, write_roots, *, has_modules2, dependency_closure, readonly_declared):
    p = canonical(root)
    require(not any(within(p,q) or within(q,p) for q in protected_roots), 'LIVE_PROTECTED_CACHE_NOT_A_SEED')
    require(not any(within(p,q) or within(q,p) for q in write_roots), 'READ_WRITE_SEED_OVERLAP')
    require(has_modules2 is True, 'RO_LAYOUT_INVALID_NATIVE_FALLBACK_MUST_NOT_PASS')
    require(dependency_closure is True, 'RO_DEPENDENCY_CLOSURE_UNKNOWN')
    require(readonly_declared is True, 'RO_PROTECTION_UNKNOWN')
    return 'DECLARED_RO_MODEL_ONLY'

class StaticRoutes:
    def __init__(self, task_root, write_roots, protected_roots, owner=TASK):
        require(owner == TASK, 'TASK_OWNER_MISMATCH')
        self.task_root = canonical(task_root)
        self.protected = [canonical(p) for p in protected_roots]
        require(not any(within(self.task_root, p) or within(p, self.task_root) for p in self.protected), 'PROTECTED_ROOT_OVERLAP')
        require(bool(write_roots), 'NO_DECLARED_WRITE_ROOTS')
        self.writes = {k: canonical(v) for k, v in write_roots.items()}
        require(len(set(self.writes.values())) == len(self.writes), 'WRITE_ROOT_ALIAS')
        for p in self.writes.values():
            require(within(p, self.task_root) and p != self.task_root, 'WRITE_ROOT_NOT_TASK_OWNED')
            require(not any(within(p, q) or within(q, p) for q in self.protected), 'PROTECTED_WRITE_OVERLAP')

    def route_mock_write(self, family, fact, protected_identities=()):
        require(family in self.writes, 'UNKNOWN_WRITE_FAMILY')
        p = check_fact(fact, protected_identities)
        require(within(p, self.writes[family]), 'WRITE_OUTSIDE_DECLARED_FAMILY')
        require(not any(within(p, q) for q in self.protected), 'WRITE_TO_PROTECTED_ROOT')
        return 'STATIC_ROUTING_SUPPORTED'

    def environment(self, actual, expected):
        require(set(actual) == set(expected), 'ENVIRONMENT_FALLBACK_OR_EXTRA_OPTION')
        for key, target in expected.items():
            require(canonical(actual[key]) == canonical(target), 'ENVIRONMENT_PATH_CONFLICT:' + key)
        return 'PROPOSED_NOT_EXECUTED'

def check_proposal(command, expected, cwd, expected_cwd):
    require(command == expected and canonical(cwd) == canonical(expected_cwd), 'COMMAND_OR_CWD_CONFLICT')
    require(command.count('assembleAarRelease') == 1 and command.count('--dry-run') == 1 and '--offline' in command, 'G_ONLY_PROPOSAL_REQUIRED')
    require(not any(x in command for x in ['publish', ':app:assembleDebug', 'assembleAarDebug']), 'UNAUTHORIZED_TASK')
    return 'PROPOSED_NOT_EXECUTED'

def global_readiness(unresolved):
    return {'staticModelOnly': True, 'unresolved': list(unresolved),
            'inventoryRuntimeClosureVerified': False, 'readyForPopen': False,
            'runtimeAuthorization': 'ZERO_THIS_TASK',
            'status': 'WRITE_ISOLATION_STILL_BLOCKED' if unresolved else 'WRITE_ISOLATION_STATIC_CONTRACT_DELIVERED'}
