# Running-engine task evidence adapter

This is the reviewed source snapshot for V1015_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_20261030, attempt-0001, Task Blob a1cbc75afe406e3e05712c6c51fb63c86bad928d, sole Parent debe4a11d19f25179efef1d90d04e346980c2867. It is not a successor task or a general Docker management CLI.

The executed controller lived at the root of the task-owned LOCAL_ONLY directory, not this repository directory. `owned.py` binds the exact existing root and ledger FileID/volume, Task, Parent, attempt and monotonic start. No repository entry point creates a task, resets a budget or accepts a STOP ledger. After delivery, the execution root is sealed; do not copy its ledger, revive it or run these snapshots there.

- `supply.py`: HTTPS official-source transport with per-hop request and maximum-body reservation before I/O; failed/unknown reads keep their reservation. Raw bodies, auth and signed URLs remain LOCAL_ONLY.
- `oci.py`: official PHP/MariaDB index, platform, config, layer and diff-id verification; compressed-plus-expansion and archive space checks. Containerd import conversion is checked through exported original config and the entire diff-id chain.
- `engine.py`: pinned local endpoint and installed CLI identity; task resource targets and argument policy. It neither starts nor repairs Desktop/WSL. This is an application guard, not OS enforcement proof.
- `broker.php`/`broker.py` and `pump.py`: an internal metadata relay to the metered controller, with no external listener. Composer runs scripts/plugins disabled. Dist cache entries preserve Composer's native URL hash key; exact package refs and downloaded zip hashes are receipted.
- Dockerfile and php-build-meter.sh: offline PHP extension build, with a nonrefundable 30-process PHP reservation and an inner 30-process ceiling (observed 9).
- `http_e2e.py`, `http_phase1.py`, `http_phase2.py`, `http_relay.php`: source for actual HTTP assertions. The host driver atomically submits LOCAL_ONLY queue files; the PHP client in the API container uses curl to fixed `127.0.0.1:8081` with redirects/proxies disabled. No mock response producer is used. The intended host publish was unavailable on the internal Docker network, so the actual HTTP runs used container loopback without adding egress. The relay PHP file was staged under task storage; it is not a product route.

The submitted phase1 source consolidates the corrected required admin confirmation/revision form and the media fixture input. Original failed executions and the staged resume scripts remain LOCAL_ONLY. The task bootstrap selects `v1011_relationship` as its private local fixture media disk, authenticates the exact new schema/actor/server, checks all DB selectors and the entire source closure once per PHP request/CLI, and rechecks DB/environment/window at protected use points. Public index.php does not load this bootstrap. Its secret proof is deliberately not shipped.

Synthetic legacy-session fixtures use PHP serialize plus current encryption and current admin authorization. They prove this wire-format fixture's positive/negative behavior and restart continuity; they do not prove execution by a Laravel11 binary. Real provider Push, H264/206 without a qualified fixture, APP/device/RTC/AEC and physical 15/30 days are outside these receipts.

Do not execute these files automatically. Any future run needs a separately authorized task, root, ledger, source qualification, secrets and budgets; this snapshot grants none.
