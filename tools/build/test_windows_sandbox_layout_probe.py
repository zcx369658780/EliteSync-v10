import copy
from pathlib import Path
import unittest
from unittest.mock import patch
from types import SimpleNamespace
import tempfile
import windows_sandbox_layout_probe as layout_probe


class LayoutReceiptTests(unittest.TestCase):
    def setUp(self):
        self.m={'nonce':'a'*32,'binary_sha256':'b'*64,
            'readonly_files':[f'C:\\Inputs\\{i}\\file' for i in range(7)],
            'readonly_roots':[f'C:\\Inputs\\{i}' for i in range(7)]}

    def good(self):
        checks=[{'path':p,'access':a,'directory':False,'succeeded':False,'native_error':5}
                for p in self.m['readonly_files'] for a in [0x40000000,0x40000,0x80000]]
        checks += [{'path':p,'access':0x40,'directory':True,'succeeded':False,'native_error':5} for p in self.m['readonly_roots']]
        receipt={'schema':1,'kind':'readonly-input-layout','nonce':'a'*32,'username':'WDAGUtilityAccount',
            'binary_sha256':'b'*64,'failure':None,'java_exit':0,'readonly_checks':checks,
            'clr_version':'4.0','kernel_file_version':'10.0','gradle_starts':0,'apk_builds':0,'G2':False}
        paths=[r'C:\Inputs\Flutter',r'C:\Inputs\Flutter\packages\flutter_tools\gradle',r'C:\Inputs\DependencyCache\modules-2',
            r'C:\Inputs\Pub\jni\android',r'C:\BuildWork\Project\apps\flutter_elitesync_module\.android',
            r'C:\BuildWork\Tooling\packages\flutter_tools\gradle',r'C:\BuildWork\state\cmake\jni',r'C:\BuildWork\GradleHome']
        layout={'nonce':'a'*32,'username':'WDAGUtilityAccount','failure':None,'product_files':718,'tooling_files':50,
            'native_files':2145,'seed_files':3183,'native_plugins':14,'private_writes':19,
            'path_traits':[{'path':p,'real':p,'canonical_equal':True,'ancestors_clean':True,'symbolic_link':False,'other':False,'directory':True} for p in paths],
            'old_jni_generated_cache_visible':False,'original_guard_tooling_path_equal':False,
            'java_version':'17.0.18','os_name':'Windows','os_version':'10.0','gradle_starts':0,'G2':False,
            'gradle_index_parse':False,'agp_override_consumed':False}
        return receipt,layout

    def test_bounded_layout_can_pass_without_claiming_guard_or_gradle(self):
        receipt,layout=self.good()
        layout['path_traits'][0].update(canonical_equal=False,ancestors_clean=False,other=True)
        layout_probe.validate_receipts(receipt,layout,self.m)

    def test_guest_failure_or_wrong_identity_cannot_pass(self):
        for key,value in [('failure','copy failed'),('nonce','c'*32),('java_exit',False),('schema',True)]:
            receipt,layout=self.good();receipt[key]=value
            with self.assertRaises(ValueError):layout_probe.validate_receipts(receipt,layout,self.m)

    def test_missing_duplicate_or_successful_readonly_operation_rejected(self):
        for mode in ['missing','duplicate','success','error','directory_type']:
            receipt,layout=self.good()
            if mode=='missing':receipt['readonly_checks'].pop()
            elif mode=='duplicate':receipt['readonly_checks'][-1]=receipt['readonly_checks'][0].copy()
            elif mode=='success':receipt['readonly_checks'][0]['succeeded']=True
            elif mode=='error':receipt['readonly_checks'][0]['native_error']=32
            else:receipt['readonly_checks'][0]['directory']=0
            with self.assertRaises(ValueError):layout_probe.validate_receipts(receipt,layout,self.m)

    def test_private_work_paths_must_be_exact_and_canonical(self):
        for key,value in [('canonical_equal',False),('real',r'\\server\share'),('path',r'C:\other'),('ancestors_clean',None)]:
            receipt,layout=self.good();layout['path_traits'][-1][key]=value
            with self.assertRaises(ValueError):layout_probe.validate_receipts(receipt,layout,self.m)

    def test_counts_and_unknown_environment_rejected(self):
        for key,value in [('seed_files',True),('product_files',717),('private_writes',18),('os_version',None)]:
            receipt,layout=self.good();layout[key]=value
            with self.assertRaises(ValueError):layout_probe.validate_receipts(receipt,layout,self.m)

    def test_cannot_promote_data_read_to_index_or_override_execution(self):
        for key in ['gradle_index_parse','agp_override_consumed','original_guard_tooling_path_equal','G2']:
            receipt,layout=self.good();layout[key]=True
            with self.assertRaises(ValueError):layout_probe.validate_receipts(receipt,layout,self.m)
        for key in ['gradle_starts','apk_builds']:
            receipt,layout=self.good();receipt[key]=False
            with self.assertRaises(ValueError):layout_probe.validate_receipts(receipt,layout,self.m)

    def test_relative_paths_cannot_escape_input_tree(self):
        root=Path(r'C:\owned')
        for name in ['../secret',r'C:\secret',r'\secret','folder/file:stream','folder/name.']:
            with self.assertRaises(ValueError):layout_probe.relative(root,name)

    def test_compiler_child_environment_drops_injection_without_global_changes(self):
        malicious={'JAVA_TOOL_OPTIONS':'-javaagent:bad.jar','JDK_JAVAC_OPTIONS':'@bad.args',
            'CLASSPATH':'untrusted','_JAVA_OPTIONS':'agent','JDK_JAVA_OPTIONS':'agent',
            'COR_PROFILER':'bad','COMPlus_foo':'bad','LIB':'bad','KEEP':'unchanged'}
        with patch.dict(layout_probe.os.environ,malicious,clear=True):
            before=dict(layout_probe.os.environ)
            env=layout_probe.compiler_environment(Path(r'C:\owned'))
            self.assertEqual(dict(layout_probe.os.environ),before)
        for key in malicious:
            if key!='KEEP':self.assertNotIn(key.upper(),{name.upper():value for name,value in env.items()})
        self.assertEqual(env['KEEP'],'unchanged')

    def test_actual_javac_subprocess_uses_clean_env_and_no_processors(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            with patch.dict(layout_probe.os.environ,{'JAVA_TOOL_OPTIONS':'bad','JDK_JAVAC_OPTIONS':'bad','CLASSPATH':'bad'},clear=True), \
                 patch.object(layout_probe.subprocess,'run',return_value=SimpleNamespace(returncode=0,stdout=b'',stderr=b'')) as run:
                layout_probe.compile_programs(root,Path(r'C:\existing\csc.exe'))
            args=run.call_args_list[0].args[0];kwargs=run.call_args_list[0].kwargs
            self.assertIn('-proc:none',args)
            self.assertEqual(args[args.index('-classpath')+1],str(root/'empty-classpath'))
            self.assertEqual(args[args.index('-sourcepath')+1],str(root/'empty-classpath'))
            self.assertEqual(kwargs['cwd'],root)
            for key in ['JAVA_TOOL_OPTIONS','JDK_JAVAC_OPTIONS','CLASSPATH']:self.assertNotIn(key,kwargs['env'])

    def test_product_reads_use_captured_commit_after_first_head_lookup(self):
        commit='c'*40
        with patch.object(layout_probe.subprocess,'check_output',side_effect=[commit+'\n','d'*40+'\n'+'e'*40+'\n',b'',b'objects']) as call:
            source,trees,listing=layout_probe.product_identity(Path(r'C:\owned'))
        self.assertEqual(source,commit);self.assertEqual(listing,b'objects')
        calls=[item.args[0] for item in call.call_args_list]
        self.assertEqual(calls[1],['git','rev-parse',commit+':apps',commit+':services'])
        for args in calls[2:]:
            self.assertIn(commit,args);self.assertNotIn('HEAD',args)


if __name__=='__main__':unittest.main()
