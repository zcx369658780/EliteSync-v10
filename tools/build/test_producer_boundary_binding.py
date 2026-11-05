import hashlib
import json
import unittest
from unittest.mock import patch

import producer_boundary_binding as binding


def fixture():
    return dict(status='FULL_ROOT_PRODUCER_SOURCE_WIRED_NOT_EXECUTABLE',execution_allowed=False,
        claim_created=False,G2=False,inherit_environment=False,old_claims_reused=False,
        producer_budget='UNKNOWN_NOT_CREATED',source_identity={'source_commit':'fixture'},
        publication_version='fixture',stage1={'argv':['C:/Inputs/Jdk/bin/java.exe',
        '-Dexample=path with spaces','--offline','--max-workers=1','assembleAarRelease'],
        'working_directory':'C:/BuildWork/Project/apps/flutter_elitesync_module/.android'},
        environment={'PATH':'C:/Inputs/Jdk/bin'})


class BindingTests(unittest.TestCase):
    def bind(self, obj):
        raw=json.dumps(obj).encode()
        with patch.object(binding,'ENTRY_SHA256',hashlib.sha256(raw).hexdigest()):
            return binding.bind_entry(raw,b'boundary source fixture')

    def test_bound_command_quoting_keeps_environment_and_authority_closed(self):
        obj=fixture();result=self.bind(obj)
        self.assertIn('"-Dexample=path with spaces"',result['launch_request']['command_line'])
        self.assertEqual(result['launch_request']['environment'],obj['environment'])
        self.assertIsNone(result['nonce']);self.assertIsNone(result['authorization'])
        self.assertFalse(result['runtime_authorized']);self.assertFalse(result['runtime_qualified'])

    def test_any_artifact_drift_is_rejected_at_the_single_input_boundary(self):
        raw=json.dumps(fixture()).encode()
        with patch.object(binding,'ENTRY_SHA256',hashlib.sha256(raw).hexdigest()):
            for changed in (raw+b' ',raw.replace(b'assembleAarRelease',b'help')):
                with self.assertRaises(ValueError):binding.bind_entry(changed,b'source')

    def test_output_routing_is_added_without_changing_the_pinned_entry(self):
        obj=fixture();original=json.dumps(obj)
        result=self.bind(obj)
        self.assertEqual(json.dumps(obj),original)
        self.assertIn('producer-output.init.gradle',result['launch_request']['command_line'])
        self.assertEqual(result['launch_request']['cwd'],r'C:\BuildWork\Project\apps\flutter_elitesync_module\.android')


if __name__=='__main__':unittest.main()
