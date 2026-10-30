"""Synthetic authority/boundary regressions for this task, no Windows observation."""
import copy,unittest
from pathlib import Path
from contracts import Gate,canonical,digest
from current_native_task import probe_authority, BINDING, TASK, ROOT_NAME
import test_native_unblock
from php_runtime import qualify_config

class CurrentProbeContracts(unittest.TestCase):
    def setUp(self):
        test_native_unblock.NoDbProbeContracts.setUp(self)
        root=self.root.with_name(ROOT_NAME);self.root.rename(root);self.root=root
        self.config.update(task_root=str(root),source_root=str(root/'backend'),source_binding=dict(BINDING))
        self.grant.update(task_blob=TASK,probe_operations=2,source_binding=dict(BINDING));self.rehash()
    def rehash(self):self.grant['config_sha256']=digest(canonical(self.config))
    def valid(self):return probe_authority(self.config,self.grant)
    def reject(self):
        with self.assertRaises((Gate,KeyError,ValueError)):self.valid()
    def test_native_probe_does_not_require_a_resolved_business_lock(self):self.assertEqual(self.root,self.valid())
    def test_same_native_grant_cannot_authorize_business(self):
        with self.assertRaises(Gate):qualify_config(self.config,self.grant)
    def test_old_task_cannot_inherit_budget(self):self.grant['task_blob']='d048f7f8fee97a93f8bf8c52293f60762fff0bda';self.reject()
    def test_wrong_source_binding_rejected(self):self.config['source_binding']['commit']='a'*40;self.rehash();self.reject()
    def test_extra_probe_rejected(self):self.grant['probe_operations']=3;self.reject()
    def test_longer_probe_rejected(self):self.grant['probe_seconds']=31;self.reject()
    def test_network_forbidden(self):self.grant['network_operations']=1;self.reject()
    def test_db_forbidden(self):self.grant['db_operations']=1;self.reject()
    def test_laravel_bootstrap_forbidden(self):self.grant['laravel_bootstrap_allowed']=True;self.reject()
    def test_expired_authority_rejected(self):self.grant['expires_at']='2000-01-01T00:00:00+00:00';self.reject()
    def test_owner_required(self):self.grant['owner_authorized']=False;self.reject()
    def test_source_bytes_changed_rejected(self):(Path(self.config['source_root'])/'composer.lock').write_bytes(b'FAKE');self.reject()
    def test_db_configuration_rejected(self):self.config['db_port']=43349;self.rehash();self.reject()
    def test_config_mutation_rejected(self):self.config['max_bytes']+=1;self.reject()
    def test_space_limit_rejected(self):self.config['max_bytes']=8589934593;self.grant['max_bytes']=8589934593;self.rehash();self.reject()
