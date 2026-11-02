"""Pure candidate policy tests; no runner, SDK, guest, or prior receipt changes."""
import copy
import hashlib
import json
import unittest

import current_product_flutter_cache_policy as policy


class FlutterCachePolicyTests(unittest.TestCase):
    def setUp(self):
        self.metadata = {'frameworkVersion': '3.41.7',
                         'frameworkRevision': 'cc0734ac716fbb8b90f3f9db8020958b1553afa7',
                         'dartSdkVersion': '3.11.5', 'channel': 'stable', 'repositoryUrl': 'https://github.com/flutter/flutter.git'}
        self.raw = json.dumps(self.metadata).encode('utf-8')
        self.observation = {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False,
                            'lock_identity_stable': True, 'legacy_version_file_exists': False}

    def validate(self, raw=None, observation=None):
        raw = self.raw if raw is None else raw
        observation = self.observation if observation is None else observation
        return policy.validate_cache_observation(raw, hashlib.sha256(raw).hexdigest(), observation)

    def test_pinned_source_omission_candidate_keeps_runtime_and_lock_claims_limited(self):
        result = self.validate()
        self.assertEqual(result['metadata_identity']['sha256'], hashlib.sha256(self.raw).hexdigest())
        self.assertEqual(result['metadata_identity']['bytes'], len(self.raw))
        self.assertEqual(result['metadata_identity']['frameworkRevision'], self.metadata['frameworkRevision'])
        self.assertEqual(result['legacy_policy'], 'PINNED_SOURCE_DEFAULT_OMIT')
        self.assertEqual(result['legacy_feature_flag'], 'NOT_DIRECTLY_OBSERVED')
        self.assertEqual(result['lock_held'], 'NOT_DIRECTLY_OBSERVED')
        self.assertEqual(result['future_profile_status'], 'NOT_RUN')
        self.assertIs(result['producer_entry_allowed'], False)
        self.assertIs(result['G2'], False)
        self.assertNotIn('tool_qualified', result)

    def test_raw_sha_and_all_three_version_identities_must_match(self):
        for digest in ['0' * 64, True, '', 'A' * 64]:
            with self.subTest(digest=digest), self.assertRaises(ValueError):
                policy.validate_cache_observation(self.raw, digest, self.observation)
        for key, value in [('frameworkVersion', '3.41.8'), ('frameworkRevision', '0' * 40),
                           ('dartSdkVersion', '3.11.4'), ('frameworkRevision', True)]:
            metadata = {**self.metadata, key: value}
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                self.validate(json.dumps(metadata).encode())
        missing = {k: v for k, v in self.metadata.items() if k != 'frameworkRevision'}
        with self.assertRaises(ValueError): self.validate(json.dumps(missing).encode())

    def test_serialized_metadata_is_bounded_strict_utf8_object_without_ambiguous_keys(self):
        invalid = [b'', b' ' * 32769, b'\xff', b'{', b'[]', b'"metadata"',
                   b'{"frameworkVersion":"3.41.7","frameworkVersion":"3.41.7"}',
                   b'{"other":NaN}', b'{"other":Infinity}']
        for raw in invalid:
            with self.subTest(raw=raw[:80]), self.assertRaises(ValueError): self.validate(raw)
        with self.assertRaises(ValueError):
            policy.validate_cache_observation(bytearray(self.raw), hashlib.sha256(self.raw).hexdigest(), self.observation)

    def test_observation_requires_exact_schema_and_strict_types(self):
        for observation in [[], {}, {**self.observation, 'extra': True},
                            {k: v for k, v in self.observation.items() if k != 'lock_identity_stable'}]:
            with self.subTest(observation=observation), self.assertRaises(ValueError): self.validate(observation=observation)
        for key, value in [('lock_exists', 1), ('lock_bytes', False), ('lock_reparse', 0),
                           ('lock_identity_stable', 1), ('legacy_version_file_exists', 0)]:
            with self.subTest(key=key), self.assertRaises(ValueError): self.validate(observation={**self.observation, key: value})

    def test_bad_lock_or_present_legacy_file_cannot_become_candidate_support(self):
        for key, value in [('lock_exists', False), ('lock_bytes', 1), ('lock_bytes', -1), ('lock_reparse', True),
                           ('lock_identity_stable', False), ('legacy_version_file_exists', True)]:
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                self.validate(observation={**self.observation, key: value})

    def test_validation_does_not_mutate_or_repair_supplied_observation(self):
        original = copy.deepcopy(self.observation)
        result = self.validate()
        self.assertEqual(self.observation, original)
        result['metadata_identity']['frameworkVersion'] = 'changed result'
        self.assertEqual(self.metadata['frameworkVersion'], '3.41.7')
        invalid = {**self.observation, 'legacy_version_file_exists': True}
        before = copy.deepcopy(invalid)
        with self.assertRaises(ValueError): self.validate(observation=invalid)
        self.assertEqual(invalid, before)
        self.assertEqual(self.observation, original)


if __name__ == '__main__': unittest.main()
