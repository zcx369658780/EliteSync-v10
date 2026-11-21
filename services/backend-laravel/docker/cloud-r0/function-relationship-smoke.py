#!/usr/bin/env python3
"""Run the signed synthetic journey on the provisioned loopback MariaDB fixture."""

import argparse
from datetime import datetime, timedelta, timezone
import json
from pathlib import Path
import runpy
import subprocess
import time
from urllib.parse import urlencode
from uuid import UUID, uuid4


def command(f, args, label, expected=0, overrides=()):
    env = [item for override in overrides for item in ("-e", override)]
    result = subprocess.run(
        f.project + ["exec", "-T", *env, "r0-app", "/usr/local/bin/elitesync-r0", "php", "artisan", *args],
        capture_output=True, text=True, timeout=45,
    )
    print(f"{label} exit={result.returncode}", flush=True)
    require(result.returncode == expected, label)
    return result.stdout.strip()


def seed(f):
    return f.php(r"""
    use App\Services\MariaDbFixtureIdentity;
    use App\Models\QuestionnaireQuestion;
    use App\Models\QuestionnaireAnswer;
    if (! app(MariaDbFixtureIdentity::class)->enabled()) exit(4);
    $required = (int) config('questionnaire.required_answer_count', 10);
    $password = """ + json.dumps(f.password) + r""";
    $people = [];
    foreach (['a','b','expires','forged','wrong_batch','disabled','ordinary'] as $kind) {
        $user = User::create([
            'phone' => 'p02-'.bin2hex(random_bytes(8)), 'name' => 'Fictional P0.2 fixture',
            'password' => $password, 'is_synthetic' => $kind !== 'ordinary', 'account_type' => 'test',
            'synthetic_batch' => $kind === 'wrong_batch' ? 'p02-other-qa' : MariaDbFixtureIdentity::DATASET,
            'verify_status' => 'approved', 'realname_verified' => false, 'disabled' => $kind === 'disabled',
            'account_status' => 'active', 'moderation_status' => 'normal', 'is_match_eligible' => true,
        ]);
        $people[$kind] = ['id' => (int)$user->id, 'phone' => $user->phone];
        if (! in_array($kind, ['a','b'], true)) continue;
        for ($i = 0; $i < $required; $i++) {
            $q = QuestionnaireQuestion::firstOrCreate(['question_key' => 'p02-qa-'.$i], [
                'category' => 'lifestyle', 'content' => 'Fictional preference', 'question_type' => 'single_choice',
                'enabled' => true, 'version' => 1, 'options' => [['option_id' => 'A'], ['option_id' => 'B']],
            ]);
            QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $q->id,
                'selected_answer_json' => ['A'], 'acceptable_answers_json' => ['A'], 'importance' => 3,
                'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
        }
    }
    echo json_encode($people, JSON_THROW_ON_ERROR), PHP_EOL;
    """)


def enrollment(f, token, gender):
    inputs = {"revision": 0, "confirm": True, "birthday": "1995-01-02",
              "gender": gender, "city_key": "Fixture", "relationship_goal": "marriage",
              "age_mode": "adult_any", "region_mode": "same_city",
              **dict.fromkeys(("height_cm", "education", "occupation", "marital_history",
                               "children_status", "children_intention"))}
    f.call("matching-input-confirm", "PUT", "/matching-inputs", 200, token, inputs)
    url = "/profile/lifestyle-discovery"
    lifestyle = f.call("lifestyle-bank", "GET", url, 200, token)
    for scene in lifestyle["bank"]["scenes"]:
        lifestyle = f.call("lifestyle-answer", "PUT", url, 200, token, {
            "action": "answer", "expected_revision": lifestyle["revision"], "request_key": str(uuid4()),
            "questionnaire_version": lifestyle["questionnaire_version"],
            "scene_id": scene["id"], "option_id": scene["options"][0]["id"],
        })
    state = f.call("qualified-enrollment", "PUT", "/journey/participation", 200, token,
                   {"action": "opt_in", "revision": 0, "intent": "Explicit fictional participation"})
    require(state["state"] == "ACTIVE", "enrollment persisted")


def run_round(f, admin, participants):
    root = "/admin/matching/rounds"
    now = datetime.now(timezone.utc)
    channel = f.php("echo json_encode(DB::table('dating_round_channels')->where('channel_key','default')->first(['active_round_id','state_version'])),PHP_EOL;")
    require(channel is None or channel["active_round_id"] is None, "existing active default round; preserve it")
    future = f.call("admin-prepare", "POST", root, 201, admin, {
        "channel_key": "default", "cadence_key": "p02-" + uuid4().hex,
        "scheduled_for": (now-timedelta(minutes=2)).isoformat(), "reveal_at": (now-timedelta(minutes=1)).isoformat(),
        "state_version": channel["state_version"] if channel else 1,
    }, headers={"Idempotency-Key": str(uuid4())})["data"]
    path = f"{root}/{future['round_key']}"
    run = f.call("admin-request-execution", "POST", path+"/execution-requests", 202, admin,
                 {"state_version": future["state_version"], "reason_code": "fixture"},
                 headers={"Idempotency-Key": str(uuid4())})["data"]
    command(f, ["app:matching:execute-pending", "--once", f"--run-id={run['id']}"], "real-matching-consumer")
    current = f.call("admin-round-before-reveal", "GET", path, 200, admin)["data"]
    require(current["active_run"]["candidate_count"] == 2 and current["active_run"]["pair_count"] == 1, "exactly two qualified candidates")
    for token in participants:
        require(f.call("not-revealed", "GET", "/journey", 200, token)["proposal"] is None, "unpublished candidate hidden")
    f.call("admin-reveal-needs-confirmation", "POST", path+"/reveal", 422, admin,
           {"state_version": current["state_version"], "reason_code": "fixture"}, headers={"Idempotency-Key": str(uuid4())})
    published = f.call("admin-reveal", "POST", path+"/reveal", 200, admin,
                       {"state_version": current["state_version"], "reason_code": "fixture"},
                       headers={"Idempotency-Key": str(uuid4()),
                                "X-Matching-Confirmation": f"confirm:{future['round_key']}:reveal"})["data"]
    require(published["state"] == "revealed", "released state")
    return published


def identity(f, token, label, expected):
    candidate = f.call(label, "GET", "/journey", 200, token)["identity"]
    require(candidate["activation_available"] is expected and candidate["test_only"] is expected
            and candidate["formal_participation_available"] is False and candidate["real_provider"] == "PENDING", label)


def smoke(f, record):
    people = seed(f)
    f_admin = support["seed"](f)["admin"]
    admin = f.login(f_admin["phone"])["access_token"]
    tokens = {key: f.login(people[key]["phone"])["access_token"] for key in people if key != "disabled"}
    a, b = [people[key]["id"] for key in ("a", "b")]
    at, bt, guest = [tokens[key] for key in ("a", "b", "ordinary")]
    nonce = str(uuid4())

    def issuer(key, label, expected=0, options=(), overrides=()):
        value = command(f, ["qa:mariadb-identity", "issue", str(people[key]["id"]), *options], label, expected, overrides)
        return str(UUID(value)) if not expected else None

    for env in ("APP_ENV=production", "APP_ENV=local", "V2_FUNCTION_RUNTIME=other",
                "V2_FUNCTION_MARIADB_IDENTITY_ENABLED=false", "DB_DATABASE=elitesync_v2_r0",
                "DB_HOST=wrong-fixture", "DB_USERNAME=other", "DB_PORT=3307",
                "APP_URL=https://not-loopback.invalid"):
        issuer("a", "refuse-" + env.partition("=")[0] + "-" + env.partition("=")[2], 1, overrides=(env,))
    for key in ("wrong_batch", "disabled", "ordinary"):
        issuer(key, "issuance-denied-" + key, 1)
    issuer("a", "excessive-ttl-denied", 1, options=("--ttl=61",))
    expires = issuer("expires", "issue-one-minute", options=("--ttl=1",))
    deadline = time.monotonic() + 62
    identity(f, tokens["expires"], "one-minute-credential-current", True)
    forged = issuer("forged", "issue-then-tamper")
    # Fault injection is limited to the assertion that this fixture just issued.
    f.php(f"DB::table('identity_assertions')->where('id','{forged}')->where('user_id',{people['forged']['id']})->update(['signature'=>str_repeat('0',64)]); echo json_encode(true),PHP_EOL;")
    identity(f, tokens["forged"], "tampered-assertion-denied", False)
    a_cred = issuer("a", "issue-a", options=(f"--nonce={nonce}",))
    issuer("a", "nonce-replay-denied", 1, options=(f"--nonce={nonce}",))
    identity(f, at, "a-test-only", True)
    identity(f, bt, "unsigned-b-denied", False)
    f.call("half-qualified-enrollment-denied", "PUT", "/journey/participation", 403, bt,
           {"action": "opt_in", "revision": 0, "intent": "Fixture"})
    f.call("public-issuer-absent", "POST", "/qa/mariadb-identity", 404, guest, {"test_only": True})
    f.call("ordinary-formal-enrollment-denied", "PUT", "/journey/participation", 403, guest,
           {"action": "opt_in", "revision": 0, "intent": "Fixture", "test_only": True, "verified": True})
    f.call("non-admin-round-denied", "GET", "/admin/matching/rounds", 403, guest)
    b_cred = issuer("b", "issue-b")
    enrollment(f, at, "male")
    enrollment(f, bt, "female")

    round_ = run_round(f, admin, [at, bt])
    proposal = f.call("current-revealed-candidate", "GET", "/journey", 200, at)["proposal"]
    pid = proposal["id"]
    require(proposal["peer_id"] == b and proposal["revision"] == 1, "participant-specific proposal")
    decision = f"/journey/proposals/{pid}/decision"
    first = {"action": "accept", "revision": 1, "idempotency_key": str(uuid4())}
    require(f.call("first-proposal-accept", "POST", decision, 200, at, first)["state"] == "ACCEPTED_BY_ONE", "independent decision")
    f.call("same-key-proposal-replay", "POST", decision, 200, at, first)
    f.call("same-key-proposal-conflict", "POST", decision, 409, at, first | {"action": "withdraw"})
    f.call("stale-proposal-version", "POST", decision, 409, bt, first)
    f.call("half-accepted-connection-denied", "GET", f"/connections/{a}", 404, bt)
    require(f.call("second-proposal-accept", "POST", decision, 200, bt, first | {"revision": 2})["connection_eligible"], "mutual acceptance")
    f.call("third-party-proposal-link-denied", "GET", f"/journey/history/{pid}", 404, guest)
    receipt = f.call("authoritative-decision-receipt", "GET", decision+"-result?"+urlencode(first), 200, at)
    require(receipt["command_status"] == "APPLIED", "receipt readback")
    f.call("relationship-recipient-opt-in", "POST", "/social/preferences", 200, bt, {"requests_enabled": True})
    relationship_body = {"peer_id": b, "idempotency_key": str(uuid4())}
    f.call("match-alone-no-relationship", "POST", "/formal-relationships", 404, at, relationship_body)

    def conn(kind, action, actor, peer, rev):
        return f.call(f"{kind}-{action}", "POST", f"/connections/{peer}/{kind}", 200, actor,
                      {"action": action, "expected_revision": rev})

    conn("connection", "request", at, b, 0)
    cn = conn("connection", "accept", bt, a, 1)
    require(not cn["gates"]["live_send_allowed"], "Connection alone cannot message")
    f.call("connection-alone-no-messages", "GET", f"/messages?peer_id={b}", 404, at)
    relation = f.call("formal-request", "POST", "/formal-relationships", 200, at, relationship_body)
    rel_path = f"/formal-relationships/{relation['id']}/actions"

    def action(kind, actor, rev, status=200):
        return f.call(f"formal-{kind}", "POST", rel_path, status, actor,
                      {"action": kind, "revision": rev, "idempotency_key": str(uuid4())})

    action("confirm", at, 1)
    action("confirm", at, 2, 409)
    active = action("confirm", bt, 2)
    require(active["state"] == "ACTIVE" and active["test_only"], "dual formal confirmation")
    action("end", guest, active["revision"], 404)
    f.call("formal-alone-no-messages", "GET", f"/messages?peer_id={b}", 404, at)
    conn("consent", "request", at, b, 0)
    conn("consent", "accept", bt, a, 1)
    msg = f.call("qualified-text-send", "POST", "/messages", 200, at,
                 {"receiver_id": b, "content": "Fictional P0.2 text", "client_message_id": str(uuid4())})
    received = f.call("qualified-text-read", "GET", f"/messages?peer_id={a}", 200, bt)["items"]
    require(any(row["id"] == msg["id"] for row in received), "same persisted message")
    notices = f.call("qualified-notice-read", "GET", "/notifications", 200, bt)["items"]
    notice = next(row["id"] for row in notices if row.get("kind") == "message")

    command(f, ["qa:mariadb-identity", "revoke", str(a), f"--credential={a_cred}"], "revoke-a")
    identity(f, at, "revoked-a-denied", False)
    suspended = f.call("relationship-after-issuer-revoke", "GET", "/formal-relationships", 200, bt)["relationships"][0]
    require(suspended["state"] == "SUSPENDED_REVERIFY" and "resume" not in suspended["allowed_actions"], "issuer revocation invalidates formal relationship")
    f.call("revoked-identity-old-connection", "GET", f"/connections/{a}", 404, bt)
    f.call("revoked-identity-old-messages", "GET", f"/messages?peer_id={a}", 404, bt)
    replacement = issuer("a", "issue-fresh-a")
    resumed = action("resume", bt, suspended["revision"])
    require(resumed["confirmation_generation"] == 2 and not resumed["confirmed_me"] and not resumed["confirmed_peer"],
            "replacement cannot auto-activate")
    half = action("confirm", at, resumed["revision"])
    active = action("confirm", bt, half["revision"])
    require(active["state"] == "ACTIVE", "two new confirmations")
    f.call("block-pair", "POST", "/moderation/blocks", 200, bt, {"blocked_user_id": a})
    action("confirm", at, active["revision"], 409)
    action("end", guest, active["revision"], 404)
    f.call("blocked-old-connection", "GET", f"/connections/{b}", 404, at)
    f.call("blocked-old-messages", "GET", f"/messages?peer_id={a}", 404, bt)
    f.call("blocked-old-peer-link", "GET", f"/profile-peers/{a}", 404, bt)
    history = f.call("blocked-old-notification", "GET", f"/notifications/{notice}", 200, bt)["item"]
    require(history["availability"] == "history" and not history["payload"], "old notification stripped")
    old = f.call("blocked-old-proposal", "GET", f"/journey/history/{pid}", 200, at)
    require(not old["candidate_available"] and old["showcase"] is None and not old["connection_eligible"], "read-only safe history")
    for token in (at, bt):
        f.call("exit-after-block", "PUT", "/journey/participation", 200, token,
               {"action": "exit", "revision": 1, "intent": "End fixture participation"})
    reenrolled = f.call("re-enroll-next-generation", "PUT", "/journey/participation", 200, at,
                        {"action": "opt_in", "revision": 2, "intent": "Explicit new generation"})
    require(reenrolled["generation"] > 1, "fresh generation")
    f.call("old-generation-decision-denied", "POST", decision, 404, at, first)
    f.call("exit-next-generation", "PUT", "/journey/participation", 200, at,
           {"action": "exit", "revision": reenrolled["revision"], "intent": "End fixture"})
    close_round(f, admin, round_)

    for user, credential in ((a, replacement), (b, b_cred)):
        command(f, ["qa:mariadb-identity", "revoke", str(user), f"--credential={credential}"], "retire-run-credential")
    while time.monotonic() < deadline:
        time.sleep(min(3, deadline-time.monotonic()))
    identity(f, tokens["expires"], "natural-expiry-denied", False)
    state = {"a": a, "b": b, "first": a_cred, "replacement": replacement, "b_credential": b_cred,
             "expired_user": people["expires"]["id"], "expired_credential": expires,
             "proposal": pid, "relation": relation["id"], "connection": cn["connection"]["id"],
             "message": msg["id"], "notice": notice, "round": round_["id"]}
    check_persistence(f, state)
    with record.open("x", encoding="utf-8") as file:
        json.dump(state, file)


def check_persistence(f, state):
    ids = {key: int(state[key]) for key in ("a", "b", "expired_user", "connection", "message", "notice", "round")}
    safe = {key: str(UUID(state[key])) for key in ("first", "replacement", "b_credential", "expired_credential", "proposal", "relation")}
    outcome = f.php(rf"""
    use App\Services\MariaDbFixtureIdentity;
    $issuer = app(MariaDbFixtureIdentity::class);
    $relationship = DB::table('formal_relationships')->where('id','{safe['relation']}')->first();
    echo json_encode([
      DB::table('migrations')->count(),
      (bool)$relationship->test_only, $relationship->state, $relationship->request_source_kind,
      (int)$relationship->request_source_id, (int)$relationship->request_source_revision,
      DB::table('formal_relationship_slots')->where('relationship_id','{safe['relation']}')->count(),
      DB::table('match_proposals')->where('id','{safe['proposal']}')->value('state'),
      DB::table('dating_rounds')->where('id',{ids['round']})->value('state'),
      DB::table('chat_messages')->where('id',{ids['message']})->where('receiver_id',{ids['b']})->count(),
      DB::table('notifications')->where('id',{ids['notice']})->where('user_id',{ids['b']})->count(),
      DB::table('identity_assertions')->whereIn('id',['{safe['first']}','{safe['replacement']}','{safe['b_credential']}'])
        ->where('revision',2)->whereNotNull('revoked_at')->count(),
      DB::table('journey_audits')->where('aggregate_id','{safe['first']}')->where('action','MARIADB_TEST_ONLY_REVOKED')->count(),
      $issuer->credential({ids['a']}), $issuer->credential({ids['b']}), $issuer->credential({ids['expired_user']},'{safe['expired_credential']}'),
      DB::table('user_blocks')->where('blocker_id',{ids['b']})->where('blocked_user_id',{ids['a']})->count()
    ],JSON_THROW_ON_ERROR),PHP_EOL;""")
    require(outcome[0] >= 92 and outcome[1:] == [True, "ENDED", "connection", ids["connection"], 2, 0,
            "MUTUALLY_ACCEPTED", "closed", 1, 1, 3, 1, None, None, None, 1], "MariaDB durable authority and audit")
    print(f"MariaDB readback PASS: {outcome[0]} migrations, ended TEST_ONLY relationship, source version 2, "
          "no relationship slots, persisted text/notice/Block, three revoked credentials and one expired", flush=True)


def close_round(f, admin, round_):
    f.call("admin-close-round", "POST", f"/admin/matching/rounds/{round_['round_key']}/close", 200, admin,
           {"state_version": round_["state_version"], "reason_code": "fixture"},
           headers={"Idempotency-Key": str(uuid4()), "X-Matching-Confirmation": f"confirm:{round_['round_key']}:close"})


def proposal_expiry(f):
    people = seed(f)
    admin = f.login(support["seed"](f)["admin"]["phone"])["access_token"]
    subjects = []
    for key, gender in (("a", "male"), ("b", "female")):
        person = people[key]
        token = f.login(person["phone"])["access_token"]
        credential = str(UUID(command(f, ["qa:mariadb-identity", "issue", str(person["id"])], "expiry-fixture-issue")))
        enrollment(f, token, gender)
        subjects.append((person["id"], token, credential))
    round_ = run_round(f, admin, [row[1] for row in subjects])
    token = subjects[0][1]
    proposal = f.call("expiry-fixture-proposal", "GET", "/journey", 200, token)["proposal"]
    pid = str(UUID(proposal["id"]))
    changed = f.php(f"""echo json_encode(DB::table('match_proposals')->where('id','{pid}')
        ->where('round_id',{int(round_['id'])})->where('state','PENDING')
        ->update(['expires_at'=>now('UTC')->subSecond()])),PHP_EOL;""")
    require(changed == 1, "fault injection targets exactly this synthetic proposal")
    f.call("expired-proposal-accept-denied", "POST", f"/journey/proposals/{pid}/decision", 409, token,
           {"action": "accept", "revision": proposal["revision"], "idempotency_key": str(uuid4())})
    old = f.call("expired-proposal-history", "GET", f"/journey/history/{pid}", 200, token)
    require(old["state"] == "EXPIRED" and old["decision_me"] == "PENDING" and not old["candidate_available"],
            "expiry preserves the decision fact")
    require(f.php(f"echo json_encode(DB::table('match_proposal_slots')->where('proposal_id','{pid}')->count()),PHP_EOL;") == 0,
            "expired proposal releases both slots")
    for user, token, credential in subjects:
        f.call("exit-expiry-fixture", "PUT", "/journey/participation", 200, token,
               {"action": "exit", "revision": 1, "intent": "End fixture"})
        if user == subjects[0][0]:
            denied = f.php(rf"""use App\Services\MariaDbFixtureIdentity;
              User::whereKey({user})->where('synthetic_batch',MariaDbFixtureIdentity::DATASET)->update(['disabled'=>true]);
              echo json_encode(app(MariaDbFixtureIdentity::class)->credential({user}) === null),PHP_EOL;""")
            require(denied is True, "disabled credential automatically denied")
            f.call("disabled-subject-old-session", "GET", "/journey", 403, token)
        command(f, ["qa:mariadb-identity", "revoke", str(user), f"--credential={credential}"], "retire-expiry-fixture")
    close_round(f, admin, round_)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("compose_folder", type=Path)
    parser.add_argument("record", type=Path)
    parser.add_argument("--readback-only", action="store_true")
    parser.add_argument("--proposal-expiry-only", action="store_true")
    args = parser.parse_args()
    support = runpy.run_path(str(args.compose_folder / "function-smoke.py"))
    require = support["require"]
    fixture = support["Fixture"](args.compose_folder)
    if args.readback_only:
        check_persistence(fixture, json.loads(args.record.read_text(encoding="utf-8")))
    elif args.proposal_expiry_only:
        proposal_expiry(fixture)
    else:
        smoke(fixture, args.record)
    print("MariaDB signed relationship fixture: PASS", flush=True)
