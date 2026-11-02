"""Pure cache-observation policy candidate for a future independent profile.

Flutter 3.41.7's pinned source defaults to omitting the legacy version file.
This policy does not observe the effective feature flag or directly prove lock
ownership. It is not wired into an executor and cannot reclassify a consumed
scope or replace its original rejected receipt. Future runtime remains NOT_RUN.
"""
import hashlib
import json
import re


FRAMEWORK_VERSION = '3.41.7'
FRAMEWORK_REVISION = 'cc0734ac716fbb8b90f3f9db8020958b1553afa7'
DART_VERSION = '3.11.5'
METADATA_LIMIT = 32768
OBSERVATION = {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False,
               'lock_identity_stable': True, 'legacy_version_file_exists': False}


def _unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Duplicate metadata JSON key')
        result[key] = value
    return result


def _reject_constant(value):
    raise ValueError('Non-finite metadata JSON constant: ' + value)


def validate_cache_observation(version_metadata: bytes, expected_sha256: str,
                               observation: dict) -> dict:
    """Validate only pinned metadata plus the declared observation schema.

    Official metadata may contain additional fields. Observation fields are
    exact; bool is never accepted in place of an integer byte count.
    """
    if type(version_metadata) is not bytes or not 1 <= len(version_metadata) <= METADATA_LIMIT:
        raise ValueError('Version metadata must be 1..32768 raw bytes')
    if type(expected_sha256) is not str or not re.fullmatch('[0-9a-f]{64}', expected_sha256):
        raise ValueError('Expected metadata SHA-256 must be lowercase hexadecimal')
    digest = hashlib.sha256(version_metadata).hexdigest()
    if digest != expected_sha256:
        raise ValueError('Pinned raw metadata SHA-256 mismatch')
    try:
        metadata = json.loads(version_metadata.decode('utf-8', errors='strict'),
                              object_pairs_hook=_unique_object, parse_constant=_reject_constant)
    except (UnicodeError, json.JSONDecodeError) as error:
        raise ValueError('Strict UTF-8 JSON metadata required') from error
    identity = {'frameworkVersion': FRAMEWORK_VERSION, 'frameworkRevision': FRAMEWORK_REVISION,
                'dartSdkVersion': DART_VERSION}
    if type(metadata) is not dict or any(type(metadata.get(k)) is not str or metadata[k] != v
                                         for k, v in identity.items()):
        raise ValueError('Pinned Flutter/Dart metadata identity mismatch')
    if (type(observation) is not dict or set(observation) != set(OBSERVATION)
            or any(type(observation[k]) is not type(v) or observation[k] != v
                   for k, v in OBSERVATION.items())):
        raise ValueError('Exact stable fresh-lock and omitted-legacy observation required')
    return {'metadata_identity': {'sha256': digest, 'bytes': len(version_metadata), **identity},
            'legacy_policy': 'PINNED_SOURCE_DEFAULT_OMIT',
            'legacy_feature_flag': 'NOT_DIRECTLY_OBSERVED', 'lock_held': 'NOT_DIRECTLY_OBSERVED',
            'future_profile_status': 'NOT_RUN', 'producer_entry_allowed': False, 'G2': False}
