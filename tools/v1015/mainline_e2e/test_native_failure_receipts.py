"""Synthetic Popen doubles; NEVER starts PHP or enumerates a real process."""
import io,json,os,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from contracts import Gate
from php_native import cli

class CliFailureReceipts(unittest.TestCase):
    def run_fake(self,mode):
        tmp=tempfile.TemporaryDirectory(dir=os.environ['ELITESYNC_SELFTEST_ROOT']);self.addCleanup(tmp.cleanup)
        root=Path(tmp.name);(root/'raw/driver').mkdir(parents=True)
        profile=dict(executable=str(root/'php.exe'),manifest={},manifest_sha256='a'*64,extension_paths=[])
        owner=self
        class Process:
            pid=123;_handle=7;returncode=None
            def __init__(self):self.stdin=io.BytesIO();self.killed=False
            def poll(self):return self.returncode
            def kill(self):self.killed=True;self.returncode=-9
            def wait(self):return self.returncode
            def communicate(self,timeout):
                if self.returncode is None:self.returncode=0
                return b'ORIGINAL_STDOUT',b'ORIGINAL_LOADER_STDERR'
        child=Process()
        def launch(*a,**kw):
            owner.assertFalse(kw['shell']);env=kw['env']
            value=dict(pid=child.pid,nonce=env['ELITESYNC_PHP_START_NONCE'],manifest_sha256='a'*64)
            if mode=='wrong_nonce':value['nonce']='b'*32
            Path(env['ELITESYNC_PHP_NATIVE_READY']).write_text(json.dumps(value))
            return child
        with patch('php_native.subprocess.Popen',side_effect=launch) as popen,patch('php_native.capture_images',return_value=([],str(root))),patch('php_native.validate_images',side_effect=Gate('MAP_DENIED') if mode=='bad_map' else None),patch('php_native.process_identity',return_value=dict(pid=123,creation=10,running=True)):
            if mode=='success':
                result=cli(profile,['INERT_ONLY'],b'{}',{},root);self.assertEqual(0,result.returncode);self.assertEqual(b'ORIGINAL_STDOUT',result.stdout)
            else:
                with self.assertRaises(Gate) as exc:cli(profile,['INERT_ONLY'],b'{}',{},root)
                self.assertEqual(-9,exc.exception.returncode);self.assertEqual(b'ORIGINAL_LOADER_STDERR',exc.exception.native_stderr)
                self.assertTrue(child.killed)
            popen.assert_called_once()
    def test_synthetic_success_retains_real_exit_fields(self):self.run_fake('success')
    def test_synthetic_nonce_rejection_retains_first_failure_streams(self):self.run_fake('wrong_nonce')
    def test_synthetic_native_map_rejection_retains_first_failure_streams(self):self.run_fake('bad_map')
