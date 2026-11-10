"""Capture committed Dart-only changes and apply them to a fresh Project copy.

Git is read-only here. Dependency changes, Android changes and tracked Flutter
worktree/index changes are rejected. Other committed paths are not overlaid.
"""
import base64
import copy
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import subprocess

from sandbox_owned_session_cleanup import windows_arguments

MODULE = 'apps/flutter_elitesync_module'
FILE_LIMIT = 2000
BYTE_LIMIT = 16*1024**2


def _git(root, *args, allowed=(0,)):
    result = subprocess.run(['git', '-C', str(root), *args], capture_output=True, timeout=30)
    if result.returncode not in allowed:
        raise ValueError('Read-only Git identity/input check failed')
    return result


def _text(raw):
    try:
        return raw.decode('utf-8').replace('\r\n', '\n').encode('utf-8')
    except UnicodeDecodeError as error:
        raise ValueError('UTF-8 source text required') from error


def _allowed(path):
    if (type(path) is not str or '\\' in path or ':' in path or any(ord(c)<32 for c in path)
            or PurePosixPath(path).as_posix() != path or '..' in PurePosixPath(path).parts
            or not path.startswith(MODULE+'/')):
        raise ValueError('Literal module-relative Dart path required')
    relative = PurePosixPath(path).relative_to(MODULE)
    if len(relative.parts)<2 or relative.parts[0] not in ('lib','test') or relative.suffix != '.dart':
        raise ValueError('Only lib/test Dart additions and modifications are covered')
    return relative


def _blob(root, commit, path):
    listing = _git(root, 'ls-tree', '-z', commit, '--', path).stdout
    if not listing or listing.split(b' ',1)[0] not in (b'100644', b'100755'):
        raise ValueError('Regular committed source blob required')
    size = int(_git(root, 'cat-file', '-s', commit+':'+path).stdout)
    if size>BYTE_LIMIT:
        raise ValueError('Overlay byte limit exceeded')
    raw = _git(root, 'show', commit+':'+path).stdout
    if len(raw)!=size:
        raise ValueError('Committed source size changed')
    _text(raw)
    return raw


def _canonical(manifest):
    return json.dumps(manifest, sort_keys=True, separators=(',',':'), ensure_ascii=True).encode('utf-8')


def _clean(root):
    if _git(root, 'diff', '--quiet', 'HEAD', '--', MODULE, 'apps/android', allowed=(0,1)).returncode:
        raise ValueError('Tracked Flutter/Android worktree and index must match HEAD')


def capture_overlay(product_root, baseline_commit):
    """Read committed inputs before creating any candidate or consuming a run."""
    root = Path(product_root).resolve()
    actual = Path(_git(root, 'rev-parse', '--show-toplevel').stdout.decode().strip()).resolve()
    if root!=actual:
        raise ValueError('Exact product Git root required')
    if type(baseline_commit) is not str or not re.fullmatch(r'[0-9a-fA-F]{7,40}', baseline_commit):
        raise ValueError('Literal baseline commit identity required')
    head = _git(root, 'rev-parse', '--verify', 'HEAD^{commit}').stdout.decode().strip()
    baseline = _git(root, 'rev-parse', '--verify', baseline_commit+'^{commit}').stdout.decode().strip()
    if _git(root, 'merge-base', '--is-ancestor', baseline, head, allowed=(0,1)).returncode:
        raise ValueError('Baseline must be an ancestor of current HEAD')
    _clean(root)
    if _git(root, 'diff', '--quiet', baseline, head, '--', 'apps/android', allowed=(0,1)).returncode:
        raise ValueError('Android source changes are outside this overlay')
    dependencies = {}
    for name in ('pubspec.yaml','pubspec.lock'):
        path = MODULE+'/'+name
        before, after = _blob(root, baseline, path), _blob(root, head, path)
        if _text(before)!=_text(after):
            raise ValueError('Flutter dependency changes require a different input preparation')
        dependencies[name] = hashlib.sha256(_text(after)).hexdigest()
    raw = _git(root, 'diff', '--name-status', '-z', '--no-renames', baseline, head, '--', MODULE).stdout
    tokens = raw.rstrip(b'\0').split(b'\0') if raw else []
    if len(tokens)%2 or len(tokens)//2>FILE_LIMIT:
        raise ValueError('Overlay file limit or diff format exceeded')
    rows, total = [], 0
    for index in range(0,len(tokens),2):
        status, path = tokens[index].decode('ascii'), tokens[index+1].decode('utf-8')
        if path in (MODULE+'/pubspec.yaml', MODULE+'/pubspec.lock') and status=='M':
            continue  # CRLF-only dependency text differences were checked above.
        if status not in ('A','M'):
            raise ValueError('Deleted, renamed or non-text source changes are not covered')
        _allowed(path)
        current = _blob(root, head, path)
        previous = _blob(root, baseline, path) if status=='M' else None
        total += len(current)+(len(previous) if previous is not None else 0)
        if total>BYTE_LIMIT:
            raise ValueError('Overlay byte limit exceeded')
        rows.append(dict(path=path, status=status, content_b64=base64.b64encode(current).decode('ascii'),
            sha256=hashlib.sha256(current).hexdigest(), bytes=len(current),
            baseline_b64=base64.b64encode(previous).decode('ascii') if previous is not None else None,
            baseline_sha256=hashlib.sha256(previous).hexdigest() if previous is not None else None,
            baseline_bytes=len(previous) if previous is not None else 0))
    identity = dict(source_commit=head,
        apps_tree=_git(root, 'rev-parse', head+':apps').stdout.decode().strip(),
        services_tree=_git(root, 'rev-parse', head+':services').stdout.decode().strip())
    if _git(root, 'rev-parse','HEAD').stdout.decode().strip()!=head:
        raise ValueError('HEAD changed while capturing source')
    _clean(root)
    manifest = dict(baseline_commit=baseline, source_identity=identity,
                    dependency_sha256=dependencies, files=rows)
    return dict(manifest=manifest, manifest_sha256=hashlib.sha256(_canonical(manifest)).hexdigest())


def _validated(overlay):
    manifest = overlay['manifest']
    if hashlib.sha256(_canonical(manifest)).hexdigest()!=overlay['manifest_sha256']:
        raise ValueError('Overlay manifest changed')
    identity = manifest['source_identity']
    if any(type(identity.get(key)) is not str or not re.fullmatch(r'[0-9a-f]{40}',identity[key])
           for key in ('source_commit','apps_tree','services_tree')):
        raise ValueError('Full committed source identity required')
    if len(manifest['files'])>FILE_LIMIT:
        raise ValueError('Overlay file limit exceeded')
    decoded, seen, total = [], set(), 0
    for row in manifest['files']:
        _allowed(row['path'])
        if row['path'].casefold() in seen or row['status'] not in ('A','M'):
            raise ValueError('Ambiguous overlay path/status')
        seen.add(row['path'].casefold())
        contents = []
        for prefix in ('','baseline_'):
            encoded = row['content_b64'] if not prefix else row['baseline_b64']
            if prefix and row['status']=='A':
                if encoded is not None or row['baseline_sha256'] is not None or row['baseline_bytes']!=0:
                    raise ValueError('Added file must not have baseline bytes')
                contents.append(None); continue
            try:
                content = base64.b64decode(encoded, validate=True)
            except (ValueError,TypeError) as error:
                raise ValueError('Valid base64 source bytes required') from error
            if (type(row[prefix+'bytes']) is not int or len(content)!=row[prefix+'bytes']
                    or hashlib.sha256(content).hexdigest()!=row[prefix+'sha256']):
                raise ValueError('Overlay content identity changed')
            _text(content); total += len(content)
            if total>BYTE_LIMIT:
                raise ValueError('Overlay byte limit exceeded')
            contents.append(content)
        decoded.append((row, *contents))
    return decoded


def _target(module, relative):
    target = module.joinpath(*relative.parts)
    if not target.resolve().is_relative_to(module.resolve()):
        raise ValueError('Overlay target escapes private module')
    for path in [target, *target.parents]:
        if path.exists() or path.is_symlink():
            info = path.lstat()
            if path.is_symlink() or getattr(info,'st_file_attributes',0)&getattr(stat,'FILE_ATTRIBUTE_REPARSE_POINT',0x400):
                raise ValueError('Redirected overlay target denied')
        if path==module:
            break
    return target


def apply_overlay(overlay, project_root):
    """Apply before candidate freezing; partial failures are preserved, never cleaned."""
    rows = _validated(overlay)
    module = Path(project_root).resolve()/MODULE
    if not module.is_dir():
        raise FileNotFoundError('Copied private Flutter module required')
    if module.resolve()!=module:
        raise ValueError('Private module ancestry must not redirect')
    for row, current, baseline in rows:
        relative = _allowed(row['path']); target = _target(module, relative)
        if row['status']=='A':
            target.parent.mkdir(parents=True, exist_ok=True)
            target = _target(module, relative)
            with target.open('xb') as stream:
                stream.write(_text(current))
        else:
            with target.open('r+b') as stream:
                original = stream.read(BYTE_LIMIT+1)
                if len(original)>BYTE_LIMIT or _text(original)!=_text(baseline):
                    raise ValueError('Private source differs from captured baseline')
                stream.seek(0); stream.write(_text(current)); stream.truncate()
    return dict(applied_files=len(rows), manifest_sha256=overlay['manifest_sha256'])


def retarget_entry(entry, overlay):
    """Purely retarget the rendered local entry's one publication argument."""
    _validated(overlay)
    argv = windows_arguments(entry['launch_request']['command_line'])
    if argv!=entry['argv']:
        raise ValueError('Rendered entry argv and command line disagree')
    old = '-PbuildNumber='+entry['publication_version']
    if sum(arg.startswith('-PbuildNumber=') for arg in argv)!=1 or argv.count(old)!=1:
        raise ValueError('Exactly one bound old publication argument required')
    result = copy.deepcopy(entry)
    identity = overlay['manifest']['source_identity']
    version = '1.0-v1015-'+identity['source_commit'][:12]+'-'+overlay['manifest_sha256'][:12]
    result['argv'] = [('-PbuildNumber='+version) if arg==old else arg for arg in argv]
    result['launch_request']['command_line'] = subprocess.list2cmdline(result['argv'])
    result['publication_version'] = version
    result['base_identity'] = copy.deepcopy(entry['source_identity'])
    result['source_identity'] = copy.deepcopy(identity)
    return result
