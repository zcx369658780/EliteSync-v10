"""Run the exact frozen eleven-file suite and retain untouched streams and input identities."""
import argparse, datetime, hashlib, json, pathlib, subprocess, time, xml.etree.ElementTree as ET, os
p=argparse.ArgumentParser(); p.add_argument("--label",required=True); a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[4]; svc=root/"services/backend-laravel"; ev=root/"docs/versions/v10.0.0/evidence"
intake=json.loads((ev/"source-intake.json").read_text()); tests=intake["test_names"]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
assert len(tests)==11 and len(set(tests))==11
assert not (svc/".env").exists(), "No .env is permitted in this isolated test worktree"
suite=ET.parse(svc/"phpunit.xml"); node=suite.getroot().find("testsuites"); node.clear()
selection=ET.SubElement(node,"testsuite",{"name":"FrozenV100Exact11"})
for name in tests: ET.SubElement(selection,"file").text="tests/Unit/"+name+".php"
suite.getroot().set("colors","false"); cfg=svc/"phpunit.v100.xml"; suite.write(cfg,encoding="utf-8",xml_declaration=True)
record={"label":a.label,"started_utc":datetime.datetime.now(datetime.timezone.utc).isoformat(),"cwd":"services/backend-laravel","code_parent":intake["code_parent"],"plan_commit":"8072ba51ad1dde2e3c3262a418af54531dcec7e0","plan_blob":"ae84a65e3636fa51a188c687154cb51856f58bf9","tests":tests,"inputs":[{"path":x["path"],"sha256":sha(root/x["path"])} for x in intake["files"]]+[{"path":cfg.relative_to(root).as_posix(),"sha256":sha(cfg)}]}
run=ev/a.label; run.mkdir(exist_ok=False)
cmd=[r"C:\tools\php85\php.exe","vendor/bin/phpunit","--configuration","phpunit.v100.xml","--do-not-cache-result","--colors=never","--display-deprecations","--display-phpunit-deprecations","--log-junit",str(run/"junit.xml")]
record["argv"]=cmd; (run/"receipt.json").write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")
env=os.environ.copy(); env.update({"APP_ENV":"testing","DB_CONNECTION":"sqlite","DB_DATABASE":":memory:","CACHE_STORE":"array","SESSION_DRIVER":"array","QUEUE_CONNECTION":"sync"})
started=time.monotonic()
with (run/"stdout.txt").open("wb") as out,(run/"stderr.txt").open("wb") as err:
    result=subprocess.run(cmd,cwd=svc,env=env,stdout=out,stderr=err)
record.update({"exit_code":result.returncode,"elapsed_seconds":round(time.monotonic()-started,3),"completed_utc":datetime.datetime.now(datetime.timezone.utc).isoformat(),"stdout_sha256":sha(run/"stdout.txt"),"stderr_sha256":sha(run/"stderr.txt")})
(run/"receipt.json").write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")
if (run/"junit.xml").exists() and (run/"junit.xml").stat().st_size:
    doc=ET.parse(run/"junit.xml").getroot()
    names={n.get("class") for n in doc.iter("testcase")}
    expected={"Tests\\Unit\\"+n for n in tests}
    record["coverage_files_exact"]=names==expected
    record["executed_classes"]=sorted(names)
    record["tests_executed"]=sum(1 for _ in doc.iter("testcase"))
    record["failures"]=sum(1 for _ in doc.iter("failure")); record["errors"]=sum(1 for _ in doc.iter("error")); record["skips"]=sum(1 for _ in doc.iter("skipped"))
else: record["coverage_files_exact"]=False
record["inputs_unchanged"]=all(sha(root/x["path"])==x["sha256"] for x in record["inputs"])
(run/"receipt.json").write_text(json.dumps(record,indent=2)+"\n",encoding="utf-8")
print(json.dumps({k:record.get(k) for k in ("label","exit_code","tests_executed","failures","errors","skips","coverage_files_exact","inputs_unchanged","elapsed_seconds")}))
raise SystemExit(result.returncode if result.returncode else (0 if record["coverage_files_exact"] and record["inputs_unchanged"] else 2))
