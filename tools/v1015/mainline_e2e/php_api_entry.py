"""Future PHP API source entry. Default plan only; current R1 cannot execute it."""
import sys
sys.dont_write_bytecode=True
import json,os,argparse,time
from pathlib import Path
from contracts import *
from php_runtime import qualify_config,api_arguments,private_environment
from php_native import api
def main(argv=None):
    p=argparse.ArgumentParser(description=__doc__);p.add_argument("action",choices=("inspect","plan","execute"),default="inspect",nargs="?");p.add_argument("--config");p.add_argument("--grant");a=p.parse_args(argv)
    if a.action=="inspect":
        print(json.dumps(dict(state="STATIC_INPUT_REQUIRED",live="LIVE_MODULE_LOAD_NOT_RUN",api="NOT_RUN_GATE_CLOSED")));return 0
    c=json.loads(local(a.config).read_bytes());g=json.loads(local(a.grant).read_bytes());root=validate_authority(c,g);profile=qualify_config(c,g)
    router=local(c["api_router"],root);need(digest(router.read_bytes())==g["api_router_sha256"],"PHP_API_ROUTER_CHANGED")
    command=api_arguments(profile,root,router)
    if a.action=="plan":
        print(json.dumps(dict(state="STATIC_PRECONDITION_OK",live="LIVE_MODULE_LOAD_NOT_RUN",command=command,profile_sha256=profile["manifest_sha256"])));return 0
    need(type(g.get("api_max_seconds",3600)) is int and 0<g.get("api_max_seconds",3600)<=5400,"API_WINDOW_BUDGET_REQUIRED")
    need(type(g.get("php_api_launches")) is int and 0<g["php_api_launches"]<=2,"API_NEW_START_BUDGET_REQUIRED")
    ledger_file=root/"php_api_execution_ledger.jsonl";lock=root/".php-api-launch.lock";handle=os.open(lock,os.O_CREAT|os.O_EXCL|os.O_WRONLY);os.close(handle)
    process=None
    def log(event,**values):
        with ledger_file.open("ab",buffering=0) as f:f.write(canonical(dict(event=event,**values))+b"\n");os.fsync(f.fileno())
    try:
        rows=[json.loads(s) for s in ledger_file.read_bytes().splitlines()] if ledger_file.exists() else []
        need(not rows,"EXISTING_API_ATTEMPT_RECONCILIATION_REQUIRED")
        log("PREPARE_API",task_blob=g["task_blob"],profile_sha256=profile["manifest_sha256"],limit=g["php_api_launches"],command_sha256=digest(canonical(command)))
        context=dict(config=c,grant=g);path=root/"api-context-LOCAL_ONLY.json"
        with path.open("xb") as f:f.write(canonical(context));f.flush();os.fsync(f.fileno())
        env=private_environment(profile,root,os.environ.get("SystemRoot",""));env.update(ELITESYNC_MAINLINE_CONTEXT=str(path),ELITESYNC_MAINLINE_CONTEXT_SHA256=digest(path.read_bytes()),ELITESYNC_MAINLINE_TASK_ROOT=str(root))
        parent=local(root/"raw",root);parent.mkdir(exist_ok=True)
        local(parent/"api",root).mkdir(exist_ok=False)
        process=api(profile,command,env,root,log)
        deadline=time.monotonic()+min(g.get("api_max_seconds",3600),5400)
        while process.poll() is None:
            need(not process.qualification_failure_file.exists(),"API_QUALIFICATION_FAILED_STOP")
            need(time.monotonic()<deadline,"API_WINDOW_LIMIT");logical,allocated=measured_space(root);need(max(logical,allocated)+2097152<=c["max_bytes"],"API_SPACE_LIMIT");time.sleep(.2)
        log("API_ENDED",pid=process.pid,exit=process.returncode)
        return process.returncode
    finally:
        if process is not None and process.poll() is None:process.kill();process.wait();log("API_STOPPED",pid=process.pid,exit=process.returncode)
        lock.unlink()
if __name__=="__main__":
    try:raise SystemExit(main())
    except (Gate,ValueError,KeyError,OSError):
        print(json.dumps(dict(state="BLOCKED_OR_FAILED",actual_api="NOT_ACCEPTED")));raise SystemExit(2)
