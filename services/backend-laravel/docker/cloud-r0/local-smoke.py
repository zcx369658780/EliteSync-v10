#!/usr/bin/env python3
"""Exercise only the disposable R0 fixture stack, without printing credentials."""
import argparse
import struct
import zlib
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import ssl
import subprocess
import time
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import HTTPSHandler, ProxyHandler, Request, build_opener
from uuid import uuid4

BASE = "https://127.0.0.1:18443"
PREFIX = "/api/v1"
NATAL = "/profile/natal"
def png_chunk(kind, raw):
    return struct.pack(">I", len(raw)) + kind + raw + struct.pack(">I", zlib.crc32(kind + raw))

PNG = (
    b"\x89PNG\r\n\x1a\n"
    + png_chunk(b"IHDR", struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0))
    + png_chunk(b"IDAT", zlib.compress(b"\x00\x14\x64\xa0"))
    + png_chunk(b"IEND", b"")
)

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("compose", type=Path)
parser.add_argument("mode", choices=("business", "natal", "missing", "recover"))
args = parser.parse_args()
compose = [
    "docker", "--host", "unix:///run/docker.sock", "compose", "--project-name",
    "elitesync-v2-cloud-r0", "--env-file", "/srv/r0/local.env", "-f", str(args.compose),
]
opener = build_opener(
    ProxyHandler({}), HTTPSHandler(context=ssl.create_default_context(cafile="/srv/r0/secrets/tls.crt"))
)


def require(condition, label):
    if not condition:
        raise RuntimeError(label)


def php(body):
    program = r"""<?php
    require '/opt/elitesync-r0/db-preflight.php';
    use App\Models\User;
    use Illuminate\Support\Facades\DB;
    if (config('app.url') !== 'https://127.0.0.1:18443'
        || ! config('security.enforce_https')
        || config('journey.test_issuer_enabled')
        || User::whereNull('synthetic_batch')->orWhere('synthetic_batch', '!=', 'cloud-r0-fictional-only')->exists()) {
        exit(2);
    }
    """ + body
    result = subprocess.run(
        compose + ["exec", "-T", "r0-app", "/usr/local/bin/elitesync-r0", "php"],
        input=program, text=True, encoding="utf-8", capture_output=True,
    )
    require(result.returncode == 0, f"fixture PHP exit={result.returncode}")
    lines = result.stdout.splitlines()
    require(json.loads(lines[0])["schema"] == "elitesync_v2_r0", "schema identity")
    return json.loads(lines[-1]) if len(lines) > 1 else None


def request(label, method, path, expected, token=None, payload=None, media=None):
    headers = {"Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = None
    if payload is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(payload).encode()
    if media:
        boundary = "R0" + uuid4().hex
        headers["Content-Type"] = f"multipart/form-data; boundary={boundary}"
        parts = [
            f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode()
            for name, value in media.items()
        ]
        image = (
            f'--{boundary}\r\nContent-Disposition: form-data; name="photo"; filename="fixture.png"\r\n'
            "Content-Type: image/png\r\n\r\n"
        ).encode() + PNG + f"\r\n--{boundary}--\r\n".encode()
        data = b"".join(parts) + image
    before = time.monotonic()
    try:
        response = opener.open(Request(BASE + PREFIX + path, data, headers, method=method), timeout=190)
    except HTTPError as error:
        response = error
    with response:
        content_type = response.headers.get_content_type()
        raw = response.read()
        parsed = json.loads(raw) if content_type == "application/json" else raw
        status = response.status
        timing = time.monotonic() - before
        print(f"{label} HTTP {status} {timing:.3f}s", flush=True)
        require(status in expected, f"{label}: HTTP {status}, expected {expected}")
        return status, parsed, response.headers


def seed():
    return php(r"""
    $password = bin2hex(random_bytes(24)).'A9';
    $fixtures = [
        'owner' => ['+12025550101', 'admin'],
        'friend' => ['+12025550102', 'admin'],
        'other' => ['+12025550103', 'user'],
        'missing' => ['+12025550104', 'user'],
        'disabled' => ['+12025550105', 'admin'],
        'participant' => ['fictional-'.bin2hex(random_bytes(10)), 'user'],
    ];
    $out = [];
    foreach ($fixtures as $key => [$phone, $role]) {
        if ($key === 'participant' && config('app.admin_phones') !== ['+12025550101', '+12025550103']) exit(6);
        $user = User::firstOrCreate(['phone' => $phone], [
            'role' => $role, 'password' => $password, 'disabled' => $key === 'disabled',
            'is_synthetic' => true, 'synthetic_batch' => 'cloud-r0-fictional-only',
            'account_status' => 'active', 'moderation_status' => 'normal',
        ]);
        $user->update(['password' => $password]);
        $out[$key] = ['id' => $user->id, 'phone' => $phone];
    }
    $mapped = $out['owner']['id'];
    if ($mapped === 9100001 || \Illuminate\Support\Facades\Hash::check('fictional-legacy-credential', User::findOrFail($mapped)->password)) {
        exit(3);
    }
    try {
        DB::transaction(function () use ($fixtures, $password) {
            User::create(['phone' => $fixtures['other'][0], 'role' => 'admin', 'password' => $password]);
        });
        exit(4);
    } catch (\Illuminate\Database\QueryException $error) {
        if (($error->errorInfo[1] ?? null) !== 1062) {
            exit(5);
        }
    }
    $out['password'] = $password;
    echo json_encode($out, JSON_THROW_ON_ERROR), PHP_EOL;
    """)


def login(actors, key, expected=200):
    return request(
        f"login-{key}", "POST", "/auth/login", (expected,),
        payload={"phone": actors[key]["phone"], "password": actors["password"], "device_id": "r0-fixture-" + key},
    )[1]


def business():
    actors = seed()
    print("fictional admin: target-generated ID, fresh password, duplicate contact rejected", flush=True)
    owner = login(actors, "owner")
    friend = login(actors, "friend")["access_token"]
    other = login(actors, "other")["access_token"]
    login(actors, "disabled", 403)
    admin = owner["access_token"]
    token = login(actors, "participant")["access_token"]
    request("guest-admin", "GET", "/admin/users", (401,))
    request("enabled-role-allowlist", "GET", "/admin/users", (200,), admin)
    request("role-without-allowlist", "GET", "/admin/users", (403,), friend)
    request("allowlist-without-role", "GET", "/admin/users", (403,), other)
    request("auth-verify", "POST", "/auth/session/verify", (200,), admin,
            {"refresh_token": owner["refresh_token"]})
    request("formal-enrollment-fails-closed", "PUT", "/journey/participation", (403,), token,
            {"action": "opt_in", "revision": 0, "intent": "fixture"})

    command = {"action": "answer", "expected_revision": 0, "questionnaire_version": "lifestyle_v1",
               "request_key": str(uuid4()), "scene_id": "home_atmosphere", "option_id": "quiet"}
    lifestyle = "/profile/lifestyle-discovery"
    receipt = lifestyle + "/command-result?" + urlencode(command)

    def command_state(label, credential, value):
        body = request(label, "GET", receipt, (200,), credential)[1]
        require(body["command_status"] == value, label)

    command_state("lifestyle-before", token, "NOT_APPLIED")
    alternative = dict(command, request_key=str(uuid4()))
    with ThreadPoolExecutor(max_workers=2) as pool:
        results = list(pool.map(
            lambda data: request("lifestyle-concurrent", "PUT", lifestyle, (200, 409), token, data)[0],
            (command, alternative),
        ))
    require(sorted(results) == [200, 409], "one concurrent writer must win")
    if results[0] != 200:
        receipt = lifestyle + "/command-result?" + urlencode(alternative)
    command_state("lifestyle-applied", token, "APPLIED")
    command_state("lifestyle-other-account", friend, "NOT_APPLIED")
    request("lifestyle-conflicting-receipt", "GET", receipt + "&option_id=invalid", (409,), token)
    participant = int(actors["participant"]["id"])
    require(php(f"""echo json_encode([
        DB::table('lifestyle_discoveries')->where('user_id', {participant})->count(),
        DB::table('lifestyle_discovery_commands')->where('user_id', {participant})->count(),
    ]), PHP_EOL;""") == [1, 1], "MariaDB lifestyle write/receipt count")

    request("buddy-enable", "PUT", "/buddy/preferences", (200,), token, {"enabled": True, "revision": 0})
    start = datetime.now(timezone.utc) + timedelta(days=2)
    buddy = {"type": "STUDY", "subject": "Fictional reading", "place_kind": "ONLINE",
             "budget_band": "LOW", "start_at": start.isoformat(),
             "end_at": (start + timedelta(hours=1)).isoformat(), "idempotency_key": str(uuid4())}
    lookup = "/buddy/activities/create-result?" + urlencode({"idempotency_key": buddy["idempotency_key"]})
    require(request("buddy-before", "GET", lookup, (200,), token)[1]["command_status"] == "NOT_APPLIED",
            "Buddy before")
    buddy_id = request("buddy-create", "POST", "/buddy/activities", (201,), token, buddy)[1]["id"]
    require(request("buddy-original-result", "GET", lookup, (200,), token)[1]["command_status"] == "APPLIED",
            "Buddy original result")
    require(request("buddy-same-key", "POST", "/buddy/activities", (201,), token, buddy)[1]["id"] == buddy_id,
            "Buddy idempotency")
    request("buddy-conflict", "POST", "/buddy/activities", (409,), token, dict(buddy, subject="Changed fixture"))

    upload = request("private-photo-upload", "POST", "/profile/showcase/photos", (200,), token,
                     media={"expected_revision": 0, "client_upload_id": str(uuid4())})[1]
    photo_id = upload["draft"]["photos"][0]["id"]
    photo_path = f'/profile/showcase/{actors["participant"]["id"]}/photos/{photo_id}'
    _, body, headers = request("private-photo-owner", "GET", photo_path, (200,), token)
    require(body.startswith(b"\x89PNG") and "no-store" in headers["Cache-Control"], "private photo cache control")
    request("private-photo-other-account", "GET", photo_path, (404,), friend)
    request("private-photo-guest", "GET", photo_path, (401,))

    peer = int(actors["friend"]["id"])
    php(f"""
    DB::table('friendships')->insert(['user_a' => {min(participant, peer)}, 'user_b' => {max(participant, peer)},
        'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
    """)
    request("connection-unavailable-on-staging", "POST", f"/connections/{peer}/connection",
            (404,), token, {"action": "request", "expected_revision": 0})
    post = request("friend-post-publish", "POST", "/status/posts", (201,), token,
                   {"title": "Fixture", "body": "Fictional post", "audience": "FRIENDS"})[1]["item"]["id"]
    post_path = f"/status/posts/{post}"
    request("friend-post-read", "GET", post_path, (200,), friend)
    request("friend-post-account-switch", "GET", post_path, (404,), other)
    request("friend-post-block", "POST", "/moderation/blocks", (200,), token,
            {"blocked_user_id": actors["friend"]["id"]})
    request("friend-post-stale-link-after-block", "GET", post_path, (404,), friend)
    request("connection-unavailable-after-block", "POST", f'/connections/{actors["friend"]["id"]}/connection',
            (404,), token, {"action": "request", "expected_revision": 0})

    require(php(r"""
    $u = User::where('phone', '+12025550105')->firstOrFail();
    $allowed = config('app.admin_phones');
    config(['app.admin_phones' => [...$allowed, $u->phone]]);
    $denied = ! app(\App\Services\Accounts\AdminAccess::class)->allows($u);
    User::where('phone', '+12025550101')->update(['role' => 'user']);
    echo json_encode($denied), PHP_EOL;
    """) is True, "disabled admin rejected even if allowlisted")
    request("admin-role-revoked-current-session", "GET", "/admin/users", (403,), admin)
    request("device-logout", "POST", "/auth/logout", (200,), admin)
    request("revoked-token-rejected", "GET", NATAL, (401,), admin)
    request("fictional-legacy-token-rejected", "GET", "/admin/users", (401,), "fictional-legacy-token")


def natal(mode):
    key = "owner" if mode == "natal" else "missing"
    actors = seed()
    token = login(actors, key)["access_token"]
    other = login(actors, "other")["access_token"] if mode == "natal" else None
    fixture = {
        "civil_date": "2000-01-01", "civil_time": "12:00", "time_precision": "minute",
        "timezone": "Europe/London", "latitude": 51.5, "longitude": 0.0, "algorithm_sex": "female",
    }
    payload = {"input": fixture, "settings": {}, "expected_revision": 0}
    if mode == "recover":
        profile = request("failed-state-readback-before-recovery", "GET", NATAL, (200,), token)[1]["profile"]
        require(profile["status"] == "FAILED" and profile["input_revision"] == 1, "recovery precondition")
        payload["expected_revision"] = 1
    request("guest-natal", "GET", NATAL, (401,))
    expected = 503 if mode == "missing" else 200
    _, response, _ = request("natal-known-" + mode, "POST", NATAL, (expected,), token, payload)
    persisted = request("natal-persistent-readback", "GET", NATAL, (200,), token)[1]["profile"]
    if mode == "missing":
        require(response["code"] == "natal_calculation_unavailable", "public 503 reason")
        require("r0-missing-node" not in json.dumps(response), "absolute dependency path leaked")
        require(persisted["status"] == "FAILED" and persisted["results"] is None
                and persisted["result_revision"] is None, "failed row must not reuse results")
        return
    require(persisted == response["profile"], "persistent profile differs")
    require(persisted["status"] == "COMPUTED_UNVERIFIED", "preserve calculation status")
    modules = persisted["results"]
    require(set(modules) == {"bazi", "ziwei", "western"}, "three calculation modules")
    require(modules["ziwei"]["calculation_status"] == modules["western"]["calculation_status"] == "CALCULATED"
            and modules["ziwei"]["oracle_status"] == "UNVERIFIED", "known-time module statuses")
    print("three modules:", modules["bazi"]["status"], modules["ziwei"]["calculation_status"],
          modules["western"]["calculation_status"], flush=True)
    if mode == "recover":
        require(persisted["input_revision"] == persisted["result_revision"] == 2, "recovery version")
        return
    require(persisted["input_revision"] == persisted["result_revision"] == 1, "first write version")
    require(request("natal-other-account", "GET", NATAL, (200,), other)[1]["exists"] is False,
            "cross-account natal read")
    request("natal-stale-revision", "POST", NATAL, (409,), token, payload)
    payload["input"] = dict(fixture, civil_time=None, time_precision="unknown")
    payload["expected_revision"] = 1
    unknown = request("natal-unknown-time", "POST", NATAL, (200,), token, payload)[1]["profile"]
    require(unknown["context"]["normalized_time"] is None and unknown["results"]["western"]["calculation_status"]
            == "UNKNOWN" and unknown["result_revision"] == 2, "unknown-time must stay unknown")


if args.mode == "business":
    business()
else:
    natal(args.mode)
print(f"R0 {args.mode}: PASS", flush=True)
