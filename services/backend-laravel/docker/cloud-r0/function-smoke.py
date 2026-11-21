#!/usr/bin/env python3
"""Local fixture with real HTTPS, Laravel and MariaDB. Run from the dedicated WSL only."""
import argparse
from datetime import datetime, timedelta, timezone
from html.parser import HTMLParser
from http.cookiejar import CookieJar
import json
from pathlib import Path
import secrets
import ssl
import subprocess
from urllib.error import HTTPError
from urllib.parse import urlencode, urlsplit
from urllib.request import HTTPRedirectHandler, HTTPCookieProcessor, HTTPSHandler, ProxyHandler, Request, build_opener
from uuid import uuid4

BASE = "https://127.0.0.1:18444"
API = "/api/v1"
TLS = ssl.create_default_context(cafile="/srv/function/secrets/tls.crt")


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, request, response, code, message, headers, new_url):
        return None


class FormToken(HTMLParser):
    value = None

    def handle_starttag(self, tag, attrs):
        fields = dict(attrs)
        if tag == "input" and fields.get("name") == "_token":
            self.value = fields.get("value")


def require(condition, label):
    if not condition:
        raise RuntimeError(label)


def opener():
    return build_opener(ProxyHandler({}), HTTPSHandler(context=TLS), HTTPCookieProcessor(CookieJar()), NoRedirect())


class Fixture:
    def __init__(self, folder):
        self.project = ["docker", "--host", "unix:///run/docker.sock", "compose", "-p", "elitesync-v2-function",
                        "--env-file", "/srv/function/local.env", "-f", str(folder / "compose.yaml"),
                        "-f", str(folder / "compose.function.yaml")]
        self.api = opener()
        self.password = secrets.token_hex(23) + "Aa9"

    def php(self, body, expected=0):
        source = r"""<?php
        $argv[] = '--function';
        require '/opt/elitesync-r0/db-preflight.php';
        use App\Models\User;
        use Illuminate\Support\Facades\DB;
        use App\Services\SyntheticConnectionScope;
        if (! app(SyntheticConnectionScope::class)->enabled()) exit(2);
        """ + body
        command = self.project + ["exec", "-T", "r0-app", "/usr/local/bin/elitesync-r0", "php"]
        result = subprocess.run(command, input=source, text=True, encoding="utf-8", capture_output=True, timeout=30)
        require(result.returncode == expected, f"fixture PHP returned {result.returncode}")
        lines = result.stdout.splitlines()
        require(json.loads(lines[0])["schema"] == "elitesync_v2_function", "wrong fixture database")
        return json.loads(lines[-1]) if len(lines) > 1 else None

    def pair(self, action, actor, peer, expected=0):
        command = self.project + ["exec", "-T", "r0-app", "/usr/local/bin/elitesync-r0", "php", "artisan",
                                  "qa:connection-pair", action, str(actor), str(peer)]
        result = subprocess.run(command, text=True, capture_output=True, timeout=30)
        print(f"pair-{action} exit={result.returncode}", flush=True)
        require(result.returncode == expected, f"pair {action} expected {expected}")

    def request(self, label, method, path, status, token=None, body=None, client=None, form=False, headers=None):
        require(path.startswith("/") and not path.startswith("//"), "fixture path")
        extra = {"Accept": "text/html" if client else "application/json", **(headers or {})}
        if token:
            extra["Authorization"] = f"Bearer {token}"
        data = None
        if body is not None:
            extra["Content-Type"] = "application/x-www-form-urlencoded" if form else "application/json"
            data = (urlencode(body) if form else json.dumps(body)).encode()
        try:
            result = (client or self.api).open(Request(BASE + path, data, extra, method=method), timeout=190)
        except HTTPError as error:
            result = error
        with result:
            raw = result.read()
            actual = result.status
            print(f"{label} HTTP {actual}", flush=True)
            require(status == actual, f"{label} expected {status}, got {actual}")
            data = json.loads(raw) if result.headers.get_content_type() == "application/json" else raw.decode("utf-8")
            return data, result.headers

    def call(self, label, method, path, status, token=None, body=None, **kwargs):
        return self.request(label, method, API + path, status, token, body, **kwargs)[0]

    def login(self, phone):
        return self.call("api-login", "POST", "/auth/login", 200,
                         body={"phone": phone, "password": self.password, "device_id": str(uuid4())})


def seed(f):
    return f.php(r"""
    $p = """ + json.dumps(f.password) + r""";
    $ids = [];
    foreach (['alpha', 'beta', 'gamma', 'admin', 'no_role'] as $key) {
        $phone = match ($key) {
            'admin' => '+12025550151',
            'no_role' => '+12025550153',
            default => 'fixture-'.bin2hex(random_bytes(8)),
        };
        $user = User::firstOrCreate(['phone' => $phone], [
            'name' => 'Function fixture '.$key,
            'role' => $key === 'admin' ? 'admin' : 'user',
            'is_synthetic' => true,
            'account_type' => 'test',
            'synthetic_batch' => SyntheticConnectionScope::DATASET,
            'account_status' => 'active',
            'moderation_status' => 'normal',
            'password' => $p,
        ]);
        if (! $user->is_synthetic || $user->synthetic_batch !== SyntheticConnectionScope::DATASET
            || ($key === 'admin') !== $user->isAdminRole()) exit(3);
        $user->update(['password' => $p]);
        $ids[$key] = ['id' => (int)$user->id, 'phone' => $phone];
    }
    echo json_encode($ids, JSON_THROW_ON_ERROR), PHP_EOL;
    """)


def account_and_natal(f):
    phone = "fixture-" + secrets.token_hex(8)
    new = f.call("register-with-forged-verified", "POST", "/auth/register", 201, body={
        "phone": phone, "password": f.password, "device_id": str(uuid4()), "realname_verified": True,
    })
    require(new["user"]["realname_verified"] is False, "client cannot set KYC")
    login = f.login(phone)
    token = login["access_token"]
    f.call("verify-live-session", "POST", "/auth/session/verify", 200, token,
           {"refresh_token": login["refresh_token"]})
    f.call("save-self-profile", "POST", "/profile/basic", 200, token,
           {"name": "Function fixture saved", "gender": "female", "city": "Test City", "relationship_goal": "friendship"})
    readback = f.call("get-self-profile", "GET", "/profile/basic", 200, token)
    require(readback["name"] == "Function fixture saved", "profile readback")
    f.call("formal-kyc-required", "PUT", "/journey/participation", 403, token,
           {"action": "opt_in", "revision": 0, "intent": "fixture"})
    form = {"input": {"civil_date": "2000-01-01", "civil_time": "12:00", "time_precision": "minute",
                      "timezone": "Europe/London", "latitude": 51.5, "longitude": 0.0, "algorithm_sex": "female"},
            "settings": {}, "expected_revision": 0}
    profile = f.call("known-natal", "POST", "/profile/natal", 200, token, form)["profile"]
    require(profile["status"] == "COMPUTED_UNVERIFIED" and set(profile["results"]) == {"bazi", "ziwei", "western"},
            "natal modules")
    f.call("stale-natal-revision", "POST", "/profile/natal", 409, token, form)
    form["input"].update(civil_time=None, time_precision="unknown")
    form["expected_revision"] = 1
    profile = f.call("unknown-natal", "POST", "/profile/natal", 200, token, form)["profile"]
    require(profile["context"]["normalized_time"] is None
            and profile["results"]["western"]["calculation_status"] == "UNKNOWN", "unknown time preserved")
    require(f.call("natal-readback", "GET", "/profile/natal", 200, token)["profile"] == profile, "natal readback")
    f.call("api-logout", "POST", "/auth/logout", 200, token)
    f.call("old-api-session", "GET", "/profile/basic", 401, token)
    return new["user"]["id"], f.login(phone)["access_token"]


def friendship(f, a, b):
    f.call("enable-invitations", "POST", "/social/preferences", 200, b, {"requests_enabled": True})
    invite = f.call("create-friend-invite", "POST", "/social/invites", 201, b, {"purpose": "friendship"})
    request = f.call("send-friend-request", "POST", "/social/requests", 201, a,
                     {"purpose": "friendship", "invitation_token": invite["token"], "idempotency_key": str(uuid4())})
    accepted = f.call("accept-friend-request", "POST", f'/social/requests/{request["id"]}/accept', 200, b)
    require(accepted["state"] == "ACCEPTED", "friendship accepted")


def relation(f, actors, normal_id, normal_token):
    a, b, c = [int(actors[k]["id"]) for k in ("alpha", "beta", "gamma")]
    at, bt, ct = [f.login(actors[k]["phone"])["access_token"] for k in ("alpha", "beta", "gamma")]
    friendship(f, at, bt)
    friendship(f, at, ct)
    require(f.call("other-account-cannot-see-natal", "GET", "/profile/natal", 200, at)["exists"] is False,
            "private natal account scope")
    f.call("ungranted-friend", "GET", f"/connections/{b}", 404, at,
           headers={"X-Synthetic-Connection": "true"})
    f.pair("grant", a, normal_id, expected=1)
    f.pair("grant", a, b)
    f.pair("grant", a, c)
    f.call("ungranted-third-party", "GET", f"/connections/{c}", 404, bt)

    def activate(peer, receiver, message):
        def change(actor, target, kind, action, rev, status=200):
            return f.call(f"{kind}-{action}", "POST", f"/connections/{target}/{kind}", status, actor,
                          {"action": action, "expected_revision": rev})

        payload = {"receiver_id": peer, "content": message, "client_message_id": str(uuid4())}
        f.call("friends-cannot-send", "POST", "/messages", 404, at, payload)
        require(change(at, peer, "connection", "request", 0)["connection"]["state"] == "CN_PENDING", "connection pending")
        change(at, peer, "connection", "accept", 1, 409)
        require(change(receiver, a, "connection", "accept", 1)["connection"]["state"] == "CN_ACTIVE", "connection active")
        f.call("connection-cannot-send", "POST", "/messages", 404, at, payload)
        require(change(at, peer, "consent", "request", 0)["consent"]["state"] == "MC_PENDING", "consent pending")
        change(at, peer, "consent", "accept", 1, 409)
        require(change(receiver, a, "consent", "accept", 1)["consent"]["state"] == "MC_ACTIVE", "consent active")
        f.call("sandbox-public-attachment-denied", "POST", "/messages", 422, at, dict(payload, attachment_ids=[1]))
        message_row = f.call("send-message", "POST", "/messages", 200, at, payload)
        replay = f.call("replay-message", "POST", "/messages", 200, at, payload)
        require(replay["id"] == message_row["id"] and replay["idempotent_replay"], "idempotent replay")
        history = f.call("read-message", "GET", f"/messages?peer_id={a}", 200, receiver)
        require(any(row["content"] == message for row in history["items"]), "message persistence")
        notices = f.call("authorized-message-notification", "GET", "/notifications", 200, receiver)["items"]
        notice = next(item for item in notices if item.get("route_name") == "chat_room")
        require(message not in json.dumps(notice), "notification contains private text")
        return payload, notice["id"], int(message_row["conversation_id"])

    first, notice_id, convo = activate(b, bt, "synthetic text for consent test")
    second, block_notice, block_convo = activate(c, ct, "synthetic text for block test")
    f.call("conversation-list", "GET", "/conversations", 200, bt)
    f.call("cross-account-history-denied", "GET", f"/conversations/{convo}", 404, ct)

    f.call("consent-revoke", "POST", f"/connections/{a}/consent", 200, bt,
           {"action": "revoke", "expected_revision": 2})
    f.call("old-conversation-after-revoke", "GET", f"/conversations/{convo}", 404, bt)
    f.call("duplicate-send-after-revoke", "POST", "/messages", 404, at, first)
    after = f.call("old-notice-after-consent-revoke", "GET", f"/notifications/{notice_id}", 200, bt)["item"]
    require(after["availability"] == "history" and not after["payload"], "revoked notice route")

    f.call("home-feed", "GET", "/home/feed", 200, at)
    post = f.call("publish-friends-post", "POST", "/status/posts", 201, at,
                  {"title": "Fixture", "body": "Fictional friends post", "audience": "FRIENDS"})["item"]["id"]
    f.call("friend-post-visible", "GET", f"/status/posts/{post}", 200, ct)
    comments = f"/status-posts/{post}/comments"
    note = f.call("friend-comment", "POST", comments, 201, ct,
                  {"body": "Fictional prior audience", "idempotency_key": str(uuid4())})
    comment_path = f'{comments}/{note["id"]}'
    require(f.call("post-owner-can-read-comment", "GET", comment_path, 200, at)["body"]
            == "Fictional prior audience", "original comment audience")
    friendship(f, at, normal_token)
    f.call("non-fixture-friend", "GET", f"/connections/{a}", 404, normal_token)
    f.call("new-friend-can-read-post", "GET", f"/status/posts/{post}", 200, normal_token)
    f.call("new-friend-cannot-read-old-comment", "GET", comment_path, 404, normal_token)
    f.call("block-peer", "POST", "/moderation/blocks", 200, at, {"blocked_user_id": c})
    f.call("block-hides-conversation", "GET", f"/conversations/{block_convo}", 404, ct)
    f.call("block-prevents-replay", "POST", "/messages", 404, at, second)
    f.call("block-hides-friends-post", "GET", f"/status/posts/{post}", 404, ct)
    f.call("block-hides-old-comment", "GET", comment_path, 404, ct)
    after = f.call("old-notice-after-block", "GET", f"/notifications/{block_notice}", 200, ct)["item"]
    require(after["availability"] == "history" and not after["payload"], "blocked notice route")

    f.pair("revoke", a, b)
    f.pair("grant", a, b, expected=1)
    f.call("fixture-revoked-connection", "GET", f"/connections/{b}", 404, at)
    require(f.php(f"""echo json_encode([
      DB::table('synthetic_connection_pairs')->whereIn('user_a', [{a}, {b}])
          ->whereIn('user_b', [{a}, {b}])->whereNotNull('revoked_at')->count(),
      DB::table('chat_messages')->where('sender_id', {a})->count(),
      DB::table('product_connections')->where('requester_id', {a})->count(),
    ]), PHP_EOL;""") == [1, 2, 2], "fixture transaction state")
    return at


def buddy(f, auth, guest):
    f.call("buddy-opt-in", "PUT", "/buddy/preferences", 200, auth, {"enabled": True, "revision": 0})
    start = datetime.now(timezone.utc) + timedelta(days=2)
    payload = {"type": "STUDY", "subject": "Fictional reading", "place_kind": "ONLINE", "budget_band": "LOW",
               "start_at": start.isoformat(), "end_at": (start + timedelta(hours=1)).isoformat(),
               "idempotency_key": str(uuid4())}
    url = "/buddy/activities/create-result?" + urlencode({"idempotency_key": payload["idempotency_key"]})
    require(f.call("buddy-not-applied", "GET", url, 200, auth)["command_status"] == "NOT_APPLIED", "Buddy initial receipt")
    item = f.call("buddy-create", "POST", "/buddy/activities", 201, auth, payload)
    require(f.call("buddy-applied", "GET", url, 200, auth)["command_status"] == "APPLIED", "Buddy saved receipt")
    require(f.call("buddy-dedup", "POST", "/buddy/activities", 201, auth, payload)["id"] == item["id"],
            "Buddy same-key retry")
    activity = f"/buddy/{item['id']}"
    discovery = "/buddy/discovery?" + urlencode({"city": "线上", "type": "STUDY"})
    f.call("buddy-opt-in-required", "GET", discovery, 403, guest)
    preference = f.call("buddy-guest-opt-in", "PUT", "/buddy/preferences", 200, guest,
                        {"enabled": True, "revision": 0})
    f.call("buddy-draft-private", "GET", activity, 404, guest)

    def action(label, name, revision):
        return f.call(label, "POST", activity + "/actions", 200, auth,
                      {"action": name, "revision": revision, "idempotency_key": str(uuid4())})

    opened = action("buddy-open", "open", item["revision"])
    published = f.call("buddy-publish-discovery", "POST", activity + "/discovery", 200, auth,
                       {"action": "publish", "revision": opened["revision"], "author_label": "Fixture host",
                        "idempotency_key": str(uuid4())})
    publication = published["discovery"]
    cards = f.call("buddy-discover", "GET", discovery, 200, guest)["items"]
    card = next(row for row in cards if row["publication_id"] == publication["publication_id"])
    require(card["author_label"] == "Fixture host" and "owner_id" not in card and card["avatar"] is None,
            "minimal Buddy card")
    apply_path = f"/buddy/discovery/{publication['publication_id']}/apply"
    application = {"generation": publication["generation"], "revision": published["revision"],
                   "idempotency_key": str(uuid4())}
    applied = f.call("buddy-apply", "POST", apply_path, 200, guest, application)
    require(applied["state"] == "REQUESTED" and applied["participation_source"] == "DISCOVERY",
            "Buddy request state")
    require(action("buddy-confirm", "confirm", applied["revision"])["state"] == "CONFIRMED",
            "Buddy owner confirmation")
    require(f.call("buddy-apply-replay", "POST", apply_path, 200, guest, application)["state"] == "CONFIRMED",
            "Buddy replays current authorized state")
    require(f.php(f"""echo json_encode([
      DB::table('buddy_activities')->where('id',{json.dumps(item['id'])})->value('state'),
      DB::table('buddy_commands')->where('idempotency_key',{json.dumps(application['idempotency_key'])})->count(),
    ]), PHP_EOL;""") == ["CONFIRMED", 1], "Buddy state and single application commit")
    f.call("buddy-guest-opt-out", "PUT", "/buddy/preferences", 200, guest,
           {"enabled": False, "revision": preference["revision"]})
    f.call("buddy-discovery-lost-access", "GET", discovery, 403, guest)
    projection = f.call("buddy-terminal-projection", "GET", activity, 200, guest)
    require(projection["state"] == "WITHDRAWN" and "subject" not in projection, "Buddy terminal exposure")


def admin(f, actors, target_id, target_token):
    def web(label, method, path, code, client, fields=None):
        return f.request(label, method, path, code, body=fields, client=client, form=fields is not None)

    def csrf(label, path, client):
        parser = FormToken()
        parser.feed(web(label, "GET", path, 200, client)[0])
        require(parser.value is not None, "Web form csrf")
        return parser.value

    denied, allowed = opener(), opener()
    web("web-guest", "GET", "/admin", 302, denied)
    denied_fields = {"phone": actors["no_role"]["phone"], "password": f.password}
    web("web-allowlist-without-role", "POST", "/admin/login", 302, denied,
        denied_fields | {"_token": csrf("web-guest-login", "/admin/login", denied)})
    web("web-still-guest", "GET", "/admin", 302, denied)
    login = {"phone": actors["admin"]["phone"], "password": f.password}
    web("web-admin-csrf-required", "POST", "/admin/login", 419, allowed, login)
    _, headers = web("web-admin-login", "POST", "/admin/login", 302, allowed,
                     login | {"_token": csrf("web-login-form", "/admin/login", allowed)})
    require(urlsplit(headers["Location"]).path == "/admin", "Web admin destination")
    web("web-admin-users", "GET", "/admin", 200, allowed)
    web("web-showcase-queue", "GET", "/admin/showcase", 200, allowed)
    web("web-report-queue", "GET", "/admin/reports", 200, allowed)
    reporter = f.login(actors["beta"]["phone"])["access_token"]
    report = f.call("submit-user-report", "POST", "/moderation/reports", 200, reporter,
                    {"target_user_id": target_id, "category": "user", "reason_code": "fixture",
                     "detail": "Fictional report"})["report"]
    report_id = int(report["id"])
    report_path = f"/admin/reports/{report_id}"
    web("web-report-guest-denied", "GET", report_path, 302, denied)
    triage = {"_token": csrf("web-report-detail", report_path, allowed), "action": "triage", "confirm": "1",
              "reason": "Fictional triage", "expected_revision": 0, "expected_user_revision": 0}
    web("web-report-triage", "POST", report_path, 302, allowed, triage)
    web("web-report-stale-triage", "POST", report_path, 409, allowed, triage)
    draft = f.call("save-private-showcase", "PUT", "/profile/showcase/draft", 200, target_token,
                   {"expected_revision": 0, "display_name": "Fictional showcase",
                    "self_intro": "Locally reviewed introduction", "audiences": ["friends"]})
    publication = {"expected_revision": draft["revision"], "publication_revision": 0, "confirm_public_display": True}
    f.call("unreviewed-showcase-cannot-publish", "POST", "/profile/showcase/publication", 409, target_token, publication)
    submission = f.call("submit-showcase", "POST", "/profile/showcase/draft/submit-review", 200, target_token,
                        {"expected_revision": draft["revision"]})["submission"]
    review_path = f'/admin/showcase/{submission["id"]}'
    review = {"_token": csrf("web-showcase-review-form", review_path, allowed),
              "result": "approved", "reason": "Fictional review", "confirm": "1",
              "expected_revision": submission["revision"]}
    web("web-showcase-approve", "POST", review_path, 302, allowed, review)
    web("web-showcase-stale-approve", "POST", review_path, 409, allowed, review)
    require(f.call("review-does-not-publish", "GET", "/profile/showcase/publication", 200, target_token)["publication"]
            is None, "review is separate from publish")
    published = f.call("owner-confirms-showcase-publication", "POST", "/profile/showcase/publication",
                       200, target_token, publication)["publication"]
    require(published["publication_status"] == "published", "published snapshot")
    web("web-disable-user", "POST", f"/admin/users/{target_id}/disable", 302, allowed,
        {"_token": csrf("web-user-detail", f"/admin/users/{target_id}", allowed),
         "expected_revision": "0", "reason": "Fictional integration test", "confirm_disable": "1"})
    require(f.php(f"""echo json_encode([
      (bool) User::findOrFail({int(target_id)})->disabled,
      DB::table('admin_operation_audits')->where('target_id', (string){int(target_id)})
          ->where('action','user.banned')->count(),
      DB::table('profile_showcase_submissions')->where('user_id',{int(target_id)})->where('state','approved')->count(),
      DB::table('user_profile_showcase_publications')->where('user_id',{int(target_id)})->count(),
      DB::table('moderation_reports')->where('id',{report_id})->value('status'),
      DB::table('admin_operation_audits')->where('target_id',(string){report_id})->where('action','report.triage')->count(),
    ]), PHP_EOL;""") == [True, 1, 1, 1, "triaged", 1], "moderation, showcase and audit commit")
    f.call("disabled-user-loses-session", "GET", "/profile/basic", 401, target_token)
    web("web-audit-view", "GET", "/admin/audits", 200, allowed)
    web("web-logout", "POST", "/admin/logout", 302, allowed,
        {"_token": csrf("web-admin-session", "/admin", allowed)})
    web("web-logout-revokes-page", "GET", "/admin", 302, allowed)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("compose_folder", type=Path)
    fixture = Fixture(parser.parse_args().compose_folder)
    people = seed(fixture)
    uid, bearer = account_and_natal(fixture)
    buddy(fixture, relation(fixture, people, uid, bearer), bearer)
    admin(fixture, people, uid, bearer)
    print("function fixture: PASS", flush=True)
