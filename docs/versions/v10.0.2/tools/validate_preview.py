"""Same-invocation PHP -> fresh bytes -> unchanged Dart parser -> preview tests.

No package acquisition, services, .env, devices or production credentials.
Exclusive run labels keep untouched receipts even if an implementation fails.
"""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[4]
EVIDENCE = ROOT / "docs/versions/v10.0.2/evidence"
APP = ROOT / "apps/flutter_elitesync_module"
PLAN = "c96b3582243067d8acf572405d8a4eb908b18da3"
PARENT = "be070a771114052b2f6e7796636cd1a186502988"
PHP = r"C:\tools\php85\php.exe"
FLUTTER = r"D:\flutter\bin\flutter.bat"
WIDGET = "apps/flutter_elitesync_module/lib/features/qualification_diagnostics/presentation/widgets/qualification_diagnostic_preview.dart"
TEST = "apps/flutter_elitesync_module/test/features/qualification_diagnostics/qualification_diagnostic_preview_test.dart"


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main():
    args = argparse.ArgumentParser()
    args.add_argument("--label", required=True)
    label = args.parse_args().label
    assert re.fullmatch(r"[a-z0-9-]+", label)
    run = EVIDENCE / label
    run.mkdir(exist_ok=False)
    env = {k: v for k, v in os.environ.items() if k.upper() in {
        "PATH", "SYSTEMROOT", "WINDIR", "COMSPEC", "TEMP", "TMP", "USERPROFILE",
        "LOCALAPPDATA", "APPDATA", "HOMEDRIVE", "HOMEPATH", "PATHEXT",
        "PROGRAMFILES", "PROGRAMFILES(X86)", "PROGRAMDATA", "PROCESSOR_ARCHITECTURE",
    }}
    env.update({"CI": "true", "FLUTTER_SUPPRESS_ANALYTICS": "true",
                "DART_SUPPRESS_ANALYTICS": "true", "GIT_OPTIONAL_LOCKS": "0"})
    assert not (ROOT / "services/backend-laravel/.env").exists()
    identities = json.loads((EVIDENCE / "source-identities.json").read_text(encoding="utf-8"))
    inputs = {x["path"]: sha(ROOT / x["path"]) for x in identities["files"]}
    assert all(inputs[x["path"]] == x["checkout_sha256"] for x in identities["files"])
    inputs.update({p: sha(ROOT / p) for p in [WIDGET, TEST, Path(__file__).relative_to(ROOT).as_posix()]})
    summary = {"label": label, "plan_commit": PLAN, "plan_blob": "cdb88dba4585755fafd08b30fc025a019dd39a91",
               "code_parent": PARENT, "inputs": inputs, "steps": [],
               "started_utc": datetime.datetime.now(datetime.timezone.utc).isoformat()}
    save(run / "summary.json", summary)

    def execute(name, argv, cwd, out_name=None):
        stdout = run / (out_name or name + ".stdout.txt")
        stderr = run / (name + ".stderr.txt")
        receipt = {"argv": argv, "cwd": str(cwd),
                   "started_utc": datetime.datetime.now(datetime.timezone.utc).isoformat()}
        save(run / (name + ".receipt.json"), receipt)
        started = time.monotonic()
        with stdout.open("wb") as out, stderr.open("wb") as err:
            result = subprocess.run(argv, cwd=cwd, env=env, stdout=out, stderr=err)
        receipt.update({"exit_code": result.returncode, "elapsed_seconds": round(time.monotonic() - started, 3),
                        "completed_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                        "stdout_sha256": sha(stdout), "stderr_sha256": sha(stderr)})
        save(run / (name + ".receipt.json"), receipt)
        summary["steps"].append({"name": name, **receipt})
        save(run / "summary.json", summary)
        print(json.dumps({"step": name, "exit": result.returncode}), flush=True)
        return result.returncode, stdout

    execute("php-version", [PHP, "-n", "--version"], ROOT)
    exporter = ROOT / "services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php"
    export_exit, fixture = execute("php-export", [PHP, "-n", str(exporter)], ROOT, "diagnostic.json")
    summary["php_export_exit"] = export_exit
    if export_exit == 0:
        data = json.loads(fixture.read_text(encoding="utf-8"))
        producer = json.loads((run / "php-export.stderr.txt").read_text(encoding="utf-8"))
        summary.update({"fixture_sha256": sha(fixture), "fixture_bytes": fixture.stat().st_size,
                        "php_scenarios": producer["scenarios_passed"], "php_checks": producer["checks_passed"],
                        "producer_digest_matches": producer["exported_sha256"] == sha(fixture)
                            and producer["exported_bytes"] == fixture.stat().st_size and producer["status"] == "PASS",
                        "scenario_index": [{k: r[k] for k in ["scenario_id", "context_id", "diagnostic_outcome", "reason_codes"]}
                                           for r in data["records"]]})
        flutter_exit, out = execute("flutter-consumers", [FLUTTER, "--no-version-check", "--suppress-analytics",
            "test", "--no-pub", "--reporter=expanded",
            "--dart-define=QUALIFICATION_DIAGNOSTIC_FIXTURE=" + str(fixture),
            "test/features/qualification_diagnostics/qualification_diagnostic_test.dart",
            "test/features/qualification_diagnostics/qualification_diagnostic_preview_test.dart"], APP)
        text = out.read_text(encoding="utf-8", errors="replace")
        parser_hashes = re.findall(r'QUALIFICATION_DIAGNOSTIC_INPUT_SHA256=([0-9a-f]{64})', text)
        widget_hashes = re.findall(r'WIDGET_DIAGNOSTIC_INPUT_SHA256=([0-9a-f]{64})', text)
        counts = re.findall(r'\+(\d+): All tests passed!', text)
        summary.update({"flutter_exit": flutter_exit, "parser_input_sha256": parser_hashes,
                        "widget_input_sha256": widget_hashes, "flutter_pass_count": counts,
                        "same_fresh_bytes": bool(parser_hashes and widget_hashes)
                            and set(parser_hashes + widget_hashes) == {sha(fixture)}})
    widget_source = (ROOT / WIDGET).read_text(encoding="utf-8")
    summary["debug_gate_source_check"] = "displayAllowed(debugBuild: kDebugMode, enabled: enabled)" in widget_source
    summary["non_debug_build_runtime"] = "NOT_RUN; static kDebugMode guard + executable pure gate truth table only"
    summary["be12_evidence"] = "ROUTE_AND_MIDDLEWARE_BLOB_IDENTITY_ONLY; runtime/Feature NOT_RUN_THIS_VERSION"
    summary["inputs_unchanged"] = all(sha(ROOT / p) == value for p, value in inputs.items())
    summary["completed_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    passed = (export_exit == 0 and summary.get("flutter_exit") == 0 and summary.get("producer_digest_matches")
              and summary.get("same_fresh_bytes") and summary["debug_gate_source_check"] and summary["inputs_unchanged"])
    summary["author_verification"] = "PASS" if passed else "FAIL"
    save(run / "summary.json", summary)
    print(json.dumps({k: summary.get(k) for k in ["author_verification", "php_scenarios", "php_checks",
                        "same_fresh_bytes", "flutter_pass_count"]}), flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
