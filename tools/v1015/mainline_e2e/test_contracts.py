"""Pure synthetic tests only. No HTTP, DB, Flutter, device or executable fixture launch."""
import copy,io,json,os,tempfile,unittest
from contextlib import redirect_stdout
from datetime import datetime,timedelta,timezone
from pathlib import Path
from contracts import *
import run
class Contracts(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(prefix="v1015-mainline-live-",suffix="-20261029",dir=os.environ["ELITESYNC_SELFTEST_ROOT"])
        self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
        now=datetime.now(timezone.utc)
        self.c=dict(task_root=str(self.root),api=API,database=DATABASE,db_port=43349,max_bytes=1048576,source_binding=dict(commit="1"*40,apps_tree="2"*40,services_tree="3"*40,apk_sha256=None))
        self.g=dict(owner_authorized=True,task_blob="4"*40,action="mainline_api_db_e2e",new_instance_qualified=True,not_before=(now-timedelta(minutes=1)).isoformat(),expires_at=(now+timedelta(minutes=1)).isoformat(),source_binding=self.c["source_binding"],config_sha256=digest(canonical(self.c)),http_operations=1,php_operations=1,max_bytes=self.c["max_bytes"])
    def rejects(self,fn):
        with self.assertRaises((Gate,ValueError,KeyError)):fn()
    def test_current_task_has_no_runtime_grant(self):
        self.g["task_blob"]=CURRENT_TASK;self.rejects(lambda:validate_authority(self.c,self.g))
    def test_missing_owner_is_rejected(self):self.rejects(lambda:validate_authority(self.c,None))
    def test_future_grant_only_validates_configuration(self):self.assertEqual(self.root,validate_authority(self.c,self.g))
    def test_old_and_remote_ports_are_rejected(self):
        for port in (3306,43316,43329,43339):
            c=dict(self.c,db_port=port);self.rejects(lambda:validate_authority(c,self.g))
    def test_external_api_and_expired_grant_rejected(self):
        self.rejects(lambda:validate_authority(dict(self.c,api="https://example.invalid"),self.g))
        self.g["expires_at"]=(datetime.now(timezone.utc)-timedelta(seconds=1)).isoformat();self.rejects(lambda:validate_authority(self.c,self.g))
    def test_source_and_config_mismatch_rejected(self):
        self.g["source_binding"]=dict(self.c["source_binding"],commit="5"*40);self.rejects(lambda:validate_authority(self.c,self.g))
    def test_default_inspect_creates_no_files(self):
        before=list(self.root.rglob("*"));out=io.StringIO()
        with redirect_stdout(out):self.assertEqual(0,run.main([]))
        self.assertIn("NOT_RUN_GATE_CLOSED",out.getvalue());self.assertEqual(before,list(self.root.rglob("*")))
    def test_network_names_rejected_before_stat(self):
        self.rejects(lambda:local("//server/share/data"))
    def test_ledger_reservation_consumes_failed_attempt(self):
        ledger=run.Ledger(self.root,self.g,16*1024**2);self.assertEqual(1,ledger.reserve("http"));self.rejects(lambda:ledger.reserve("http"))
        self.rejects(lambda:run.Ledger(self.root,self.g,16*1024**2))
    def test_duplicate_message_or_notification_is_failure(self):
        check_counts(dict(message_count=1,attachment_count=1,notification_count=1),1)
        for k in ("message_count","attachment_count","notification_count"):
            row=dict(message_count=1,attachment_count=1,notification_count=1);row[k]=2;self.rejects(lambda:check_counts(row,1))
    def test_t0_deadlines_are_exact_but_not_elapsed_proof(self):
        t=datetime(2026,10,29,tzinfo=timezone.utc);r=dict(user_id=1,device_id="synthetic",login_at=t.isoformat(),server_now=t.isoformat(),online_expires_at=(t+timedelta(days=15)).isoformat(),purge_at=(t+timedelta(days=30)).isoformat())
        check_login(r,1,"synthetic");r["purge_at"]=(t+timedelta(days=31)).isoformat();self.rejects(lambda:check_login(r,1,"synthetic"))
    def test_privacy_projection_disallows_private_extra_fields(self):
        row=dict(status="TEST_ONLY",provider_status="REAL_PUSH_PROVIDER_PENDING",payload=dict(notification_id=1,title="EliteSync",body="请打开应用查看当前有权通知。"))
        check_projection(row);row["payload"]["sender_name"]="synthetic";self.rejects(lambda:check_projection(row))
    def test_mock_and_wrong_source_app_receipts_are_rejected(self):
        self.rejects(lambda:check_app_receipts([dict(source_binding=self.c["source_binding"],origin="MOCK")],self.c["source_binding"],[],self.root))
        self.assertEqual("NOT_RUN_GATE_CLOSED",check_app_receipts([],self.c["source_binding"],["unknown_edit_retry"],self.root)["unknown_edit_retry"]["status"])
    def test_app_receipt_requires_actual_matching_artifact(self):
        p=self.root/"synthetic-evidence";p.write_bytes(b"inert synthetic receipt fixture")
        row=dict(scenario="x",source_binding=self.c["source_binding"],origin="ACTUAL_APP_OBSERVATION",artifact=str(p),artifact_sha256="0"*64)
        self.rejects(lambda:check_app_receipts([row],self.c["source_binding"],["x"],self.root))
    def test_case_ids_and_gates_are_complete(self):
        cases=json.loads(Path(__file__).with_name("scenarios.json").read_bytes())["cases"]
        self.assertEqual(15,len(cases));self.assertEqual(15,len({x["id"] for x in cases}));self.assertTrue(all(x["current_result"]=="NOT_RUN_GATE_CLOSED" for x in cases))
