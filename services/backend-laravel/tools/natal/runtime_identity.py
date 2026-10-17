"""Offline runtime fingerprint. No birth input, network, or kernel loading."""
import hashlib
import importlib.metadata
import importlib
import json
import pathlib
import platform
import sys


PACKAGES = ('skyfield', 'jplephem', 'numpy', 'sgp4', 'certifi', 'pyerfa')
ADMITTED_VERSIONS = {'skyfield': '1.55', 'jplephem': '2.24', 'numpy': '2.4.6',
                     'sgp4': '2.27', 'certifi': '2026.7.22', 'pyerfa': '2.0.1.5'}


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, 'rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def fingerprint(kernel, expected):
    import erfa
    from skyfield.api import load

    packages = {}
    for name in PACKAGES:
        distribution = importlib.metadata.distribution(name)
        record = distribution.read_text('RECORD')
        if record is None:
            raise RuntimeError('package_record_missing')
        packages[name] = {
            'version': distribution.version,
            'record_sha256': hashlib.sha256(record.encode('utf-8')).hexdigest(),
            'metadata_sha256': hashlib.sha256(distribution.read_text('METADATA').encode('utf-8')).hexdigest(),
        }
    modules = ('skyfield.timelib', 'skyfield.curvelib', 'erfa.core', 'erfa.ufunc',
               'jplephem.spk', 'numpy')
    implementation = {name: sha256_file(importlib.import_module(name).__file__)
                      for name in modules}
    skyfield_data = pathlib.Path(importlib.import_module('skyfield').__file__).parent / 'data'
    bundled_tables = {name: sha256_file(skyfield_data / name)
                      for name in ('delta_t.npz', 'iers.npz')}
    timescale = load.timescale(builtin=True)
    model = timescale.delta_t_function
    digest = hashlib.sha256()
    for array in (model.table_tt, model.table_delta_t):
        digest.update(array.astype('<f8').tobytes())
    leaps = erfa.leap_seconds.get()
    leap_payload = [[int(row['year']), int(row['month']), float(row['tai_utc'])]
                    for row in leaps]
    leap_hash = hashlib.sha256(json.dumps(leap_payload, separators=(',', ':')).encode()).hexdigest()
    actual = sha256_file(kernel)
    versions_match = all(packages[name]['version'] == version
                         for name, version in ADMITTED_VERSIONS.items())
    available = actual == expected and versions_match
    return {
        'schema': 'natal-runtime-identity-v1',
        'status': 'AVAILABLE' if available else 'IDENTITY_UNAVAILABLE',
        'reason': (None if available else
                   'kernel_hash_mismatch' if actual != expected else 'dependency_version_not_admitted'),
        'python_version': platform.python_version(),
        'python_executable_sha256': sha256_file(sys.executable),
        'packages': packages,
        'implementation_sha256': implementation,
        'time_tables': {
            'bundled_table_sha256': bundled_tables,
            'skyfield_delta_t_sha256': digest.hexdigest(),
            'skyfield_leap_dates_sha256': hashlib.sha256(timescale.leap_dates.astype('<f8').tobytes()).hexdigest(),
            'skyfield_leap_offsets_sha256': hashlib.sha256(timescale.leap_offsets.astype('<f8').tobytes()).hexdigest(),
            'erfa_active_leap_sha256': leap_hash,
            'erfa_version': erfa.version.erfa_version,
            'sofa_version': erfa.version.sofa_version,
        },
        'kernel': {'actual_sha256': actual, 'admitted_sha256': expected},
    }


if __name__ == '__main__':
    try:
        if len(sys.argv) != 3 or len(sys.argv[2]) != 64:
            raise ValueError('invalid_identity_arguments')
        result = fingerprint(pathlib.Path(sys.argv[1]), sys.argv[2])
    except Exception:
        # Do not leak paths, interpreter diagnostics, or private deployment details.
        result = {'schema': 'natal-runtime-identity-v1', 'status': 'IDENTITY_UNAVAILABLE',
                  'reason': 'offline_runtime_probe_failed'}
    print(json.dumps(result, sort_keys=True, separators=(',', ':')))
