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

    def test_artifact_drift_does_not_create_new_entry_authority(self):
        with self.assertRaises(ValueError):binding.bind_entry(b'{}',b'source')
        for key in ('execution_allowed','inherit_environment','old_claims_reused','G2','claim_created'):
            obj=fixture();obj[key]=True
            with self.subTest(key=key),self.assertRaises(ValueError):self.bind(obj)

    def test_action_path_and_environment_negatives_are_independent(self):
        for defect in ('cwd','offline','task','locked','duplicate','size'):
            obj=fixture()
            if defect=='cwd':obj['stage1']['working_directory']='D:/EliteSync-v10'
            elif defect=='offline':obj['stage1']['argv'].remove('--offline')
            elif defect=='task':obj['stage1']['argv'][-1]='help'
            elif defect=='locked':obj['environment']['FLUTTER_ALREADY_LOCKED']='true'
            elif defect=='duplicate':obj['environment']['Path']='x'
            else:obj['environment']['X']='x'*8193
            with self.subTest(defect=defect),self.assertRaises(ValueError):self.bind(obj)

    def test_duplicate_json_is_not_silently_reinterpreted(self):
        raw=b'{"execution_allowed":false,"execution_allowed":true}'
        with patch.object(binding,'ENTRY_SHA256',hashlib.sha256(raw).hexdigest()):
            with self.assertRaises(ValueError):binding.bind_entry(raw,b'source')


if __name__=='__main__':unittest.main()
