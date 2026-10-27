"""Pure path/policy model tests; no Groovy, Gradle, process, socket or DLL."""
from pathlib import Path
import sys,unittest,tempfile,base64,types
from unittest.mock import patch
FORBIDDEN=[]
def deny(event,args):
    if event in {'subprocess.Popen','os.system','ctypes.dlopen'} or event.startswith(('socket.','os.exec','os.spawn','os.startfile')):
        FORBIDDEN.append(event)
        raise AssertionError('REAL_RUNTIME_FORBIDDEN:'+event)
sys.addaudithook(deny)
import owned_aar_init as owned
from test_owned_aar_init import make_owned_fixture,SCRIPTS
class NewContractTests(unittest.TestCase):
    def test_context_api_is_explicit(self):self.assertTrue(callable(owned.authorize_context))
    def test_inventory_contract_rejects_old_schema(self):self.assertEqual(owned.inventory_contract()['schema'],2)
    def test_guard_has_trusted_tooling_early_return(self):
        self.assertIn(b'OWNED_CONTEXT_TOOLING',owned.PREAMBLE)
        self.assertIn(b'elitesyncOwnedAarProjectRoot',owned.PREAMBLE)
    def test_guard_binds_actual_script_and_parent_not_names(self):
        for literal in [b'initscript.sourceFile',b'rootContext.parent == null',b'currentInit == rootInit',
                        b'== toolingContext',b'== moduleContext',b'childProperties.containsKey',b'pinnedOwnedFile(toolingContext']:
            self.assertIn(literal,owned.PREAMBLE)
    def test_model_defines_match_groovy_literal(self):
        d=','.join(base64.b64encode(x.encode()).decode() for x in ['ELITESYNC_V1015_LOCAL_BUILD=true','ELITESYNC_V1015_R1_LOCAL_BUILD=true'])
        self.assertIn(("def ownedDefines = '"+d+"'").encode(),owned.PREAMBLE)
    def test_consumers_pin_guard_and_pass_project_root(self):
        text=(SCRIPTS.parent/'app/build.gradle.kts').read_text(encoding='utf-8')
        self.assertIn(owned.CONTEXT_GUARD_SHA256,text)
        self.assertIn('-PelitesyncOwnedAarProjectRoot=${rootProject.projectDir.parentFile.parentFile.absolutePath}',text)
        self.assertIn('context_guard.gradle',text)

class ContextMatrix(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        top=Path(self.temp.name).resolve();self.project=top/'project';self.flutter=top/'flutter'
        self.project.mkdir();self.flutter.mkdir();make_owned_fixture(self.project,self.flutter)
        self.module=self.project/'apps/flutter_elitesync_module/.android';self.module.mkdir(parents=True)
        self.tooling=self.flutter/'packages/flutter_tools/gradle'
        offline=self.project/'apps/android/scripts/offline_debug.init.gradle';offline.write_bytes(b'fixture offline init')
        init=self.project/owned.DIRECTORY/'aar_runtime.init.gradle'
        defines=','.join(base64.b64encode(x.encode()).decode() for x in ['ELITESYNC_V1015_LOCAL_BUILD=true','ELITESYNC_V1015_R1_LOCAL_BUILD=true'])
        props={'elitesyncOwnedAarInit':owned.SCOPE,'elitesyncOwnedAarProjectRoot':str(self.project),
               'flutter-root':str(self.flutter),'target':'lib/main.dart','is-plugin':'false',
               'dart-defines':defines,'target-platform':'android-x64,android-arm64','buildNumber':'1.0-v1015r1-123456abcdef'}
        self.root={'parent':None,'properties':props,'current_dir':self.module,'script':init,'init_scripts':[init,offline],'version':'8.14','offline':True,'tasks':['assembleAarRelease']}
        self.child={'parent':self.root,'properties':{},'current_dir':self.tooling,'script':init,'init_scripts':[init,offline],'version':'8.14','offline':True}
    def test_root_explicit_scope_accepts(self):self.assertEqual(owned.authorize_context(self.root),'OWNED_CONTEXT_ROOT')
    def test_exact_direct_tooling_child_accepts_without_own_P(self):self.assertEqual(owned.authorize_context(self.child),'OWNED_CONTEXT_TOOLING')
    def test_child_matching_scope_is_not_a_root_bypass(self):
        self.child['properties']['elitesyncOwnedAarInit']=owned.SCOPE
        self.assertEqual(owned.authorize_context(self.child),'OWNED_CONTEXT_TOOLING')
        self.root['properties'].pop('elitesyncOwnedAarInit')
        with self.assertRaises(owned.OwnedInitError):owned.authorize_context(self.child)
    def test_root_missing_or_wrong_scope_rejects(self):
        for scope in [None,'','ice','retention']:
            self.root['properties']['elitesyncOwnedAarInit']=scope
            with self.subTest(scope=scope),self.assertRaises(owned.OwnedInitError):owned.authorize_context(self.root)
    def test_other_root_tasks_reject(self):
        for tasks in [[],['tasks'],['assembleAarRelease','other'],['assembleAarDebug']]:
            self.root['tasks']=tasks
            with self.subTest(tasks=tasks),self.assertRaisesRegex(owned.OwnedInitError,'ROOT_TASK_CONTRACT'):owned.authorize_context(self.root)
    def test_standalone_sdk_named_gradle_is_rejected(self):
        self.root['current_dir']=self.tooling
        with self.assertRaisesRegex(owned.OwnedInitError,'ROOT_MODULE_IDENTITY'):owned.authorize_context(self.root)
    def test_unknown_included_same_name_rejects(self):
        other=self.tooling.parent/'fake/gradle';other.mkdir(parents=True);self.child['current_dir']=other
        with self.assertRaisesRegex(owned.OwnedInitError,'UNKNOWN_INCLUDED_CONTEXT'):owned.authorize_context(self.child)
    def test_nested_buildsrc_rejects(self):
        self.child['parent']=dict(self.root,parent=self.root)
        with self.assertRaisesRegex(owned.OwnedInitError,'UNKNOWN_NESTED_CONTEXT'):owned.authorize_context(self.child)
    def test_child_conflicting_scope_or_target_rejects(self):
        for key,value in [('elitesyncOwnedAarInit','retention'),('target','lib/dev/v1015_ice_diag.dart'),('flutter-root','elsewhere')]:
            self.child['properties']={key:value}
            with self.subTest(key=key),self.assertRaisesRegex(owned.OwnedInitError,'CONFLICTING_INCLUDED_INPUT'):owned.authorize_context(self.child)
    def test_wrong_root_project_path_rejects(self):
        self.root['properties']['elitesyncOwnedAarProjectRoot']=str(self.project/'fake')
        with self.assertRaises(owned.OwnedInitError):owned.authorize_context(self.root)
    def test_reordered_or_extra_init_rejects(self):
        self.child['init_scripts']=list(reversed(self.root['init_scripts']))
        with self.assertRaisesRegex(owned.OwnedInitError,'INIT_IDENTITY_OR_ORDER'):owned.authorize_context(self.child)
    def test_executing_script_spoof_rejects(self):
        self.child['script']=self.root['init_scripts'][1]
        with self.assertRaisesRegex(owned.OwnedInitError,'INIT_IDENTITY_OR_ORDER'):owned.authorize_context(self.child)
    def test_retention_ice_or_nonr1_inputs_reject(self):
        for key,value in [('target','lib/dev/v1015_r1_retention_probe.dart'),('dart-defines','ELITESYNC_ICE_DIAG_TEST_ONLY=true'),('buildNumber','1.0-r1probe-123456abcdef'),('is-plugin','true')]:
            original=self.root['properties'][key];self.root['properties'][key]=value
            with self.subTest(key=key),self.assertRaisesRegex(owned.OwnedInitError,'ORDINARY_RUNTIME_REQUIRED'):owned.authorize_context(self.root)
            self.root['properties'][key]=original
    def test_online_or_other_gradle_rejects(self):
        for key,value in [('version','8.13'),('offline',False)]:
            original=self.child[key];self.child[key]=value
            with self.subTest(key=key),self.assertRaisesRegex(owned.OwnedInitError,'OFFLINE_GRADLE_CONTEXT'):owned.authorize_context(self.child)
            self.child[key]=original
    def test_untrusted_tooling_source_rejects(self):
        (self.tooling/'build.gradle.kts').write_bytes(b'fake same-name plugin')
        with self.assertRaisesRegex(owned.OwnedInitError,'TOOLING_SOURCE_HASH'):owned.authorize_context(self.child)
    def test_missing_license_patch_and_source_reject(self):
        for name in ['FLUTTER_LICENSE','UPSTREAM.patch','SOURCE.json']:
            p=self.project/owned.DIRECTORY/name;raw=p.read_bytes();p.unlink()
            with self.subTest(name=name),self.assertRaises(owned.OwnedInitError):owned.authorize_context(self.child)
            p.write_bytes(raw)
    def test_symlink_and_reparse_reject_without_creating_them(self):
        with patch.object(Path,'is_symlink',return_value=True):
            with self.assertRaisesRegex(owned.OwnedInitError,'CONTEXT_REDIRECTED_PATH'):owned.authorize_context(self.child)
        original=Path.lstat
        def fake(p):
            value=original(p)
            if p==self.project:return types.SimpleNamespace(st_file_attributes=1024)
            return value
        with patch.object(Path,'is_symlink',return_value=False),patch.object(Path,'lstat',fake):
            with self.assertRaisesRegex(owned.OwnedInitError,'CONTEXT_REDIRECTED_PATH'):owned.authorize_context(self.child)
def tearDownModule():
    if FORBIDDEN:raise AssertionError('FORBIDDEN_RUNTIME_ATTEMPTS:'+repr(FORBIDDEN))
    print('ISOLATION: real process/socket/native-DLL audit events = 0; policy model only')
if __name__=='__main__':unittest.main()
