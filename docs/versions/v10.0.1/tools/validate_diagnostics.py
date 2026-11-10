"""Bounded v10.0.1 verification; existing local tools only, no install or service.

Each label is exclusive. Raw streams survive failures. PHP freshly produces the
fixture consumed by Flutter in this same invocation; no canned fixture fallback.
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
import xml.etree.ElementTree as ET

PLAN = "f39ed2d41360b14637464937b36b5dfea945d29e"
PARENT = "4bebc8f394248e254c1368a06fbdee5d2c883301"
ROOT = Path(__file__).resolve().parents[4]
SERVICE = ROOT / "services/backend-laravel"
APP = ROOT / "apps/flutter_elitesync_module"
EVIDENCE = ROOT / "docs/versions/v10.0.1/evidence"
PHP = r"C:\tools\php85\php.exe"
FLUTTER = r"D:\flutter\bin\flutter.bat"
TESTS = [
    "ProductConnectionPersistenceApplicationAdapterTest",
    "ProductConnectionPersistenceFamilyTest",
    "ProductConnectionStateTransitionEvaluatorTest",
    "InMemoryLogicalPersistenceRepositoryContractTest",
    "SqliteInMemoryLogicalPersistenceAdapterTest",
    "PersistenceBoundaryApplicationInterfaceIntegrationContractTest",
    "MessagingConsentConversationLiveGateEvaluatorTest",
]


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--label", required=True)
    args = parser.parse_args()
    if not re.fullmatch(r"[a-z0-9-]+", args.label):
        raise ValueError("Unsafe run label")
    run = EVIDENCE / args.label
    run.mkdir(exist_ok=False)
    # No ambient credentials or production connection settings are inherited.
    env = {k: v for k, v in os.environ.items() if k.upper() in {
        "PATH", "SYSTEMROOT", "WINDIR", "COMSPEC", "TEMP", "TMP",
        "USERPROFILE", "LOCALAPPDATA", "APPDATA", "HOMEDRIVE", "HOMEPATH",
        "PROGRAMFILES", "PROGRAMFILES(X86)", "PROGRAMDATA", "PATHEXT",
    }}
    env.update({"APP_ENV": "testing", "DB_CONNECTION": "sqlite",
                "DB_DATABASE": ":memory:", "CACHE_STORE": "array",
                "SESSION_DRIVER": "array", "QUEUE_CONNECTION": "sync",
                "FLUTTER_SUPPRESS_ANALYTICS": "true", "CI": "true",
                "DART_SUPPRESS_ANALYTICS": "true", "GIT_OPTIONAL_LOCKS": "0"})
    assert not (SERVICE / ".env").exists(), "Real .env must not be present"
    assert not (SERVICE / "bootstrap/cache/config.php").exists(), "No cached production config"
    intake = json.loads((EVIDENCE / "source-intake.json").read_text())
    assert all(digest(ROOT / x["path"]) == x["sha256"] for x in intake["files"])
    source_inputs = {p.relative_to(ROOT).as_posix(): digest(p) for p in [
        SERVICE / "tests/Unit/EliteSync/ConversationQualification/DiagnosticScenarioFactory.php",
        SERVICE / "tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php",
        APP / "lib/features/qualification_diagnostics/domain/qualification_diagnostic.dart",
        APP / "test/features/qualification_diagnostics/qualification_diagnostic_test.dart",
        Path(__file__),
    ]}
    source_inputs.update({x["path"]: x["sha256"] for x in intake["files"]})
    source_inputs.update({"services/backend-laravel/tests/Unit/" + n + ".php":
                         digest(SERVICE / "tests/Unit" / (n + ".php")) for n in TESTS})
    protected = ["services/backend-laravel/routes/api.php",
                 "services/backend-laravel/app/Http/Middleware/DenyUnverifiedMessagingLiveAccess.php"]
    source_inputs.update({p: digest(ROOT / p) for p in protected})
    summary = {"plan_commit": PLAN, "code_parent": PARENT, "label": args.label,
               "started_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
               "inputs": source_inputs, "steps": [], "application_tests_before_this_run": "NOT_ASSUMED"}
    write_json(run / "summary.json", summary)

    def execute(name, command, cwd, stdout_name=None):
        out = run / (stdout_name or (name + ".stdout.txt"))
        err = run / (name + ".stderr.txt")
        receipt = {"name": name, "argv": command, "cwd": str(cwd),
                   "started_utc": datetime.datetime.now(datetime.timezone.utc).isoformat()}
        write_json(run / (name + ".receipt.json"), receipt)
        started = time.monotonic()
        with out.open("wb") as stdout, err.open("wb") as stderr:
            result = subprocess.run(command, cwd=cwd, env=env, stdout=stdout, stderr=stderr)
        receipt.update({"exit_code": result.returncode,
                        "elapsed_seconds": round(time.monotonic() - started, 3),
                        "stdout_sha256": digest(out), "stderr_sha256": digest(err),
                        "completed_utc": datetime.datetime.now(datetime.timezone.utc).isoformat()})
        write_json(run / (name + ".receipt.json"), receipt)
        summary["steps"].append(receipt)
        write_json(run / "summary.json", summary)
        print(json.dumps({"step": name, "exit": result.returncode}), flush=True)
        return result.returncode, out

    # Explicit local extension set, with no php.ini or framework environment load.
    test_php = [PHP, "-n", "-d", r"extension_dir=C:\tools\php85\ext",
                "-d", "extension=mbstring", "-d", "extension=pdo_sqlite",
                "-d", "extension=sqlite3", "-d", "extension=fileinfo"]
    execute("php-version", [PHP, "-n", "--version"], ROOT)
    tree = ET.Element("phpunit", {"bootstrap": str(SERVICE / "vendor/autoload.php"),
                                 "colors": "false", "cacheResult": "false"})
    suites = ET.SubElement(tree, "testsuites")
    suite = ET.SubElement(suites, "testsuite", {"name": "V1001DirectDependencies"})
    for name in TESTS:
        ET.SubElement(suite, "file").text = str(SERVICE / "tests/Unit" / (name + ".php"))
    php_env = ET.SubElement(tree, "php")
    for key, value in {"APP_ENV": "testing", "DB_CONNECTION": "sqlite",
                       "DB_DATABASE": ":memory:", "CACHE_STORE": "array",
                       "SESSION_DRIVER": "array", "QUEUE_CONNECTION": "sync"}.items():
        ET.SubElement(php_env, "env", {"name": key, "value": value, "force": "true"})
    config = ROOT / "docs/versions/v10.0.1/phpunit.test-only.xml"
    ET.ElementTree(tree).write(config, encoding="utf-8", xml_declaration=True)
    source_inputs[config.relative_to(ROOT).as_posix()] = digest(config)
    code, php_output = execute("phpunit", test_php + ["vendor/bin/phpunit", "--configuration", str(config),
                          "--do-not-cache-result", "--display-phpunit-deprecations", "--colors=never",
                          "--log-junit", str(run / "junit.xml")], SERVICE)
    summary["phpunit_exit"] = code
    if (run / "junit.xml").exists():
        xml = ET.parse(run / "junit.xml")
        classes = {n.get("class") for n in xml.iter("testcase")}
        summary["phpunit"] = {"classes": sorted(classes),
            "exact_selected_classes": classes == {"Tests\\Unit\\" + n for n in TESTS},
            "tests": sum(1 for _ in xml.iter("testcase")),
            "failures": sum(1 for _ in xml.iter("failure")),
            "errors": sum(1 for _ in xml.iter("error")),
            "skips": sum(1 for _ in xml.iter("skipped"))}
        php_text = php_output.read_text(encoding="utf-8", errors="replace")
        summary["phpunit"]["assertions"] = re.findall(r'Assertions: (\d+)', php_text)
        summary["phpunit"]["retained_phpunit_deprecations"] = re.findall(r'PHPUnit Deprecations: (\d+)', php_text)
    # Pure negative guard: real middleware + real Request/JsonResponse, test-only
    # response factory; no Laravel app boot, controllers, DB, network or .env.
    guard = r'''function response() { return new class { function json($body,$status) {
        return new \Illuminate\Http\JsonResponse($body,$status); } }; }
    require 'vendor/autoload.php';
    require 'app/Http/Middleware/DenyUnverifiedMessagingLiveAccess.php';
    $paths=[['GET','/api/v1/messages'],['POST','/api/v1/messages'],
      ['POST','/api/v1/messages/read/fiction'],['GET','/api/v1/conversations'],
      ['POST','/api/v1/conversations'],['GET','/api/v1/conversations/fiction'],
      ['GET','/api/v1/conversation-peers/fiction'],['POST','/api/v1/messages']];
    $called=0;foreach($paths as [$method,$path]) {
      $request=\Illuminate\Http\Request::create($path,$method);
      $request->headers->set('X-Live-Gate-Allowed','true');
      $r=(new \App\Http\Middleware\DenyUnverifiedMessagingLiveAccess)->handle(
        $request,function()use(&$called){$called++;throw new \RuntimeException('CALLBACK_REACHED');});
      if($r->getStatusCode()!==404 || json_decode($r->getContent(),true)!==['message'=>'conversation unavailable'])
        throw new \RuntimeException('OPAQUE_404_REQUIRED');
      echo json_encode(['method'=>$method,'path'=>$path,'status'=>404,'downstream_called'=>$called])."\n";
    }if($called!==0)throw new \RuntimeException('DOWNSTREAM_CALLED');'''
    guard_code, _ = execute("pure-be12-guard", test_php + ["-r", guard], SERVICE)
    summary["be12_evidence_level"] = "PURE_MIDDLEWARE_RUNTIME_AND_ROUTING_BYTE_IDENTITY"
    summary["feature_route_regression"] = "NOT_RUN_NO_FRAMEWORK_DB_BOOTSTRAP"
    exporter = SERVICE / "tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php"
    php_code, fixture = execute("php-export", [PHP, "-n", str(exporter)], ROOT,
                                "diagnostic.json")
    summary["exporter_exit"] = php_code
    if php_code == 0:
        data = json.loads(fixture.read_text(encoding="utf-8"))
        summary["fixture_sha256"] = digest(fixture)
        producer_receipt = json.loads((run / "php-export.stderr.txt").read_text(encoding="utf-8"))
        summary["producer_receipt_matches_bytes"] = (
            producer_receipt["exported_sha256"] == summary["fixture_sha256"]
            and producer_receipt["exported_bytes"] == fixture.stat().st_size
            and producer_receipt["status"] == "PASS")
        summary["php_scenarios_passed"] = producer_receipt["scenarios_passed"]
        summary["php_checks_passed"] = producer_receipt["checks_passed"]
        summary["scenario_index"] = [{k: r[k] for k in
            ["scenario_id", "context_id", "diagnostic_outcome", "reason_codes"]} for r in data["records"]]
        code, output = execute("dart-consumer", [FLUTTER, "--no-version-check", "--suppress-analytics",
                     "test", "--no-pub", "--reporter=expanded",
                     "--dart-define=QUALIFICATION_DIAGNOSTIC_FIXTURE=" + str(fixture),
                     "test/features/qualification_diagnostics/qualification_diagnostic_test.dart"], APP)
        summary["dart_exit"] = code
        text = output.read_text(encoding="utf-8", errors="replace")
        hashes = re.findall(r'DIAGNOSTIC_INPUT_SHA256[=: ]+([0-9a-f]{64})', text)
        summary["dart_input_sha256"] = hashes
        summary["same_fresh_bytes"] = bool(hashes) and set(hashes) == {summary["fixture_sha256"]}
    summary["inputs_unchanged"] = all(digest(ROOT / p) == h for p, h in source_inputs.items())
    summary["completed_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    passed = (code == 0 and summary.get("dart_exit") == 0 and php_code == 0
              and summary.get("phpunit_exit") == 0 and guard_code == 0
              and summary.get("phpunit", {}).get("exact_selected_classes") is True
              and all(summary.get("phpunit", {}).get(k) == 0 for k in ["failures", "errors", "skips"])
              and summary.get("producer_receipt_matches_bytes") is True
              and summary.get("same_fresh_bytes") is True and summary["inputs_unchanged"])
    summary["author_verification"] = "PASS" if passed else "FAIL"
    write_json(run / "summary.json", summary)
    print(json.dumps({"author_verification": summary["author_verification"],
                      "same_fresh_bytes": summary.get("same_fresh_bytes"),
                      "phpunit": summary.get("phpunit")}), flush=True)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
