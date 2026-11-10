"""Strict, bounded validation of sampled native-role JSONL; no runtime API.

Caller separately binds the launch/manifest, raw file identities and receipt.
Accepted rows remain non-atomic samples, never full process/DLL closure.
"""
from datetime import datetime, timezone
import hashlib
import ipaddress
import json

from current_product_build_plan import _path


MAX_BYTES = 16 * 1024**2
MAX_LINE_BYTES = 256 * 1024
MAX_ROWS = 10000


def _fields(value, names):
    if type(value) is not dict or set(value) != set(names):
        raise ValueError('exact sampled row fields required')


def _integer(value, low=0, high=2**63 - 1):
    if type(value) is not int or not low <= value <= high:
        raise ValueError('bounded integer required')
    return value


def _canonical(value):
    return str(_path(value)).casefold()


def _utc(value):
    if type(value) is not str:
        raise ValueError('UTC timestamp required')
    stamp = datetime.fromisoformat(value.replace('Z', '+00:00'))
    if stamp.tzinfo is None or stamp.utcoffset() != timezone.utc.utcoffset(stamp):
        raise ValueError('explicit UTC timestamp required')


def _pairs(items):
    result = {}
    for key, value in items:
        if key in result:
            raise ValueError('duplicate JSON key')
        result[key] = value
    return result


def _constant(value):
    raise ValueError('non-finite JSON number')


def _endpoint(row, members):
    _fields(row, ('pid', 'state', 'family', 'local_port', 'remote_port',
                  'protocol', 'local', 'remote'))
    pid = _integer(row['pid'], 1, 2**32 - 1)
    if pid not in members or type(row['family']) is not int or row['family'] not in (2, 23):
        raise ValueError('endpoint must belong to a sampled member/family')
    version = 4 if row['family'] == 2 else 6
    for name in ('local_port', 'remote_port'):
        _integer(row[name], 0, 65535)
    if type(row['local']) is not str or ipaddress.ip_address(row['local']).version != version:
        raise ValueError('local endpoint family mismatch')
    local = ipaddress.ip_address(row['local'])
    if row['protocol'] == 'TCP':
        _integer(row['state'], 1, 12)
        if type(row['remote']) is not str or ipaddress.ip_address(row['remote']).version != version:
            raise ValueError('remote endpoint family mismatch')
        if not local.is_loopback or (row['state'] != 2 and not ipaddress.ip_address(row['remote']).is_loopback):
            raise ValueError('non-loopback TCP sample')
    elif row['protocol'] == 'UDP':
        if type(row['state']) is not int or row['state'] != 0 or row['remote'] is not None or row['remote_port'] != 0:
            raise ValueError('UDP destination must remain unknown')
    else:
        raise ValueError('unknown endpoint protocol')


def validate_samples(raw, receipt, manifest):
    if type(raw) is not bytes or not raw or len(raw) > MAX_BYTES or not raw.endswith(b'\n'):
        raise ValueError('nonempty bounded JSONL bytes required')
    lines = raw.split(b'\n')
    if lines[-1] == b'':
        lines.pop()
    if not 1 <= len(lines) <= MAX_ROWS:
        raise ValueError('sample row bound')
    images = manifest.get('images')
    if type(images) is not list or not images:
        raise ValueError('manifest image policy required')
    allowed = {_canonical(row['path']) for row in images}
    if len(allowed) != len(images):
        raise ValueError('ambiguous image policy')
    root_image = _canonical(manifest['executable'])
    if root_image not in allowed:
        raise ValueError('root not in image policy')
    proof = receipt.get('proof')
    if type(proof) is not dict:
        raise ValueError('supervisor proof required')
    expected_samples = _integer(proof.get('successful_samples'), 1, MAX_ROWS)
    expected_members = _integer(proof.get('bound_members'), 1, len(allowed))
    root_pid = _integer(proof.get('root_pid'), 1, 2**32 - 1)
    root_birth = _integer(proof.get('root_birth'), 1)
    counters = {'disk_scan_retries': 0, 'disk_directory_name_retries': 0,
                'disk_directory_open_retries': 0, 'disk_deleted_directory_ids': 0}
    identities, exited, sampled = {}, {}, set()
    attempts = snapshots = checks = endpoints = udp = verified = 0
    owned = {_canonical(r'C:\BuildWork'), _canonical(r'C:\ProbeOutput')}
    for line in lines:
        if not line.strip() or len(line) > MAX_LINE_BYTES:
            raise ValueError('empty or oversized JSONL row')
        row = json.loads(line.decode('utf-8'), object_pairs_hook=_pairs, parse_constant=_constant)
        if type(row) is not dict:
            raise ValueError('sample row must be an object')
        if 'operation' in row:
            operation = row['operation']
            if operation in ('safety_stop', 'bootstrap_failure'):
                raise ValueError('STOP/bootstrap failure in sample log')
            if operation == 'root_create_attempt':
                _fields(row, ('operation', 'utc')); _utc(row['utc'])
                attempts += 1
                if attempts != 1:
                    raise ValueError('more than one root attempt')
            elif operation == 'process_image_check':
                _fields(row, ('operation', 'pid', 'birth', 'observed_image'))
                if attempts != 1:
                    raise ValueError('image observation before root attempt')
                pid = _integer(row['pid'], 1, 2**32 - 1)
                identity = (_integer(row['birth'], 1), _canonical(row['observed_image']))
                if identity[1] not in allowed or (pid in identities and identities[pid] != identity):
                    raise ValueError('unknown or drifting process identity')
                identities[pid] = identity
                checks += 1
            elif operation == 'input_verified':
                _fields(row, ('operation', 'count'))
                count = _integer(row['count'], 200)
                if count != verified + 200 or count > len(manifest['inputs']) or attempts:
                    raise ValueError('invalid input verification progress')
                verified = count
            elif operation in ('disk_directory_name_retry', 'disk_directory_open_retry'):
                if attempts != 1:
                    raise ValueError('disk sampling before root attempt')
                _fields(row, ('operation', 'file_id', 'error', 'attempt'))
                _integer(row['file_id'], 1, 2**64 - 1)
                _integer(row['attempt'], 1, 2)
                _integer(row['error'], 1, 2**31 - 1)
                if operation == 'disk_directory_open_retry' and row['error'] != 5:
                    raise ValueError('unexpected directory open retry error')
                if operation == 'disk_directory_name_retry' and row['error'] not in (2, 3, 5):
                    raise ValueError('unexpected directory name retry error')
                counters['disk_directory_name_retries' if operation == 'disk_directory_name_retry'
                         else 'disk_directory_open_retries'] += 1
            elif operation == 'disk_directory_id_gone':
                if attempts != 1:
                    raise ValueError('disk sampling before root attempt')
                _fields(row, ('operation', 'root', 'file_id'))
                if _canonical(row['root']) not in owned:
                    raise ValueError('disk observation root escape')
                _integer(row['file_id'], 1, 2**64 - 1)
                counters['disk_deleted_directory_ids'] += 1
            elif operation == 'disk_scan_retry':
                if attempts != 1:
                    raise ValueError('disk sampling before root attempt')
                _fields(row, ('operation', 'root', 'attempt', 'hresult'))
                if _canonical(row['root']) not in owned:
                    raise ValueError('disk observation root escape')
                _integer(row['attempt'], 1, 2)
                _integer(row['hresult'], -(2**31), 2**31 - 1)
                counters['disk_scan_retries'] += 1
            else:
                raise ValueError('unknown operation row')
            continue
        _fields(row, ('utc', 'members', 'endpoints', 'udp_destination', 'sampling_non_atomic'))
        _utc(row['utc'])
        if attempts != 1 or row['udp_destination'] != 'UNKNOWN' or row['sampling_non_atomic'] is not True:
            raise ValueError('sample boundary drift')
        if type(row['members']) is not list or not row['members'] or type(row['endpoints']) is not list:
            raise ValueError('member and endpoint arrays required')
        current = set()
        for member in row['members']:
            _fields(member, ('pid', 'birth', 'image', 'exited'))
            pid = _integer(member['pid'], 1, 2**32 - 1)
            identity = (_integer(member['birth'], 1), _canonical(member['image']))
            if pid in current or identities.get(pid) != identity or type(member['exited']) is not bool:
                raise ValueError('member identity not previously checked or duplicate')
            if exited.get(pid, False) and not member['exited']:
                raise ValueError('exited process became live')
            exited[pid] = member['exited']
            current.add(pid)
        sampled.update(current)
        for endpoint in row['endpoints']:
            _endpoint(endpoint, current)
            endpoints += 1
            udp += endpoint['protocol'] == 'UDP'
        snapshots += 1
    if (attempts != 1 or snapshots != expected_samples or len(sampled) != expected_members
            or set(identities) != sampled or identities.get(root_pid) != (root_birth, root_image)):
        raise ValueError('sample count, member union or root identity mismatch')
    for key, count in counters.items():
        if _integer(proof.get(key)) != count:
            raise ValueError('sample retry counter mismatch: ' + key)
    return {'status': 'NATIVE_ROLE_SAMPLED_LOG_BOUNDARY_SUPPORTED',
            'raw_sha256': hashlib.sha256(raw).hexdigest(), 'rows': len(lines),
            'root_create_attempts': attempts, 'sample_count': snapshots,
            'bound_members': len(sampled), 'process_image_checks': checks,
            'endpoint_rows': endpoints, 'udp_endpoint_rows': udp, 'retry_counts': counters,
            'sampling_non_atomic': True, 'udp_destination': 'UNKNOWN',
            'full_process_or_DLL_closure_proven': False, 'G2': False}
