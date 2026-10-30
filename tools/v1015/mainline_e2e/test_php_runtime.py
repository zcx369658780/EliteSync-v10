"""Synthetic inert PE/module facts only. Native observer and runtime launch are never called."""
import copy,io,json,os,struct,tempfile,unittest
from pathlib import Path
from contextlib import redirect_stdout
from unittest.mock import patch
from datetime import datetime,timedelta,timezone
from contracts import *
from php_runtime import *
from php_native import validate_images
import php_api_entry
def inert_pe(imports=(),machine=0x8664):
    data=bytearray(2048);data[:2]=b"MZ";struct.pack_into("<I",data,0x3c,0x80);data[0x80:0x84]=b"PE\0\0"
    struct.pack_into("<HH",data,0x84,machine,1);struct.pack_into("<H",data,0x94,240)
    opt=0x98;struct.pack_into("<H",data,opt,0x20b);struct.pack_into("<I",data,opt+60,512);struct.pack_into("<I",data,opt+108,16)
    section=opt+240;struct.pack_into("<IIII",data,section+8,1536,0x1000,1536,512)
    if imports:
        struct.pack_into("<II",data,opt+120,0x1000,20*(len(imports)+1))
        for i,name in enumerate(imports):
            struct.pack_into("<IIIII",data,512+i*20,0,0,0,0x1200+i*64,1)
            value=name.encode()+b"\0";data[1024+i*64:1024+i*64+len(value)]=value
    return bytes(data)
class PhpRuntimeContracts(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(prefix="php-runtime-inert-",dir=os.environ["ELITESYNC_SELFTEST_ROOT"]);self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name);self.runtime=self.root/"runtime";(self.runtime/"bin/ext").mkdir(parents=True)
        self.policy=json.loads(POLICY.read_bytes());self.policy["reference_executable_sha256"]=digest(inert_pe(["php8.dll"]))
        inventory="1"*64
        self.manifest=dict(schema=1,platform="windows-x64",php_version=self.policy["php_version"],thread_safe=False,candidate_parent=self.policy["candidate_parent"],source_binding=dict(apps_tree=self.policy["apps_tree"]),requirements_sha256=digest(canonical(self.policy)),php_distribution_inventory_sha256=inventory,executable="bin/php.exe",extension_directory="bin/ext",shared_modules={},builtin_modules=sorted(set(self.policy["required_modules"])-set(self.policy["required_shared_modules"])),files=[],windows_system_modules={})
        def add(rel,imports=(),origin="TRUSTED_EXISTING_PHP_DISTRIBUTION"):
            data=inert_pe(imports);p=self.runtime/rel;p.write_bytes(data)
            self.manifest["files"].append(dict(path=rel,sha256=digest(data),source_sha256=digest(data),source_inventory_sha256=inventory,origin=origin))
        add("bin/php.exe",["php8.dll"]);add("bin/php8.dll",["kernel32.dll"]);add("bin/libprivate.dll",["kernel32.dll"],"TRUSTED_EXISTING_REDISTRIBUTABLE")
        for module in self.policy["required_shared_modules"]:
            rel="bin/ext/php_"+module+".dll";add(rel,["php8.dll","libprivate.dll"]);self.manifest["shared_modules"][module]=rel
    def validate(self):return validate_manifest(self.manifest,self.runtime,self.policy)
    def rejects(self,operation):
        with self.assertRaises((Gate,ValueError,KeyError)):operation()
    def test_valid_frozen_inert_manifest_is_static_only(self):
        p=self.validate();self.assertEqual("STATIC_PRECONDITION_OK",p["state"]);self.assertEqual("LIVE_MODULE_LOAD_NOT_RUN",p["live"])
    def test_missing_mbstring_rejected(self):
        self.manifest["shared_modules"].pop("mbstring");self.rejects(self.validate)
    def test_mbstring_cannot_be_relabelled_builtin(self):
        self.manifest["shared_modules"].pop("mbstring");self.manifest["builtin_modules"].append("mbstring");self.rejects(self.validate)
    def test_missing_native_dependency_rejected(self):
        self.manifest["files"]=[x for x in self.manifest["files"] if x["path"]!="bin/libprivate.dll"];(self.runtime/"bin/libprivate.dll").unlink();self.rejects(self.validate)
    def test_unlisted_extension_file_rejected(self):
        (self.runtime/"bin/ext/php_unknown.dll").write_bytes(inert_pe());self.rejects(self.validate)
    def test_changed_extension_hash_rejected(self):
        (self.runtime/"bin/ext/php_mbstring.dll").write_bytes(b"inert changed");self.rejects(self.validate)
    def test_wrong_executable_hash_rejected(self):
        self.policy["reference_executable_sha256"]="0"*64;self.manifest["requirements_sha256"]=digest(canonical(self.policy));self.rejects(self.validate)
    def test_wrong_architecture_rejected(self):
        self.rejects(lambda:pe_info(inert_pe(machine=0x14c)))
    def test_wrong_version_rejected(self):
        self.manifest["php_version"]="8.4.0";self.rejects(self.validate)
    def test_mixed_distribution_inventory_rejected(self):
        self.manifest["files"][0]["source_inventory_sha256"]="2"*64;self.rejects(self.validate)
    def test_unknown_origin_rejected(self):
        self.manifest["files"][0]["origin"]="GLOBAL_PATH";self.rejects(self.validate)
    def test_no_source_hash_proof_rejected(self):
        self.manifest["files"][0].pop("source_sha256");self.rejects(self.validate)
    def test_wrong_candidate_lineage_rejected(self):
        self.manifest["candidate_parent"]="0"*40;self.rejects(self.validate)
    def test_wrong_apps_candidate_rejected(self):
        self.manifest["source_binding"]["apps_tree"]="0"*40;self.rejects(self.validate)
    def test_relative_path_escape_rejected(self):
        for value in ("../outside.dll","/outside.dll","x/../outside.dll","c:/global.dll","x\\outside.dll"):
            self.rejects(lambda:relative(value))
    def test_reparse_rejected_without_resolving_target(self):
        real=Path.lstat;target=self.runtime/"bin/php.exe"
        def fake(p,*a,**kw):
            st=real(p,*a,**kw)
            if p==target:
                class Link:
                    st_mode=st.st_mode;st_file_attributes=0x400;st_nlink=1
                return Link()
            return st
        with patch.object(Path,"lstat",fake):self.rejects(self.validate)
    def test_cli_api_share_identical_n_and_extensions(self):
        p=self.validate();cli=launch_arguments(p,self.root);router=self.root/"server.php";router.write_bytes(b"inert")
        api=api_arguments(p,self.root,router);self.assertEqual(cli,api[:len(cli)]);self.assertEqual("-n",cli[1]);self.assertNotIn("-c",cli)
        for value in p["extension_paths"]:self.assertIn("extension="+value,cli)
    def test_environment_does_not_inherit_ini_or_path(self):
        p=self.validate();p["manifest_sha256"]="1"*64
        env=private_environment(p,self.root,"OS_HOST_REFERENCE")
        self.assertEqual(str(self.root/"empty-ini"),env["PHPRC"]);self.assertEqual(str(self.runtime/"bin"),env["PATH"]);self.assertNotIn("COMSPEC",env)
    def config_grant(self):
        root=self.root/"v1015-mainline-live-runtime-20261029";root.mkdir()
        now=datetime.now(timezone.utc);binding=dict(commit="1"*40,apps_tree=self.policy["apps_tree"],services_tree="2"*40,apk_sha256=None)
        c=dict(task_root=str(root),api=API,database=DATABASE,db_port=43349,max_bytes=10485760,source_binding=binding,php_runtime_manifest=str(root/"manifest.json"),php_runtime_manifest_sha256="3"*64)
        (root/"manifest.json").write_bytes(canonical(self.manifest));c["php_runtime_manifest_sha256"]=digest((root/"manifest.json").read_bytes())
        g=dict(owner_authorized=True,task_blob="4"*40,action="mainline_api_db_e2e",new_instance_qualified=True,not_before=(now-timedelta(minutes=1)).isoformat(),expires_at=(now+timedelta(minutes=1)).isoformat(),config_sha256=digest(canonical(c)),source_binding=binding,max_bytes=c["max_bytes"],http_operations=1,php_operations=1,php_cli_manifest_sha256=c["php_runtime_manifest_sha256"],php_api_manifest_sha256=c["php_runtime_manifest_sha256"])
        return c,g
    def test_old_tasks_cannot_be_reused(self):
        c,g=self.config_grant()
        for task in ZERO_TASKS:
            g["task_blob"]=task;self.rejects(lambda:qualify_config(c,g))
    def test_unauthorized_configuration_rejected(self):
        c,g=self.config_grant();g["owner_authorized"]=False;self.rejects(lambda:qualify_config(c,g))
    def test_cli_api_closure_mismatch_rejected(self):
        c,g=self.config_grant();g["php_api_manifest_sha256"]="0"*64;self.rejects(lambda:qualify_config(c,g))
    def test_policy_injection_cannot_enable_execution(self):
        c,g=self.config_grant();self.rejects(lambda:qualify_config(c,g))
    def native(self):
        p=self.validate();system=self.root/"System32";system.mkdir();dll=system/"kernel32.dll";dll.write_bytes(b"INERT_OS_FIXTURE")
        self.manifest["windows_system_modules"]["kernel32.dll"]=digest(dll.read_bytes())
        # Pure synthetic OS facts/pins; these do not qualify this temp path as Windows.
        rootfact=dict(path=str(system),file_id=100,volume=7,from_system_directory_api=True,reparse=False)
        fact=dict(path=str(dll),canonical_path=str(dll),readonly_handle=True,from_loaded_module_api=True,sha256=digest(dll.read_bytes()),file_id=101,volume=7,links=2,bytes=len(dll.read_bytes()),reparse=False)
        pin=dict(fact,signature_status='Valid',windows_publisher_verified=True,signer_thumbprint='a'*40,source_class='WINDOWS_SYSTEM_IMAGE')
        self.manifest['windows_os_image_policy']=dict(schema=1,purpose='READONLY_LOADED_WINDOWS_OS_IMAGES',system_root=rootfact,images={'kernel32.dll':pin})
        self.enterContext(patch('php_native.system_root_fact',return_value=rootfact))
        self.enterContext(patch('php_native.readonly_fact',return_value=fact))
        images=[dict(path=str(self.runtime/x["path"]),sha256=x["sha256"],source_class="TASK_PRIVATE_BINARY") for x in self.manifest["files"]]+[dict(path=str(dll),sha256=digest(dll.read_bytes()),source_class="WINDOWS_SYSTEM_IMAGE")]
        return p,system,images
    def test_synthetic_native_map_matches_declared_inputs_only(self):
        p,s,images=self.native();self.assertEqual("NATIVE_IMAGE_MAP_INPUT_MATCHED",validate_images(images,p,s)["state"])
    def test_private_class_cannot_be_relabelled_as_system(self):
        p,s,images=self.native();images[0]['source_class']='WINDOWS_SYSTEM_IMAGE'
        with self.assertRaisesRegex(Gate,'PRIVATE_SOURCE_CLASS'):validate_images(images,p,s)
    def test_system_class_cannot_be_relabelled_as_private(self):
        p,s,images=self.native();images[-1]['source_class']='TASK_PRIVATE_BINARY'
        with self.assertRaisesRegex(Gate,'OS_SOURCE_CLASS'):validate_images(images,p,s)
    def test_global_extension_image_rejected(self):
        p,s,images=self.native();bad=self.root/"global_mbstring.dll";bad.write_bytes(b"INERT")
        images.append(dict(path=str(bad),sha256=digest(bad.read_bytes())));self.rejects(lambda:validate_images(images,p,s))
    def test_changed_native_image_rejected(self):
        p,s,images=self.native();images[0]["sha256"]="0"*64;self.rejects(lambda:validate_images(images,p,s))
    def test_missing_extension_image_rejected(self):
        p,s,images=self.native();images=[x for x in images if not x["path"].endswith("php_mbstring.dll")];self.rejects(lambda:validate_images(images,p,s))
    def test_unqualified_os_hash_rejected(self):
        p,s,images=self.native();self.manifest["windows_system_modules"]={};self.rejects(lambda:validate_images(images,p,s))
    def test_api_inspect_has_no_process_or_file_side_effect(self):
        before=list(self.root.rglob("*"));output=io.StringIO()
        with redirect_stdout(output):self.assertEqual(0,php_api_entry.main([]))
        self.assertIn("LIVE_MODULE_LOAD_NOT_RUN",output.getvalue());self.assertEqual(before,list(self.root.rglob("*")))
    def test_truncated_pe_and_unterminated_import_rejected(self):
        self.rejects(lambda:pe_info(b"MZ"))
        data=bytearray(inert_pe(["php8.dll"]));struct.pack_into("<I",data,0x98+124,20);self.rejects(lambda:pe_info(bytes(data)))

    def test_policy_and_language_closed_task_sets_match(self):
        policy=json.loads(POLICY.read_bytes());self.assertEqual(ZERO_TASKS,set(policy["closed_runtime_task_blobs"]))

    def test_api_raw_can_preexist_without_blocking_driver(self):
        import run
        (self.root/"raw/api").mkdir(parents=True)
        c=dict(max_bytes=16777216);g=dict(task_blob="4"*40,source_binding={})
        with patch("run.qualify_config",return_value={}):runner=run.Runner(c,g,self.root)
        self.assertEqual(self.root/"raw/driver",runner.raw)
        self.assertTrue((self.root/"raw/api").is_dir())

    def test_historical_driver_raw_is_not_reused(self):
        import run
        (self.root/"raw/driver").mkdir(parents=True)
        with patch("run.qualify_config",return_value={}):
            self.rejects(lambda:run.Runner(dict(max_bytes=16777216),dict(task_blob="4"*40,source_binding={}),self.root))

    def test_native_cli_and_api_receipts_are_separate(self):
        from php_native import native_paths
        for name in ("api","driver"):(self.root/"raw"/name).mkdir(parents=True)
        cli=native_paths(self.root,"a"*32,"driver");api=native_paths(self.root,"a"*32,"api")
        self.assertNotEqual(cli,api)

