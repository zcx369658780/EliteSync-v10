#!/usr/bin/env python3
"""Check the dedicated MariaDB and its volume before migration or restore."""
import argparse
import json
import re
import subprocess


def run(*command, data=None):
    return subprocess.run(command, input=data, capture_output=True, text=True, check=True).stdout.strip()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify(args):
    require(re.fullmatch(r"elitesync-v2-shared-staging(?:-[a-z0-9-]+)?", args.project), "project outside Staging")
    beta_staging = args.schema.startswith("elitesync_v2_beta_")
    if beta_staging:
        require(re.fullmatch(r"elitesync-v2-shared-staging-beta(?:-[a-z0-9-]+)?", args.project), "project outside Beta Staging")
        require(re.fullmatch(r"elitesync_v2_beta_[a-z0-9_]{1,46}", args.schema), "schema outside Beta Staging")
        require(re.fullmatch(r"elitesync_v2_beta_[a-z0-9_]{1,46}", args.username), "user outside Beta Staging")
    else:
        require(re.fullmatch(r"elitesync_v2_shared_staging(?:_[a-z0-9_]+)?", args.schema), "schema outside Staging")
        require(args.username == "elitesync_staging_app", "unexpected shared Staging user")
    require(args.server_id > 0 and args.server_id not in (1, 2621111, 2621121), "protected or invalid server ID")
    require(re.fullmatch(r"[a-zA-Z0-9_-]{12,80}", args.instance), "invalid instance ID")
    compose = ["docker", "compose", "--project-name", args.project, "--env-file", args.env, "-f", args.compose]
    config = json.loads(run(*compose, "config", "--format", "json"))
    services = config["services"]
    app = services["staging-app"]["environment"]
    db = services["staging-db"]
    require(app["APP_ENV"] == "staging" and app["APP_DEBUG"] == "false", "environment")
    require(app["STAGING_INSTANCE_ID"] == args.instance, "application instance")
    require((app["DB_CONNECTION"], app["DB_HOST"], app["DB_PORT"], app["DB_DATABASE"], app["DB_USERNAME"])
            == ("mariadb", "staging-db", "3306", args.schema, args.username) and not app["DB_URL"], "application database target")
    require(not db.get("ports") and db["environment"]["MARIADB_DATABASE"] == args.schema
            and db["environment"]["MARIADB_USER"] == args.username, "database exposure or identity")
    if beta_staging:
        require(app["V1007_LOCAL_RESTORATION"] == "false"
                and app["MATCHING_FOUNDATION_WEBSOCKET_ENABLED"] == "false"
                and "staging-ws" not in services, "Beta Staging messaging must stay disabled")
    require(config["networks"]["data"]["internal"], "data network not internal")
    require(not services["staging-app"].get("ports") and not services["staging-worker"].get("ports"), "non-edge port")
    require(all(p.get("host_ip") == "127.0.0.1" for p in services["staging-edge"].get("ports", [])), "edge is not loopback")
    db_id = run(*compose, "ps", "-q", "staging-db")
    require(db_id, "database container unavailable")
    container = json.loads(run("docker", "inspect", db_id))[0]
    labels = container["Config"]["Labels"]
    require(labels.get("com.docker.compose.project") == args.project
            and labels.get("org.elitesync.staging.instance") == args.instance, "container identity")
    require(not container["HostConfig"].get("PortBindings"), "database has host bindings")
    mounts = {item["Destination"]: item for item in container["Mounts"]}
    expected_volume = args.project + "_staging-dbdata"
    require(mounts.get("/var/lib/mysql", {}).get("Name") == expected_volume, "database volume identity")
    for purpose in ("dbdata", "storage"):
        volume_name = args.project + "_staging-" + purpose
        volume_labels = json.loads(run("docker", "volume", "inspect", volume_name))[0]["Labels"]
        require(volume_labels.get("com.docker.compose.project") == args.project
                and volume_labels.get("org.elitesync.staging.instance") == args.instance, "volume labels")
    sql = ("SELECT DATABASE(), VERSION(), @@server_id, CURRENT_USER(), "
           "(SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE());")
    result = run(*compose, "exec", "-T", "staging-db", "sh", "-ec",
                 'export MYSQL_PWD="$(cat /run/secrets/r0_db_password)"; '
                 'exec mariadb -N -B -u "$1" "$MARIADB_DATABASE" -e "$2"', "sh", args.username, sql)
    schema, version, server_id, login, tables = result.split("\t")
    require(schema == args.schema and re.match(r"^10\.11\..*MariaDB", version) and int(server_id) == args.server_id
            and login == args.username + "@%", "live SQL identity")
    require(not args.empty or tables == "0", "target schema must be empty")
    print(json.dumps({"instance": args.instance, "project": args.project, "schema": schema,
                      "server_id": int(server_id), "version": version, "tables": int(tables),
                      "db_volume": expected_volume}, sort_keys=True))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ("compose", "env", "project", "schema", "instance"):
        parser.add_argument("--" + key, required=True)
    parser.add_argument("--username", default="elitesync_staging_app")
    parser.add_argument("--server-id", type=int, required=True)
    parser.add_argument("--empty", action="store_true")
    try:
        verify(parser.parse_args())
    except (ValueError, KeyError, subprocess.CalledProcessError) as error:
        reason = str(error) if not isinstance(error, subprocess.CalledProcessError) else "Docker or SQL identity query failed"
        parser.exit(1, "Staging database check refused: " + reason + "\n")
