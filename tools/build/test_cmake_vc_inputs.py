import copy
import hashlib
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import cmake_vc_inputs as vc


class CMakeVCInputTests(unittest.TestCase):
    def setUp(self):
        self.metadata = [{'name': name, 'signature': 'Valid', 'company': 'Microsoft Corporation',
            'file_version': '14.40.33810.0', 'product_version': '14.40.33810.0',
            'original_filename': name, 'signer': 'CN=Microsoft Windows Software Compatibility Publisher, O=Microsoft Corporation, C=US',
            'thumbprint': 'A' * 40} for name in vc.RUNTIME_NAMES]
        self.parsed = {name: {'machine': '0x8664', 'bits': 64, 'imports': [],
                              'runtime_dependency_closure_proven': False} for name in vc.RUNTIME_NAMES}

    def test_matching_bundle_keeps_runtime_and_release_gates_closed(self):
        result = vc.validate_bundle(self.metadata, self.parsed)
        self.assertEqual(result['version'], '14.40.33810.0')
        self.assertIs(result['runtime_resolution_proven'], False)
        self.assertIs(result['G2'], False)

    def test_missing_duplicate_or_mixed_bundle_rejected(self):
        cases = [self.metadata[:-1], self.metadata + [self.metadata[0]]]
        mixed = copy.deepcopy(self.metadata);mixed[1]['file_version'] = '14.34.1.0';cases.append(mixed)
        for case in cases:
            with self.assertRaises(ValueError):
                vc.validate_bundle(case, self.parsed)

    def test_bad_signature_publisher_version_or_architecture_rejected(self):
        for key, value in [('signature', 'NotSigned'), ('company', 'Other'),
                           ('signer', 'O=Not Microsoft Corporation, C=US'),
                           ('product_version', '14.39.0.0'), ('thumbprint', ''),
                           ('original_filename', 'other.dll')]:
            metadata = copy.deepcopy(self.metadata);metadata[0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                vc.validate_bundle(metadata, self.parsed)
        parsed = copy.deepcopy(self.parsed);parsed[vc.RUNTIME_NAMES[0]]['machine'] = '0x14c'
        with self.assertRaises(ValueError):
            vc.validate_bundle(self.metadata, parsed)

    def test_source_tree_and_DLL_candidates_copy_only_to_fresh_private_root(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory);cmake = root / 'source-cmake';jdk = root / 'source-jdk';task = root / 'task'
            for p in (cmake / 'bin', cmake / 'share', jdk / 'bin', task):p.mkdir(parents=True)
            (cmake / 'bin/cmake.exe').write_bytes(b'original cmake fixture')
            (cmake / 'share/notice.txt').write_bytes(b'keep all source files')
            for name in vc.RUNTIME_NAMES:(jdk / 'bin' / name).write_bytes(name.encode())
            def row(role, parent, relative):
                p=parent/relative;s=p.stat()
                return {'role':role,'path':str(p),'relative_path':relative,'bytes':s.st_size,
                        'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),
                        'file_id':{'device':s.st_dev,'inode':s.st_ino}}
            inventory={'roots':{'android_cmake_3_22_1':str(cmake),'jdk_17_0_18':str(jdk)},'files':
                [row('android_cmake_3_22_1',cmake,r) for r in ('bin/cmake.exe','share/notice.txt')] +
                [row('jdk_17_0_18',jdk,'bin/'+name) for name in vc.RUNTIME_NAMES]}
            bundle={'status':'PRIVATE_RUNTIME_CANDIDATE_ONLY','dlls':[r for r in inventory['files'] if r['role']=='jdk_17_0_18'],
                    'properties':vc.validate_bundle(self.metadata,self.parsed)}
            # Synthetic payloads exercise copying only, never PE loading.
            with patch.object(vc, 'describe_bundle', return_value=bundle):
                receipt=vc.stage_cmake(inventory,str(task/'CMake'),str(task))
                self.assertEqual(receipt['source_cmake_files'],2)
                self.assertEqual(receipt['private_files'],5)
                self.assertEqual((task/'CMake/share/notice.txt').read_bytes(),b'keep all source files')
                self.assertEqual((cmake/'bin/cmake.exe').read_bytes(),b'original cmake fixture')
                self.assertIs(receipt['execution_allowed'],False)
                with self.assertRaises(FileExistsError):
                    vc.stage_cmake(inventory,str(task/'CMake'),str(task))
                with patch.dict(vc.CAPS, {'byte_limit': sum(r['bytes'] for r in inventory['files'] if r['role']=='android_cmake_3_22_1') + 1}):
                    with self.assertRaisesRegex(ValueError,'combined CMake/runtime'):
                        vc.stage_cmake(inventory,str(task/'TooLarge'),str(task))
                self.assertFalse((task/'TooLarge').exists())

    def test_runtime_source_change_after_copy_is_rejected_and_partial_preserved(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);cmake=root/'cmake';jdk=root/'jdk';task=root/'private'
            (cmake/'bin').mkdir(parents=True);(jdk/'bin').mkdir(parents=True);task.mkdir()
            (cmake/'bin/cmake.exe').write_bytes(b'synthetic cmake, never executed')
            for name in vc.RUNTIME_NAMES:(jdk/'bin'/name).write_bytes(name.encode())
            def row(role,parent,relative):
                p=parent/relative;s=p.stat()
                return dict(role=role,path=str(p),relative_path=relative,bytes=s.st_size,
                            sha256=hashlib.sha256(p.read_bytes()).hexdigest(),
                            file_id={'device':s.st_dev,'inode':s.st_ino})
            inventory={'roots':{'android_cmake_3_22_1':str(cmake),'jdk_17_0_18':str(jdk)},
                       'files':[row('android_cmake_3_22_1',cmake,'bin/cmake.exe')]+
                               [row('jdk_17_0_18',jdk,'bin/'+name) for name in vc.RUNTIME_NAMES]}
            bundle={'dlls':inventory['files'][1:],'properties':vc.validate_bundle(self.metadata,self.parsed)}
            real_inventory=vc.inventory_trees
            def inventory_then_mutate(**kwargs):
                result=real_inventory(**kwargs)
                if 'private_cmake' in kwargs['roots']:
                    (jdk/'bin'/vc.RUNTIME_NAMES[0]).write_bytes(b'changed after target copy')
                return result
            with patch.object(vc,'describe_bundle',return_value=bundle), \
                 patch.object(vc,'inventory_trees',side_effect=inventory_then_mutate):
                with self.assertRaisesRegex(ValueError,'VC source changed'):
                    vc.stage_cmake(inventory,str(task/'CMake'),str(task))
            self.assertTrue((task/'CMake/bin/cmake.exe').exists())
            self.assertEqual((task/'CMake/bin'/vc.RUNTIME_NAMES[0]).read_bytes(),vc.RUNTIME_NAMES[0].encode())


if __name__ == '__main__':
    unittest.main()
