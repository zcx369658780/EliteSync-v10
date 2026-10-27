"""Pure mock path/fact routing tests: no native links, DLLs, process or socket."""
import unittest
from isolation_contract import *

ROOT = 'T:/owned/task'
PROTECTED = ['S:/history/gradle-home', 'S:/history/flutter', 'S:/sdk', 'S:/pub']
WRITES = {'journal': ROOT+'/home/caches/journal-1', 'scripts': ROOT+'/home/caches/8.14/groovy-dsl',
          'tooling-cache': ROOT+'/flutter/packages/flutter_tools/gradle/.gradle',
          'tooling-build': ROOT+'/flutter/packages/flutter_tools/gradle/build',
          'module-cache': ROOT+'/project/apps/flutter_elitesync_module/.android/.gradle'}
def fact(p, **kw):return FileFact(p, kw.pop('resolved',p), kw.pop('kind','file'), kw.pop('identity','private-1'), **kw)

class Isolation(unittest.TestCase):
    def setUp(self):self.routes=StaticRoutes(ROOT,WRITES,PROTECTED)
    def test_private_journal_route(self):self.assertEqual(self.routes.route_mock_write('journal',fact(WRITES['journal']+'/file-access.bin')),'STATIC_ROUTING_SUPPORTED')
    def test_private_compiler_route(self):self.routes.route_mock_write('scripts',fact(WRITES['scripts']+'/id/init.class'))
    def test_included_cache_is_separate(self):self.routes.route_mock_write('tooling-cache',fact(WRITES['tooling-cache']+'/buildOutputCleanup/cache.properties'))
    def test_included_build_output_is_separate(self):self.routes.route_mock_write('tooling-build',fact(WRITES['tooling-build']+'/classes/Plugin.class'))
    def test_unknown_output_rejected_even_inside_task(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('unknown',fact(ROOT+'/unknown.bin'))
    def test_shared_home_write_rejected(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(PROTECTED[0]+'/caches/journal-1/file-access.bin'))
    def test_shared_sdk_write_rejected(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('tooling-build',fact(PROTECTED[1]+'/packages/flutter_tools/gradle/build/output'))
    def test_wrong_write_family(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(WRITES['tooling-build']+'/file-access.bin'))
    def test_same_name_fake_sdk_rejected(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('tooling-cache',fact(ROOT+'/fake/flutter/packages/flutter_tools/gradle/.gradle/file'))
    def test_symlink_ancestor(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(WRITES['journal']+'/file',redirected_ancestors=('symlink',)))
    def test_junction_ancestor(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(WRITES['journal']+'/file',redirected_ancestors=('junction',)))
    def test_unknown_reparse_tag(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(WRITES['journal']+'/file',redirected_ancestors=('unknown-tag',)))
    def test_resolved_alias(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(WRITES['journal']+'/file',resolved=PROTECTED[0]+'/file'))
    def test_hardlink_count(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(WRITES['journal']+'/file',links=2))
    def test_protected_identity_alias(self):
        with self.assertRaises(Rejected):self.routes.route_mock_write('journal',fact(WRITES['journal']+'/file',identity='protected-id'),['protected-id'])
    def test_missing_file_id(self):
        with self.assertRaises(Rejected):check_fact(fact(ROOT+'/file',identity=''))
    def test_case_alias_overlap(self):
        with self.assertRaises(Rejected):StaticRoutes('s:/HISTORY/gradle-home/new',WRITES,PROTECTED)
    def test_prefix_boundary(self):self.assertFalse(within('T:/owned/task-evil','T:/owned/task'))
    def test_traversal(self):
        with self.assertRaises(Rejected):canonical(ROOT+'/a/../file')
    def test_relative_drive(self):
        with self.assertRaises(Rejected):canonical('T:relative')
    def test_unc(self):
        with self.assertRaises(Rejected):canonical('\\\\host\\share\\file')
    def test_device_namespace(self):
        with self.assertRaises(Rejected):canonical('\\\\?\\T:\\owned')
    def test_ads(self):
        with self.assertRaises(Rejected):canonical(ROOT+'/file:stream')
    def test_trailing_dot(self):
        with self.assertRaises(Rejected):canonical(ROOT+'/dir.')
    def test_environment_alias(self):
        with self.assertRaises(Rejected):canonical('T:/%HOME%/path')
    def test_dos_device(self):
        with self.assertRaises(Rejected):canonical(ROOT+'/NUL.txt')
    def test_control_character(self):
        with self.assertRaises(Rejected):canonical(ROOT+'/new\nfile')
    def test_distinct_volume_write_escape(self):
        with self.assertRaises(Rejected):StaticRoutes(ROOT,{'cache':'U:/owned/task/cache'},PROTECTED)
    def test_task_token_mismatch_rejected(self):
        with self.assertRaises(Rejected):StaticRoutes(ROOT,WRITES,PROTECTED,owner='old-G-task')
    def test_duplicate_write_alias(self):
        with self.assertRaises(Rejected):StaticRoutes(ROOT,{'a':ROOT+'/X','b':ROOT+'/x'},PROTECTED)
    def test_private_home_env(self):self.routes.environment({'GRADLE_USER_HOME':ROOT+'/home'},{'GRADLE_USER_HOME':ROOT+'/home'})
    def test_home_fallback_missing(self):
        with self.assertRaises(Rejected):self.routes.environment({}, {'HOME':ROOT+'/profile'})
    def test_home_conflict(self):
        with self.assertRaises(Rejected):self.routes.environment({'HOME':'S:/profile'}, {'HOME':ROOT+'/profile'})
    def test_injected_java_option(self):
        with self.assertRaises(Rejected):self.routes.environment({'HOME':ROOT+'/profile','JAVA_TOOL_OPTIONS':'x'}, {'HOME':ROOT+'/profile'})
    def test_state_drift_never_immutable(self):self.assertEqual(classify_state('caches/8.14/fileHashes/fileHashes.bin',False),'VARIABLE_RUNTIME_STATE')
    def test_access_journal_mutable(self):self.assertEqual(classify_state('caches/journal-1/file-access.bin',True),'VARIABLE_RUNTIME_STATE')
    def test_build_cleanup_mutable(self):self.assertEqual(classify_state('gradle/.gradle/buildOutputCleanup/cache.properties',True),'VARIABLE_RUNTIME_STATE')
    def test_derived_groovy_not_dependency(self):self.assertEqual(classify_state('caches/8.14/groovy-dsl/id/init.class',True),'DERIVED_GENERATED_STATE_NOT_INHERITED')
    def test_derived_jars_not_dependency(self):self.assertEqual(classify_state('caches/jars-9/id/instrumented.jar',True),'DERIVED_GENERATED_STATE_NOT_INHERITED')
    def test_dependency_pin_required(self):
        with self.assertRaises(Rejected):classify_state('caches/modules-2/files-2.1/x.jar',False)
    def test_dependency_read_candidate(self):self.assertEqual(classify_state('caches/modules-2/files-2.1/x.jar',True),'PINNED_DEPENDENCY_READ_CANDIDATE')
    def test_unknown_cache_state(self):
        with self.assertRaises(Rejected):classify_state('caches/unmapped/file',True)
    def test_small_seed(self):self.assertTrue(seed_within_cap(400000))
    def test_complete_seed_over_cap(self):self.assertFalse(seed_within_cap(1362106905))
    def test_unknown_seed_size(self):
        with self.assertRaises(Rejected):seed_within_cap(None)
    def test_proposed_copied_ro_seed(self):self.assertEqual(readonly_seed_plan(ROOT+'/seed',PROTECTED,list(WRITES.values()),has_modules2=True,dependency_closure=True,readonly_declared=True),'DECLARED_RO_MODEL_ONLY')
    def test_live_old_cache_not_ro_seed(self):
        with self.assertRaises(Rejected):readonly_seed_plan(PROTECTED[0],PROTECTED,[],has_modules2=True,dependency_closure=True,readonly_declared=True)
    def test_ro_seed_writable_overlap(self):
        with self.assertRaises(Rejected):readonly_seed_plan(WRITES['journal'],PROTECTED,list(WRITES.values()),has_modules2=True,dependency_closure=True,readonly_declared=True)
    def test_ro_missing_modules2_is_not_soft_success(self):
        with self.assertRaises(Rejected):readonly_seed_plan(ROOT+'/seed',PROTECTED,[],has_modules2=False,dependency_closure=True,readonly_declared=True)
    def test_ro_unknown_dependency_subset(self):
        with self.assertRaises(Rejected):readonly_seed_plan(ROOT+'/seed',PROTECTED,[],has_modules2=True,dependency_closure=False,readonly_declared=True)
    def test_ro_unknown_enforcement(self):
        with self.assertRaises(Rejected):readonly_seed_plan(ROOT+'/seed',PROTECTED,[],has_modules2=True,dependency_closure=True,readonly_declared=False)
    def test_proposed_command(self):
        cmd=['pinned/gradle.bat','assembleAarRelease','--offline','--dry-run'];self.assertEqual(check_proposal(cmd,cmd,ROOT+'/module',ROOT+'/module'),'PROPOSED_NOT_EXECUTED')
    def test_aar_execution_without_dry_run(self):
        cmd=['pinned/gradle.bat','assembleAarRelease','--offline']
        with self.assertRaises(Rejected):check_proposal(cmd,cmd,ROOT+'/module',ROOT+'/module')
    def test_wrong_cwd(self):
        cmd=['pinned/gradle.bat','assembleAarRelease','--offline','--dry-run']
        with self.assertRaises(Rejected):check_proposal(cmd,cmd,'S:/other',ROOT+'/module')
    def test_even_no_unknown_is_not_runtime_authority(self):self.assertFalse(global_readiness([])['readyForPopen'])
    def test_unknown_critical_surface_keeps_blocked(self):self.assertEqual(global_readiness(['android-sdk-writes'])['status'],'WRITE_ISOLATION_STILL_BLOCKED')

if __name__ == '__main__':unittest.main(verbosity=2)
