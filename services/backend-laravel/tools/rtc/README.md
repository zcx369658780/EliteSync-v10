# Local development RTC gateway

This supervisor connects the existing LiveKit client to the current Laravel
`/api/v1/rtc-guard/{authorize,sweep,audit}` contract. It adapts the protocol code
from `docs/versions/v10.0.9`; it does not invoke historical launchers or their
filesystem request/reply bridge.

Build the supplied Dockerfile using an approved Python 3.11+ runtime and a pinned
official LiveKit image. Runtime credentials and configuration belong outside Git.

Required environment:

| Variable | Meaning |
| --- | --- |
| `LIVEKIT_API_KEY` / `LIVEKIT_API_SECRET` | Same private key pair configured in the owned SFU and Laravel |
| `V1009_GATEWAY_SECRET` | Independent credential for Laravel's internal RTC authority endpoints |
| `RTC_AUTHORITY_HOST` / `RTC_AUTHORITY_PORT` | Current development API, default `v1015-current-dev-db:8080` |

Mount the private SFU configuration at `/private/livekit-config-private.yaml`.
Bind its raw signal/API port 7880 to **container loopback**, publish only gateway
7883 to host loopback, and expose only the specifically required local media
ports. This gateway is a development integration, not a public TLS deployment.

Every join validates the signed token and current backend authority. The monitor
removes rooms excluded by the backend; uncertainty or removal failure kills its
own SFU child. The separate anonymous-pipe watchdog also kills that child if
successful monitor pulses stop for 3.5 seconds. It shares no HTTP or filesystem
authority with the monitor.

Focused protocol checks: `python -m unittest discover -s . -p test_rtc_gateway.py`.
These checks do not establish actual media-stop latency, AEC quality, or complete
RTC acceptance; those require the real APP/API/SFU chain.

## Development authority worker pool

`serve_development_api.py` runs the ordinary PHP server on 8080 with four
workers and reserves a separate PHP server on 8082 with two workers. Point
`RTC_AUTHORITY_PORT` at 8082 for this configuration. Keep 8082 private to the
owned development network. The authority router serves only POST requests to
the three existing guard routes, through the same Laravel kernel and guard.

The pool prevents ordinary API accept-queue contention from blocking authority
checks. CPU, database and lock contention remain shared dependencies. Monitor
failures report the phase and elapsed time without private request data. The
one-second response deadline and independent 3.5-second watchdog are retained.
