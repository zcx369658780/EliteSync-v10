import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET
import current_product_config_diagnostic as d

class DiagnosticTests(unittest.TestCase):
    def test_all_three_tooling_references_are_separated(self):
        root=d.HERE.parent.parent/'apps/flutter_elitesync_module/.android'
        for name,count in [('settings.gradle',1),('include_flutter.groovy',2)]:
            original=(root/name).read_text(encoding='utf-8');new=d.adapt_text('/'+name,original)
            self.assertEqual(new.count('C:/BuildWork/Tooling/packages/flutter_tools/gradle'),count)
            self.assertNotIn('$flutterSdkPath/packages/flutter_tools/gradle',new)
            self.assertEqual((root/name).read_text(encoding='utf-8'),original)
    def test_unexpected_reference_or_adapter_is_rejected(self):
        for name,text in [('/settings.gradle','other'),('/include_flutter.groovy','$flutterSdkPath/packages/flutter_tools/gradle'),('/other.gradle','')]:
            with self.assertRaises(ValueError):d.adapt_text(name,text)
    def test_properties_are_lines_and_disable_jdk_fetch(self):
        text=d.adapt_text('/gradle.properties','legacy')
        self.assertIn('org.gradle.java.installations.auto-download=false',text.splitlines())
        self.assertIn('kotlin.compiler.execution.strategy=in-process',text.splitlines())
        self.assertNotIn('8G',text)
    def test_exact_cli_avoids_shell_wrapper_actual_builds(self):
        args=d.command('gradle');self.assertEqual(args[0],d.JAVA)
        self.assertIn('-jar',args);self.assertTrue(args[args.index('-jar')+1].endswith('gradle-gradle-cli-main-8.14.jar'))
        self.assertEqual(args[-2:],['--dry-run','assembleAarRelease'])
        self.assertIn('--offline',args);self.assertIn('--no-daemon',args)
        self.assertEqual(args.count('-I'),2)
        self.assertFalse(any(s in ['cmd','flutter','gradlew','publish',':app:assembleDebug'] for s in args))
        with self.assertRaises(ValueError):d.command('apk')
    def test_gradle_request_and_launcher_managed_jvm_options_match(self):
        args=d.command('gradle');prefix=args[:args.index('-jar')]
        properties=d.adapt_text('/gradle.properties','legacy').splitlines()
        requested=next(line.split('=',1)[1] for line in properties if line.startswith('org.gradle.jvmargs='))
        self.assertEqual(requested.split(),d.jvm_options())
        managed=[arg for arg in prefix[1:] if not arg.startswith('-Duser.home=') and not arg.startswith('-javaagent:')]
        self.assertEqual(managed,requested.split())
        self.assertEqual([arg for arg in prefix if arg.startswith('-javaagent:')],[r'-javaagent:C:\Inputs\Gradle\lib\agents\gradle-instrumentation-agent-8.14.jar'])
        self.assertFalse(any('instrumentation.agent=false' in arg for arg in args))
    def test_child_environment_has_no_inherited_injection(self):
        with patch.dict(d.os.environ,{'JAVA_TOOL_OPTIONS':'bad','JDK_JAVA_OPTIONS':'bad','PATH':'untrusted'},clear=True):
            env=d.environment()
        self.assertNotIn('JAVA_TOOL_OPTIONS',env);self.assertNotIn('JDK_JAVA_OPTIONS',env)
        self.assertNotIn('untrusted',env['PATH']);self.assertEqual(env['GRADLE_RO_DEP_CACHE'],r'C:\Inputs\DependencyCache')
    def result(self,mode='gradle'):
        m={'nonce':'a'*32,'binary_sha256':'b'*64,'mode':mode,'inputs':[1]}
        r={'schema':1,'nonce':m['nonce'],'binary_sha256':m['binary_sha256'],'mode':mode,'input_files':1,'failure':None,'G2':False,'apk_builds':0,'gradle_root_attempts':1 if mode=='gradle' else 0,'proof':{'job_final_empty':True,'all_bound_handles_exited':True,'watchdog_stop':0,'root_exit':1,'stop_reason':None,'bound_members':2,'successful_samples':8}}
        if mode=='qualify':r['proof']['stop_reason']='SafetyStop: NON_LOOPBACK_TCP'
        return r,m
    def test_normal_failure_is_valid_evidence_not_success(self):
        r,m=self.result();p=d.validate_result(r,m)
        self.assertEqual(d.classify(p,'failure',[],[]),'CONFIGURATION_FAILED')
    def test_unknown_fake_counts_and_missing_inputs_rejected(self):
        for key,value in [('schema',True),('gradle_root_attempts',True),('apk_builds',False),('input_files',0),('nonce','wrong')]:
            r,m=self.result();r[key]=value
            with self.assertRaises(ValueError):d.validate_result(r,m)
        for key,value in [('root_exit',False),('watchdog_stop',False),('job_final_empty',1),('all_bound_handles_exited',None)]:
            r,m=self.result();r['proof'][key]=value
            with self.assertRaises(ValueError):d.validate_result(r,m)
    def test_qualification_requires_observed_negative_and_descendant(self):
        r,m=self.result('qualify');d.validate_result(r,m)
        for key,value in [('bound_members',1),('successful_samples',True),('stop_reason',None),('watchdog_stop',2)]:
            changed=copy.deepcopy(r);changed['proof'][key]=value
            with self.assertRaises(ValueError):d.validate_result(changed,m)
    def test_success_line_cannot_replace_graph_and_route_evidence(self):
        p={'stop_reason':None,'root_exit':0}
        self.assertEqual(d.classify(p,'BUILD SUCCESSFUL',[],[]),'CONFIG_GRAPH_NOT_PROVEN')
        graph=':flutter:assembleAarRelease SKIPPED\n:jni:assembleAarRelease SKIPPED\n'
        self.assertEqual(d.classify(p,graph,['jni'],[]),'CONFIG_GRAPH_ROUTING_NOT_PROVEN')
        routing=[{'event':'jni_cmake_finalized','path':str(d.WORK/'state/cmake/jni')}]+[{'event':'project_output','project':key,'path':value} for key,value in d.expected_outputs(['jni']).items()]
        self.assertEqual(d.classify(p,graph,['jni'],routing),'CONFIG_GRAPH_BOUNDED_SUPPORTED')
        self.assertEqual(d.classify(p,graph+':jni:releaseJavadoc SKIPPED\n',['jni'],routing),'CONFIG_GRAPH_SELECTS_DOCUMENTATION_TASK')
        routing[-1]['path']=r'C:\Inputs\Pub\jni\build'
        self.assertEqual(d.classify(p,graph,['jni'],routing),'CONFIG_GRAPH_ROUTING_NOT_PROVEN')
    def test_safety_failure_overrides_offline_error(self):
        self.assertEqual(d.classify({'stop_reason':'UNKNOWN_PROCESS_IMAGE'},'No cached version',[],[]),'CONFIG_DIAGNOSTIC_SAFETY_STOP')
        self.assertEqual(d.classify({'stop_reason':None,'root_exit':1},'No cached version',[],[]),'OFFLINE_INPUT_MISSING')
    def test_permanent_ledger_files_cannot_overwrite_or_skip(self):
        with tempfile.TemporaryDirectory() as name,patch.object(d,'TASK_ROOT',Path(name)):
            self.assertEqual(d.ledger()['reservations'],[])
            new=d.next_reservation(d.ledger(),manifest_sha256='a'*64,command_sha256='b'*64)
            d.put(Path(name)/'reservation-1.json',new)
            self.assertEqual(len(d.ledger()['reservations']),1)
            with self.assertRaises(FileExistsError):d.put(Path(name)/'reservation-1.json',new)
            d.put(Path(name)/'reservation-3.json',new)
            with self.assertRaises(ValueError):d.ledger()
    def test_unknown_or_unbound_prior_outcome_cannot_free_next_reservation(self):
        reservation={'manifest_sha256':'a'*64}
        good={'mode':'gradle','status':'CONFIGURATION_FAILED','manifest_sha256':'a'*64,'receipt_sha256':'b'*64,'G2':False,'apk_builds':0,'proof':{'job_final_empty':True,'all_bound_handles_exited':True}}
        d.validate_prior_outcome(good,reservation)
        for key,value in [('status',None),('status','UNKNOWN'),('mode','qualify'),('receipt_sha256',None),('manifest_sha256','c'*64),('apk_builds',False)]:
            changed=copy.deepcopy(good);changed[key]=value
            with self.assertRaises(ValueError):d.validate_prior_outcome(changed,reservation)
    def test_safety_continuation_needs_bound_evidence_and_closed_scope(self):
        prior={'manifest_sha256':'a'*64,'receipt_sha256':'b'*64};m={'semantic_sha256':'c'*64,'controller_sha256':'d'*64}
        note={'decision_by':'Codex','prior_manifest_sha256':'a'*64,'prior_receipt_sha256':'b'*64,'new_semantic_sha256':'c'*64,'new_controller_sha256':'d'*64,'cause':'specific fixed monitor bug','static_fix_evidence_sha256':'e'*64,'scope_unchanged':True,'preconditions_revalidated':True,'owner_new_permission_required':False}
        d.validate_continuation(note,prior,m)
        for key,value in [('prior_receipt_sha256','f'*64),('scope_unchanged',False),('preconditions_revalidated',1),('owner_new_permission_required',True),('cause','')]:
            bad=copy.deepcopy(note);bad[key]=value
            with self.assertRaises(ValueError):d.validate_continuation(bad,prior,m)
    def test_launch_chain_requires_claim_and_exact_permanent_binding(self):
        with tempfile.TemporaryDirectory() as name,patch.object(d,'TASK_ROOT',Path(name)):
            root=Path(name)/'attempt';root.mkdir();d.put(root/'manifest.json',{'fixed':'input'})
            m={'mode':'gradle','semantic_sha256':'c'*64,'arguments':['fixed']}
            with self.assertRaises(FileNotFoundError):d.validate_launch_chain(root,m)
            claim={'attempt':1,'mode':'gradle','manifest_sha256':d.sha(root/'manifest.json'),'semantic_sha256':'c'*64,'refundable':False,'G2':False}
            d.put(root/'launch.claim.json',claim);d.put(root/'launched.json',{'pid':1,'creationUtc':'fixed'})
            with self.assertRaises(ValueError):d.validate_launch_chain(root,m)
            reserved=d.next_reservation(d.ledger(),manifest_sha256=claim['manifest_sha256'],command_sha256=d.data_sha(m['arguments']))
            d.put(Path(name)/'reservation-1.json',reserved)
            self.assertEqual(d.validate_launch_chain(root,m),claim)
    def test_configuration_disables_network_and_only_output_is_writable(self):
        with tempfile.TemporaryDirectory() as name:
            root=Path(name);(root/'probe').mkdir();(root/'output').mkdir()
            with patch.object(d,'mappings',return_value=[(root/'probe',r'C:\Probe',True),(root/'output',r'C:\ProbeOutput',False)]):
                xml=ET.fromstring(d.config(root,{'nonce':'a'*32,'mode':'gradle'}))
            self.assertEqual(xml.findtext('Networking'),'Disable');self.assertEqual(xml.findtext('MemoryInMB'),'4096')
            writable=[r.findtext('SandboxFolder') for r in xml.findall('./MappedFolders/MappedFolder') if r.findtext('ReadOnly')=='false']
            self.assertEqual(writable,[r'C:\ProbeOutput'])

if __name__=='__main__':unittest.main()
