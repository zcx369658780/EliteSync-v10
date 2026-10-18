"""Explicit offline replay of the fixed Chiron trajectory; no downloads/services.

Inputs must be the separately acquired and hash-admitted NAIF planetary kernel
and GM file. No Gaia, NIMA, Horizons or Swiss data is used by this builder.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path

import numpy as np

from chiron_dynamics import BuildModel
from orbit_integrator import integrate

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'resources/natal/chiron-data-manifest.json'


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kernel', required=True)
    parser.add_argument('--gm', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    output = Path(args.output)
    if output.exists():
        raise ValueError('output already exists; never overwrite an orbit')
    manifest = json.loads(MANIFEST.read_text(encoding='utf-8'))
    if manifest['rights_status'] != 'ADMITTED_FOR_CLOSED_SOURCE_COMPUTATION_WITH_ATTRIBUTION':
        raise ValueError('source permission not admitted')
    for relative, expected in manifest['build_source_sha256'].items():
        if digest(ROOT / relative) != expected:
            raise ValueError('build source identity mismatch: ' + relative)
    meta = manifest['npz_metadata']
    model = BuildModel(args.kernel, args.gm, ROOT / manifest['element_record'])
    try:
        if float(model.epoch_tdb) != meta['origin_tdb_jd']:
            raise ValueError('initial epoch identity mismatch')
        offsets = np.arange(meta['first_offset_days'], meta['last_offset_days'] + 1, 8., dtype=float)
        if len(offsets) != meta['knot_count']:
            raise ValueError('fixed grid identity mismatch')
        states = np.empty((len(offsets), 6))
        for direction, indices in [('past', np.where(offsets < 0)[0][::-1]),
                                   ('future', np.where(offsets >= 0)[0])]:
            current = 0.; state = model.initial.copy()
            for count, index in enumerate(indices):
                target = float(offsets[index])
                state, _ = integrate(model.rhs, current, state, target, rtol=1e-12,
                    atol=np.array([1e-13]*3 + [1e-15]*3), max_step=4, max_steps=100)
                states[index] = state; current = target
                if count % 1000 == 0:
                    print(json.dumps(dict(phase=direction, completed=count+1, total=len(indices))), flush=True)
        payload = io.BytesIO()
        np.savez_compressed(payload, offset_days=offsets, states=states,
            origin_tdb_jd=np.array(model.epoch_tdb, dtype=float),
            metadata_utf8=np.frombuffer(json.dumps(meta, sort_keys=True).encode('utf-8'), dtype=np.uint8))
        raw = payload.getvalue(); actual = hashlib.sha256(raw).hexdigest()
        if actual != manifest['artifact_sha256']:
            raise ValueError('replay artifact differs from the admitted hash: ' + actual)
        with output.open('xb') as stream:
            stream.write(raw)
        print(json.dumps(dict(status='EXACT_ARTIFACT_REPLAY', sha256=actual, bytes=len(raw))), flush=True)
    finally:
        model.close()


if __name__ == '__main__':
    main()
