"""Run isolated real-MariaDB kernel probes; all outputs contain synthetic IDs only.

Suite/config files carry bearer credentials and MUST stay LOCAL_ONLY. No migration,
server start, grant, isolation change, cleanup, or global machine control is done.
"""
import argparse
import json
import pathlib
import subprocess
import time

HERE = pathlib.Path(__file__).resolve().parent


def write(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def wait_file(path, process, seconds=40):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
        if path.exists():
            return read(path)
        if process.poll() is not None:
            raise RuntimeError(f"worker exited {process.returncode} before {path.name}")
        time.sleep(0.02)
    raise RuntimeError(f"timeout waiting for {path.name}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--php", required=True, help="Absolute PHP executable")
    parser.add_argument("--prepend", type=pathlib.Path, help="LOCAL_ONLY bootstrap loading exact original controllers, baseline only")
    parser.add_argument("--suite", required=True, type=pathlib.Path)
    parser.add_argument("--observer-config", required=True, type=pathlib.Path)
    parser.add_argument("--output", required=True, type=pathlib.Path)
    args = parser.parse_args()
    # Refuse reuse rather than overwrite raw failure evidence.
    args.output.mkdir(parents=True, exist_ok=False)
    observer = read(args.observer_config)
    suite = read(args.suite)
    results = []
    for case in suite["cases"]:
        folder = args.output / case["label"]
        folder.mkdir()
        config_path = folder / "config.LOCAL_ONLY.json"
        write(config_path, {"case": case, "work_dir": str(folder), **observer})
        processes = []
        streams = []

        def start(command):
            stdout = (folder / f"{command}.stdout.txt").open("wb")
            stderr = (folder / f"{command}.stderr.txt").open("wb")
            streams.extend([stdout, stderr])
            prefix = [args.php]
            if args.prepend:
                prefix += ["-d", "auto_prepend_file=" + str(args.prepend.resolve(strict=True))]
            p = subprocess.Popen(prefix + [str(HERE / "worker.php"), command, str(config_path)], stdout=stdout, stderr=stderr)
            processes.append((command, p))
            return p

        record = {"label": case["label"], "mode": case["mode"], "action": case["action"], "revoke": case["revoke"]}
        try:
            if case["mode"] == "race":
                revoker = start("revoke")
                wait_file(folder / "revoker_user_locks_held.json", revoker)
                reader = start("reader")
                wait_file(folder / "first_target_read.json", reader)
                wait_file(folder / "reader_user_lock_attempt.json", reader)
                reader_id = read(folder / "reader_started.json")["connection_id"]
                revoker_id = read(folder / "revoke_started.json")["connection_id"]
                deadline = time.monotonic() + 25
                observed = None
                while time.monotonic() < deadline:
                    query = subprocess.run([args.php, str(HERE / "worker.php"), "observe", str(config_path)], capture_output=True, timeout=10)
                    if query.returncode:
                        (folder / "observer.stderr.txt").write_bytes(query.stderr)
                        raise RuntimeError(f"observer exit {query.returncode}")
                    rows = json.loads(query.stdout)
                    matched = [r for r in rows if int(r["waiting_connection"]) == reader_id and int(r["blocking_connection"]) == revoker_id]
                    if matched:
                        observed = {"wall_time": time.time(), "rows": matched}
                        break
                    if reader.poll() is not None:
                        raise RuntimeError("reader ended without observed user-lock wait")
                    time.sleep(0.03)
                if observed is None:
                    raise RuntimeError("no exact reader-to-revoker INNODB_LOCK_WAITS row")
                write(folder / "lock_wait_observed.json", observed)
                # Only release after independent server lock-wait evidence exists.
                (folder / "allow_revoke").write_text("observed\n", encoding="ascii")
                wait_file(folder / "revocation_committed.json", revoker)
            elif case["mode"] == "serial":
                revoker = start("revoke")
                wait_file(folder / "revocation_committed.json", revoker)
                if revoker.wait(timeout=10) != 0:
                    raise RuntimeError("serial revoker failed")
                reader = start("reader")
            else:
                reader = start("reader")
            result = wait_file(folder / "reader_completed.json", reader)
            for command, process in processes:
                if process.wait(timeout=10) != 0:
                    raise RuntimeError(f"{command} nonzero exit")
            response = result["response"]
            reader_settings = read(folder / "reader_started.json")
            rr_verified = reader_settings["session_isolation"].upper().replace("_", "-") == "REPEATABLE-READ"
            denied = response["status"] in (403, 404) and not response["private_body_returned"] and not response["private_media_returned"]
            unchanged = result["before"] == result["after"]
            persisted = result["persisted_authorization"]
            live_post = persisted["transaction_level"] == 0 and persisted["post_exists"] and persisted["post_is_deleted"] is False
            if case["revoke"] == "audience":
                committed_revocation = live_post and persisted["post_audience"] == "SELF"
            elif case["revoke"] == "unfriend":
                committed_revocation = live_post and persisted["friendship_state"] == "REMOVED"
            elif case["revoke"] == "block":
                committed_revocation = live_post and persisted["owner_blocks_viewer"] and persisted["friendship_state"] == "REVOKED"
            else:
                committed_revocation = False
            if case["mode"] == "positive":
                success = response["status"] == 200 and live_post and persisted["post_audience"] == "FRIENDS" and persisted["friendship_state"] == "ACTIVE" and not persisted["owner_blocks_viewer"] and not persisted["viewer_blocks_owner"]
                if case["action"] == "media":
                    success = success and response["private_media_returned"] and unchanged
                else:
                    expected_like = 1 if case["action"] == "like" else 0
                    success = success and response["private_body_returned"] and result["after"]["like_count"] == expected_like
                    success = success and len(result["after"]["events"]) == len(result["before"]["events"]) + 1
                    expected_notices = 1 if case["action"] == "like" else 0
                    success = success and len(result["after"]["notifications"]) == len(result["before"]["notifications"]) + expected_notices
            else:
                success = denied and unchanged and committed_revocation
            record.update({"pass": success and rr_verified, "repeatable_read_verified": rr_verified, "reader_settings": reader_settings, "denied": denied, "side_effects_unchanged": unchanged, "committed_revocation_verified": committed_revocation, **result})
            if case["mode"] == "race":
                first = read(folder / "first_target_read.json")
                attempt = read(folder / "reader_user_lock_attempt.json")
                written = read(folder / "revocation_written.json")
                committed = read(folder / "revocation_committed.json")
                acquired = read(folder / "reader_user_locks_acquired.json")
                # Commit acknowledgment can race with reader wakeup; the server lock
                # handoff plus persisted revoked state is stronger than wall clock order.
                record["barrier"] = {"first_read": first, "lock_attempt": attempt, "observed_wait": observed,
                    "revocation_written": written, "revocation_committed_ack": committed, "reader_acquired": acquired}
                record["barrier_order_pass"] = first["wall_time"] <= attempt["wall_time"] <= observed["wall_time"] <= written["wall_time"] <= acquired["wall_time"]
                record["pass"] = record["pass"] and record["barrier_order_pass"]
        except Exception as exc:
            record.update({"pass": False, "harness_error": str(exc)})
        finally:
            for command, process in processes:
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()
                record.setdefault("exit_codes", {})[command] = process.returncode
            for stream in streams:
                stream.close()
        results.append(record)
        write(folder / "result.json", record)
        print(json.dumps({"label": case["label"], "pass": record["pass"], "exit_codes": record.get("exit_codes"), "harness_error": record.get("harness_error")}), flush=True)
    summary = {"total": len(results), "passed": sum(r["pass"] for r in results), "cases": results}
    write(args.output / "summary.json", summary)
    return 0 if summary["passed"] == summary["total"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
