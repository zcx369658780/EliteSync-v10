"""Offline nonproduction CLI. Default inspect is read-only and execute is closed."""
import sys
sys.dont_write_bytecode = True
import argparse
import json
from pathlib import Path

from core import Rejected, inspect_plan, prepare, private_path, recover, validate_pins


def main(argv=None, output=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["inspect", "plan", "prepare", "recover", "execute"], nargs="?", default="inspect")
    parser.add_argument("--config")
    parser.add_argument("--grant")
    parser.add_argument("--root")
    parser.add_argument("--action", choices=["widget", "analyze"], default="widget")
    args = parser.parse_args(argv)
    output = output or sys.stdout
    try:
        pins = json.loads(Path(__file__).with_name("locks.json").read_bytes())
        if args.command in ("inspect", "plan") and not args.config:
            problems = []
            try:
                validate_pins(pins)
            except Rejected as error:
                problems.append(error.code)
            result = dict(state="INSPECT_ONLY_OR_PATCH_INPUT_REQUIRED", default="DRY_RUN_ONLY", execute="EXECUTE_DISABLED",
                          diagnostics=problems, private_patch_source="LOCAL_ONLY_INPUT_REQUIRED", versions={k: pins[k] for k in ("flutter", "dart", "hooks_runner")})
        elif args.command == "recover":
            plan, entries = recover(args.root)
            result = dict(state="RECOVERED_NO_LAUNCH", plan_sha256=plan["sha256"], entries=len(entries))
        else:
            config = json.loads(private_path(args.config).read_bytes()) if args.config else None
            if args.command in ("inspect", "plan"):
                plan, _ = inspect_plan(config, pins)
                result = dict(state="PLAN_ONLY", plan_sha256=plan["sha256"], logical_bytes=plan["estimated_logical"], execute="EXECUTE_DISABLED")
            elif args.command == "prepare":
                grant = json.loads(private_path(args.grant).read_bytes()) if args.grant else None
                result = prepare(config, grant, pins)
            else:
                # Runtime import has no launch side effect; no runtime API called in this task.
                from runtime import execute
                grant = json.loads(private_path(args.grant).read_bytes()) if args.grant else None
                result = execute(args.root, grant, pins, args.action)
        output.write(json.dumps(result, ensure_ascii=True) + "\n")
        return 0
    except Rejected as error:
        output.write(json.dumps(dict(state="BLOCKED", code=error.code, execute="EXECUTE_DISABLED")) + "\n")
        return 2
    except (OSError, ValueError, KeyError, TypeError):
        output.write(json.dumps(dict(state="BLOCKED", code="INPUT_OR_RECEIPT_INVALID", execute="EXECUTE_DISABLED")) + "\n")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
