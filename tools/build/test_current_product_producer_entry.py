"""Producer source-wiring fixtures; no Gradle, SDK, VM or build execution."""
import base64
import hashlib
import json
import unittest
from unittest.mock import patch

import current_product_producer_entry as entry


HELPER = b'object Fixture {\n            executable(baseFlutterTask.flutterExecutable!!.absolutePath)\n            workingDir(baseFlutterTask.sourceDir)\n            args("assemble")\n}\n'
AAR = b'configure {\n                    withSourcesJar()\n                    withJavadocJar()\n}\nother {\n                    withJavadocJar()\n}\n'


def manifest(role, paths):
    return json.dumps({'scope':'COMPLETE_DECLARED_TREES_ONLY','roots':{role:'fixture'},
        'files':[{'relative_path':p,'sha256':hashlib.sha256(data).hexdigest(),
                  'bytes':len(data),'role':role} for p,data in paths.items()]}).encode()


class ProducerEntryTests(unittest.TestCase):
    def fixtures(self):
        flutter=manifest('private_flutter',{entry.HELPER_PATH:HELPER,
            entry.AAR_PATH:AAR,**{p:b'fixture' for p in entry.REQUIRED_FLUTTER}})
        project=manifest('private_project',{p:b'fixture' for p in entry.REQUIRED_PROJECT})
        pins={'flutter':hashlib.sha256(flutter).hexdigest(),
            'project':hashlib.sha256(project).hexdigest(),'helper':hashlib.sha256(HELPER).hexdigest(),
            'aar':hashlib.sha256(AAR).hexdigest()}
        return [flutter,project,HELPER,AAR],pins

    def prepare(self):
        args,pins=self.fixtures()
        with patch.dict(entry.PINS,pins):
            return entry.prepare_entry(*args)

    def test_full_root_direct_dart_prefix_preserves_assemble_and_normal_lock(self):
        result=self.prepare();text=result['overlays'][entry.HELPER_PATH]
        self.assertNotIn('executable(baseFlutterTask.flutterExecutable',text)
        self.assertIn('executable(dart.absolutePath)',text)
        self.assertLess(text.index('args("--packages='),text.index('args("assemble")'))
        self.assertLess(text.index('args(snapshot.absolutePath)'),text.index('args("assemble")'))
        self.assertIn('C:/BuildWork/Flutter',text)
        self.assertIn('System.getenv("FLUTTER_ALREADY_LOCKED") == null',text)
        self.assertNotIn('setEnvironment',text)
        self.assertIn('buildMode == "release"',text)
        self.assertIn('workingDir(baseFlutterTask.sourceDir)',text)

    def test_producer_version_flags_and_expected_repository_are_consistent(self):
        result=self.prepare();command=result['stage1']['argv'];version=result['publication_version']
        self.assertEqual(command[-1],'assembleAarRelease')
        self.assertIn('-PbuildNumber='+version,command)
        self.assertIn('--offline',command)
        self.assertIn('--max-workers=1',command)
        self.assertNotIn('--dry-run',command)
        self.assertTrue(version.endswith(entry.PINS['selected'][:12]))
        self.assertEqual(result['handoff']['expected_coordinate'],
            'com.elitesync.flutter_elitesync_module:flutter_release:'+version)
        self.assertEqual(result['handoff']['producer_repository'],'C:/BuildWork/AarOutput/outputs/repo')
        encoded=next(s for s in command if s.startswith('-Pdart-defines=')).split('=',1)[1]
        self.assertEqual([base64.b64decode(s).decode() for s in encoded.split(',')],
            ['ELITESYNC_V1015_LOCAL_BUILD=true','ELITESYNC_V1014_LOCAL_BUILD=true'])
        self.assertFalse(result['execution_allowed'])
        self.assertFalse(result['claim_created'])
        self.assertFalse(result['G2'])

    def test_environment_uses_private_full_root_and_readonly_dependencies(self):
        result=self.prepare();env=result['environment']
        self.assertEqual(env['FLUTTER_ROOT'],'C:/BuildWork/Flutter')
        self.assertEqual(env['GRADLE_RO_DEP_CACHE'],'C:/Inputs/DependencyCache')
        self.assertEqual(env['PATHEXT'],'.EXE')
        self.assertNotIn('FLUTTER_ALREADY_LOCKED',env)
        self.assertEqual(env['GRADLE_USER_HOME'],'C:/BuildWork/GradleHome')
        self.assertIn('kotlin.compiler.execution.strategy=in-process',result['gradle_properties'])

    def test_aar_adapter_preserves_sources_and_removes_only_javadoc_declarations(self):
        text=self.prepare()['overlays'][entry.AAR_PATH]
        self.assertNotIn('withJavadocJar()',text)
        self.assertEqual(text,AAR.decode().replace('                    withJavadocJar()\n',''))
        self.assertIn('withSourcesJar()',text)

    def test_source_or_manifest_drift_and_ten_control_root_are_rejected(self):
        args,pins=self.fixtures()
        for index,name in enumerate(('flutter','project','helper','aar')):
            changed=list(args);changed[index]+=b' '
            with patch.dict(entry.PINS,pins),self.subTest(name=name),self.assertRaises(ValueError):
                entry.prepare_entry(*changed)
        tiny=manifest('private_flutter',{'bin/cache/flutter_tools.snapshot':b'fixture'})
        with patch.dict(entry.PINS,{'flutter':hashlib.sha256(tiny).hexdigest()}):
            with self.assertRaises(ValueError):entry.prepare_entry(tiny,b'{}',HELPER,AAR)

    def test_missing_required_inventory_member_or_changed_helper_row_is_rejected(self):
        args,pins=self.fixtures()
        for defect in ('missing','helper'):
            files={entry.HELPER_PATH:HELPER,entry.AAR_PATH:AAR,
                   **{p:b'fixture' for p in entry.REQUIRED_FLUTTER}}
            if defect=='missing':files.pop(entry.REQUIRED_FLUTTER[0])
            else:files[entry.HELPER_PATH]=b'wrong'
            flutter=manifest('private_flutter',files)
            with patch.dict(entry.PINS,{**pins,'flutter':hashlib.sha256(flutter).hexdigest()}):
                with self.subTest(defect=defect),self.assertRaises(ValueError):
                    entry.prepare_entry(flutter,args[1],HELPER,AAR)

    def test_changed_project_members_and_duplicate_inventory_paths_are_rejected(self):
        args,pins=self.fixtures()
        for defect in ('missing','duplicate','role'):
            data=json.loads(args[1]);rows=data['files']
            if defect=='missing':rows.pop()
            elif defect=='duplicate':rows.append(rows[0])
            else:rows[0]['role']='other'
            raw=json.dumps(data).encode()
            with patch.dict(entry.PINS,{**pins,'project':hashlib.sha256(raw).hexdigest()}):
                with self.subTest(defect=defect),self.assertRaises(ValueError):
                    entry.prepare_entry(args[0],raw,args[2],args[3])

    def test_ambiguous_anchors_and_incorrect_publication_source_fail_closed(self):
        args,pins=self.fixtures()
        for helper,aar in ((HELPER+HELPER,AAR),(HELPER,AAR.replace(b'withJavadocJar()',b'other()',1))):
            flutter=manifest('private_flutter',{entry.HELPER_PATH:helper,entry.AAR_PATH:aar,
                **{p:b'fixture' for p in entry.REQUIRED_FLUTTER}})
            overrides={**pins,'flutter':hashlib.sha256(flutter).hexdigest(),
                'helper':hashlib.sha256(helper).hexdigest(),'aar':hashlib.sha256(aar).hexdigest()}
            with patch.dict(entry.PINS,overrides),self.assertRaises(ValueError):
                entry.prepare_entry(flutter,args[1],helper,aar)


if __name__=='__main__':
    unittest.main()
