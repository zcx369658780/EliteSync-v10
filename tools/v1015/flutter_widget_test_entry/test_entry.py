"""STATIC_OR_PURE_SELFTEST_ONLY. No subprocess, Flutter, Dart, DB, HTTP or shell.

Every executable fixture is inert bytes. execute positives use an injected fake.
Run with Python -B; ELITESYNC_SELFTEST_ROOT must be the authorized task-owned tmp.
"""
import ast
import copy
import io
import json
import os
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path

import core
import entry
import runtime


LOCKS = json.loads(Path(__file__).with_name("locks.json").read_bytes())
ORIGINAL = b"before\n"
PATCH = b"--- original\n+++ patched\n@@ -1 +1 @@\n-before\n+after\n"


class PureEntryTests(unittest.TestCase):
    def setUp(self):
        base = Path(os.environ["ELITESYNC_SELFTEST_ROOT"]).resolve()
        self.tmp = tempfile.TemporaryDirectory(prefix="entry-synthetic-", dir=base)
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.inputs = self.root / "inputs"; self.inputs.mkdir()
        self.outputs = self.root / "outputs"; self.outputs.mkdir()
        self.target = self.outputs / "task"
        self.pins = copy.deepcopy(LOCKS)
        self.pins.update(hook_original_sha256=core.digest(ORIGINAL), hook_target_sha256=core.digest(b"after\n"),
                         patch_diff_sha256=core.digest(PATCH), source_app_blob_count=1)
        self.config = dict(task_id="SYNTHETIC_TASK", target=str(self.target), owned_parent=str(self.outputs),
                           approved_input_roots=[str(self.inputs)], complete_offline_manifest=True,
                           max_logical=8 * 1024**2, max_allocated=8 * 1024**2, artifacts=[])
        roles = dict(dart="flutter_private/bin/cache/dart-sdk/bin/dart.exe",
                     dart_vm="flutter_private/bin/cache/dart-sdk/bin/dartvm.exe",
                     engine="flutter_private/bin/cache/artifacts/engine/windows-x64/flutter_tester.exe",
                     git="flutter_private/bin/mingit/cmd/git.exe", where="os_tools/where.exe",
                     flutter_entry="flutter_private/packages/flutter_tools/bin/flutter_tools.dart",
                     flutter_version="flutter_private/bin/cache/flutter.version.json",
                     hook_original="pub_private/hosted/example/hooks_runner-1.0.1/lib/run_process.dart",
                     tools_resolver="flutter_private/packages/flutter_tools/.dart_tool/package_config.json",
                     app_resolver="source/apps/flutter_elitesync_module/.dart_tool/package_config.json")
        for role, rel in roles.items():
            data = ("INERT-SYNTHETIC-" + role).encode()
            if role == "hook_original": data = ORIGINAL
            if role == "flutter_version":
                data = json.dumps(dict(frameworkVersion="3.41.7", frameworkRevision=self.pins["framework_revision"], dartSdkVersion="3.11.5")).encode()
            if role in ("tools_resolver", "app_resolver"):
                data = json.dumps(dict(packages=[dict(name="synthetic", rootUri="../", packageUri="lib/")])).encode()
            self.add_input(role, rel, data)
            if role in ("dart", "flutter_entry", "dart_vm", "engine", "git", "where"):
                self.pins[{"dart": "dart_executable_sha256", "flutter_entry": "flutter_entry_sha256"}.get(role, role + "_sha256")] = core.digest(data)
        app = b"synthetic source, never executed\n"
        self.add_input("support", "source/apps/flutter_elitesync_module/pubspec.lock", app, tracked=True)
        blob = __import__("hashlib").sha1(b"blob " + str(len(app)).encode() + b"\0" + app).hexdigest()
        self.pins["source_apps_tree"] = core.git_tree([("flutter_elitesync_module/pubspec.lock", "100644", blob)])
        diff = self.inputs / "local-only.diff"; diff.write_bytes(PATCH); self.config["patch_diff"] = str(diff)

    def add_input(self, role, rel, data, **extras):
        p = self.inputs / (str(len(self.config["artifacts"])) + ".synthetic")
        p.write_bytes(data)
        self.config["artifacts"].append(dict(role=role, relative=rel, source=str(p), sha256=core.digest(data), **extras))

    def plan(self):
        return core.inspect_plan(self.config, self.pins)[0]

    def grant(self, plan=None):
        plan = plan or self.plan(); now = datetime.now(timezone.utc)
        return dict(owner_authorized=True, task_id="SYNTHETIC_TASK", task_blob="1" * 40,
                    source_parent=self.pins["source_parent"], plan_sha256=plan["sha256"], actions=["prepare", "execute"],
                    runtime_batches=1, not_before=(now - timedelta(minutes=1)).isoformat(), expires_at=(now + timedelta(minutes=5)).isoformat())

    def rejects(self, code, action):
        with self.assertRaises(core.Rejected) as error: action()
        self.assertEqual(code, error.exception.code)

    def test_default_inspect_has_no_writes_or_process(self):
        before = list(self.root.rglob("*")); out = io.StringIO()
        self.assertEqual(0, entry.main([], out))
        self.assertIn("EXECUTE_DISABLED", out.getvalue())
        self.assertIn("CONTRACT_SOURCE_HASH_MALFORMED", out.getvalue())
        self.assertEqual(before, list(self.root.rglob("*")))

    def test_strict_contract_and_no_reference_hash_substitution(self):
        self.rejects("CONTRACT_SOURCE_HASH_MALFORMED", lambda: core.validate_pins(LOCKS))

    def test_exact_diff_and_target(self):
        self.assertEqual(b"after\n", core.reproduce(ORIGINAL, PATCH, self.pins))

    def test_raw_crlf_diff_rejected(self):
        self.rejects("PATCH_DIFF_HASH_MISMATCH", lambda: core.reproduce(ORIGINAL, PATCH.replace(b"\n", b"\r\n"), self.pins))

    def test_wrong_source(self):
        self.rejects("SOURCE_HASH_MISMATCH", lambda: core.reproduce(b"other", PATCH, self.pins))

    def test_wrong_target(self):
        self.pins["hook_target_sha256"] = "0" * 64
        self.rejects("PATCH_TARGET_HASH_MISMATCH", lambda: core.reproduce(ORIGINAL, PATCH, self.pins))

    def test_missing_or_multiple_hook_diff(self):
        self.rejects("PATCH_FORMAT_REJECTED", lambda: core.apply_unified(ORIGINAL, b"not a diff"))
        self.rejects("PATCH_EXTRA_FILE_OR_MARKER", lambda: core.apply_unified(ORIGINAL, PATCH + b"--- extra\n"))

    def test_context_and_range_mismatch(self):
        self.rejects("PATCH_CONTEXT_MISMATCH", lambda: core.apply_unified(b"unknown\n", PATCH))
        self.rejects("PATCH_NEW_RANGE", lambda: core.apply_unified(ORIGINAL, PATCH.replace(b"+1", b"+2")))

    def test_plan_only_does_not_create_target(self):
        p = self.plan(); self.assertEqual("EXECUTE_DISABLED", p["execute_default"]); self.assertFalse(self.target.exists())

    def test_source_hash_and_version_mismatch(self):
        artifact = self.config["artifacts"][0]; Path(artifact["source"]).write_bytes(b"changed")
        self.rejects("SOURCE_HASH_MISMATCH", self.plan)

    def test_version_mismatch(self):
        self.pins["flutter"] = "3.42.0"
        self.rejects("VERSION_MISMATCH", self.plan)

    def test_absolute_upward_and_windows_names(self):
        for value in ["/absolute", "../up", "a/../up", "a\\b", "a:stream", "NUL", "a.", "a "]:
            with self.assertRaises(core.Rejected): core.relative_path(value)

    def test_target_must_be_new_and_owned(self):
        self.config["target"] = str(self.inputs / "old")
        self.rejects("TARGET_NOT_TASK_OWNED", self.plan)

    def test_old_path_crossover(self):
        self.config["owned_parent"] = str(self.root); self.config["target"] = str(self.inputs / "new")
        self.rejects("OLD_PATH_CROSSOVER", self.plan)

    def test_hardlink_rejected(self):
        source = Path(self.config["artifacts"][0]["source"]); os.link(source, self.inputs / "alias")
        self.rejects("HARDLINK_REJECTED", self.plan)

    def test_link_detection_with_synthetic_lstat(self):
        # No real symlink privilege or Windows policy change is requested.
        from unittest.mock import patch
        real = Path.lstat
        source = Path(self.config["artifacts"][0]["source"])
        def fake(p, *args, **kwargs):
            info = real(p, *args, **kwargs)
            if p == source:
                class Reparse:
                    st_mode = info.st_mode
                    st_file_attributes = 0x400
                    st_nlink = 1
                return Reparse()
            return info
        with patch.object(Path, "lstat", fake): self.rejects("LINK_OR_REPARSE_REJECTED", self.plan)

    def test_dependency_escaping_target(self):
        role = next(x for x in self.config["artifacts"] if x["role"] == "app_resolver")
        data = b'{"packages":[{"name":"bad","rootUri":"../../../../../../outside"}]}'
        Path(role["source"]).write_bytes(data); role["sha256"] = core.digest(data)
        self.rejects("DEPENDENCY_PATH_OUTSIDE_TARGET", self.plan)

    def test_source_tree_mismatch(self):
        self.pins["source_apps_tree"] = "0" * 40
        self.rejects("SOURCE_APP_TREE_MISMATCH", self.plan)

    def test_nonexpected_hook_missing(self):
        self.config["artifacts"] = [x for x in self.config["artifacts"] if x["role"] != "hook_original"]
        self.rejects("REQUIRED_ROLE_MISSING_hook_original", self.plan)

    def test_expired_space_budget(self):
        self.config["max_allocated"] = 1
        self.rejects("SPACE_BUDGET_EXPIRED", self.plan)

    def test_unauthorized_and_closed_runtime(self):
        self.rejects("OWNER_AUTHORIZATION_REQUIRED", lambda: core.prepare(self.config, None, self.pins))
        grant = self.grant(); grant["task_id"] = LOCKS["closed_task_ids"][0]
        self.rejects("CLOSED_TASK_BUDGET", lambda: core.prepare(self.config, grant, self.pins))

    def test_expired_grant(self):
        grant = self.grant(); grant["expires_at"] = (datetime.now(timezone.utc) - timedelta(days=1)).isoformat()
        self.rejects("GRANT_EXPIRED", lambda: core.prepare(self.config, grant, self.pins))

    def test_prepare_recover_and_no_duplicate_copy(self):
        result = core.prepare(self.config, self.grant(), self.pins)
        self.assertEqual("PREPARED_EXECUTE_DISABLED", result["state"])
        plan, _ = core.recover(self.target); self.assertEqual(self.plan_hash_from_file(), plan["sha256"])
        self.rejects("TARGET_EXISTS_RECOVER_LEDGER", lambda: core.prepare(self.config, self.grant(plan), self.pins))

    def test_copied_prepared_root_rejected(self):
        import shutil
        core.prepare(self.config, self.grant(), self.pins)
        copied = self.outputs / "copied"
        shutil.copytree(self.target, copied)
        self.rejects("PREPARED_ROOT_MOVED_OR_COPIED", lambda: core.recover(copied))

    def test_initial_task_identity_rejected(self):
        core.prepare(self.config, self.grant(), self.pins)
        ledger = core.Ledger(self.target)
        rows = ledger.read(); rows[0]["task_id"] = "OTHER_TASK"
        previous = "0" * 64
        for row in rows:
            row.pop("hash"); row["prev"] = previous
            row["hash"] = core.digest(core.canonical_json(row)); previous = row["hash"]
        ledger.path.write_bytes(b"".join(core.canonical_json(row) + b"\n" for row in rows))
        self.rejects("LEDGER_TASK_ID_MISMATCH", lambda: core.recover(self.target))

    def test_unc_and_device_rejected_before_filesystem(self):
        from unittest.mock import patch
        with patch.object(Path, "exists", side_effect=AssertionError("filesystem touched")):
            for value in ("//server/share/file", "\\\\server\\share", "\\\\?\\UNC\\server\\share", "\\\\.\\device"):
                self.rejects("NETWORK_OR_DEVICE_PATH_REJECTED", lambda: core.private_path(value))

    def test_cli_sets_no_bytecode_before_tool_import(self):
        tree = ast.parse(Path(__file__).with_name("entry.py").read_text(encoding="utf-8"))
        guard = next(i for i, n in enumerate(tree.body) if isinstance(n, ast.Assign)
                     and any(isinstance(t, ast.Attribute) and t.attr == "dont_write_bytecode" for t in n.targets))
        imports = [i for i, n in enumerate(tree.body) if isinstance(n, ast.ImportFrom) and n.module == "core"]
        self.assertTrue(imports and all(guard < i for i in imports))

    def test_cli_unc_config_rejected_before_read(self):
        from unittest.mock import patch
        out = io.StringIO()
        real = Path.read_bytes
        def read(path):
            if str(path).startswith("\\\\"):
                self.fail("network read reached")
            return real(path)
        with patch.object(Path, "read_bytes", read):
            self.assertEqual(2, entry.main(["inspect", "--config", "\\\\server\\share\\config.json"], out))
        self.assertIn("NETWORK_OR_DEVICE_PATH_REJECTED", out.getvalue())

    def test_missing_or_malformed_lock_receipt(self):
        from unittest.mock import patch
        for effect in (OSError("synthetic missing"), None):
            out = io.StringIO()
            with patch.object(Path, "read_bytes", side_effect=effect, return_value=b"not-json"):
                self.assertEqual(2, entry.main([], out))
            self.assertIn("INPUT_OR_RECEIPT_INVALID", out.getvalue())

    def plan_hash_from_file(self):
        return json.loads((self.target / "prepared.json").read_bytes())["sha256"]

    def test_broken_and_truncated_ledger(self):
        core.prepare(self.config, self.grant(), self.pins)
        ledger = self.target / "execution_ledger.jsonl"; original = ledger.read_bytes()
        ledger.write_bytes(original[:-1]); self.rejects("LEDGER_TRUNCATED", lambda: core.recover(self.target))
        ledger.write_bytes(original.replace(b"INITIALIZED", b"CHANGED")); self.rejects("LEDGER_CHAIN_BROKEN", lambda: core.recover(self.target))

    def test_uncertain_start_consumed_and_not_retried(self):
        core.prepare(self.config, self.grant(), self.pins)
        core.Ledger(self.target).append("RUNTIME_PREPARE", operation="uncertain")
        self.rejects("UNCERTAIN_RUNTIME_CONSUMED_NO_RETRY", lambda: core.recover(self.target))

    def test_patch_residue_or_prepared_file_change(self):
        core.prepare(self.config, self.grant(), self.pins)
        (self.target / self.config["artifacts"][0]["relative"]).write_bytes(b"residue")
        self.rejects("PREPARED_ARTIFACT_CHANGED", lambda: core.recover(self.target))

    def test_shell_batch_and_parameter_injection_rejected(self):
        dart = self.inputs / "dart.exe"; dart.write_bytes(b"inert")
        cwd = self.inputs
        for exe in [self.inputs / "cmd.exe", self.inputs / "tool.cmd", self.inputs / "unknown.exe"]:
            exe.write_bytes(b"inert")
            self.rejects("SHELL_OR_UNKNOWN_EXECUTABLE", lambda: runtime.hook_arguments(exe, [], cwd, self.root, dart))
        self.rejects("ARGUMENT_PATTERN_REJECTED", lambda: runtime.hook_arguments(dart, ["/c", "echo"], cwd, self.root, dart))
        self.rejects("ARGUMENT_OUTSIDE_TASK", lambda: runtime.hook_arguments(dart, ["compile", "kernel", "--packages=" + str(dart), "--output=" + str(self.root.parent / "outside"), "--depfile=" + str(dart), str(dart)], cwd, self.root, dart))

    def test_fake_hook_positive_arguments_and_env_case(self):
        dart = self.inputs / "dart.exe"; dart.write_bytes(b"inert")
        args = ["compile", "kernel", "--packages=" + str(dart), "--output=" + str(self.inputs / "out"), "--depfile=" + str(self.inputs / "dep"), str(dart)]
        self.assertEqual(6, len(runtime.hook_arguments(dart, args, self.inputs, self.root, dart)))
        env = runtime.private_environment(self.root, "OS_READ_HOST")
        for value in env.values():
            if isinstance(value, str) and value.startswith(str(self.root)) and ";" not in value:
                Path(value).mkdir(parents=True, exist_ok=True)
        for value in env["PATH"].split(";"): Path(value).mkdir(parents=True, exist_ok=True)
        env["temp"] = str(self.inputs)
        self.rejects("DUPLICATE_ENVIRONMENT_KEY", lambda: runtime.normalize_environment(env, self.root))

    def test_static_no_subprocess_in_core_or_cli(self):
        for name in ["core.py", "entry.py"]:
            tree = ast.parse(Path(__file__).with_name(name).read_text(encoding="utf-8"))
            self.assertFalse(any(isinstance(n, ast.Call) and isinstance(n.func, ast.Attribute) and n.func.attr in ("Popen", "system", "startfile", "run") for n in ast.walk(tree)))

    def test_execute_needs_new_grant_and_runtime_proof(self):
        core.prepare(self.config, self.grant(), self.pins)
        plan, _ = core.recover(self.target); calls = []
        def fake(*args): calls.append(args); self.fail("Unauthorised launcher call")
        self.rejects("OWNER_AUTHORIZATION_REQUIRED", lambda: runtime.execute(self.target, None, self.pins, launcher=fake))
        self.rejects("RUNTIME_QUALIFICATION_REQUIRED", lambda: runtime.execute(self.target, self.grant(plan), self.pins, launcher=fake))
        self.assertEqual([], calls)

    def qualified_fake_grant(self):
        core.prepare(self.config, self.grant(), self.pins)
        plan, _ = core.recover(self.target); grant = self.grant(plan)
        proof = self.target / "SYNTHETIC-qualification.json"
        data = core.canonical_json(dict(plan_sha256=plan["sha256"], write_closure_qualified=True,
                                        process_guard_qualified=True, new_owner_scope_verified=True))
        proof.write_bytes(data)
        grant.update(runtime_qualification_file=str(proof), runtime_qualification_sha256=core.digest(data))
        return grant

    def test_fake_exit_propagates_and_consumes_budget(self):
        grant = self.qualified_fake_grant(); calls = []
        def fake(command, *args):
            calls.append(command)
            self.assertEqual("dart.exe", Path(command[0]).name)
            self.assertIn("--no-pub", command)
            return dict(exit=7, stdout_sha256="0" * 64, stderr_sha256="1" * 64, classification="SYNTHETIC_FAKE_ONLY")
        result = runtime.execute(self.target, grant, self.pins, launcher=fake)
        self.assertEqual(7, result["exit"]); self.assertEqual(0, result["remaining"])
        self.rejects("RUNTIME_BUDGET_EXHAUSTED", lambda: runtime.execute(self.target, grant, self.pins, launcher=fake))
        self.assertEqual(1, len(calls))

    def test_fake_uncertain_launch_cannot_refund_or_restart(self):
        grant = self.qualified_fake_grant(); calls = []
        def fake(*args):
            calls.append(1)
            raise RuntimeError("synthetic failure, no OS process")
        with self.assertRaises(RuntimeError): runtime.execute(self.target, grant, self.pins, launcher=fake)
        self.rejects("UNCERTAIN_RUNTIME_CONSUMED_NO_RETRY", lambda: runtime.execute(self.target, grant, self.pins, launcher=fake))
        self.assertEqual([1], calls)


if __name__ == "__main__":
    unittest.main()
