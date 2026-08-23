# EliteSync-v10 Local MariaDB Runtime Provisioning Report

## 1. Runtime Identity

Provisioning status: **BLOCKED — host connection identity unavailable**

- Docker client: `29.3.0`
- Docker server: `29.6.2` on Linux
- Image tag requested: `mariadb:10.11`
- Image digest: `mariadb@sha256:8020e05c4c498d06c87f0a1db010eb79bd6f8fb30e9b763d4690c34ce1e61008`
- Runtime MariaDB version: `10.11.18-MariaDB-ubu2204`
- Container name: `elitesync-v10-mariadb-local`
- Container ID: `d9fad232c2210850293214b2c80f4863c8bdaa7abd92aec245b55fd109f66c28`
- Container state: running, healthy
- Restart policy: `no`
- Network name: `elitesync-v10-mariadb-local-net`
- Network ID: `ed0eba3729e8f5acb7a12baab6e74bffe1691c752c208dc75a7b9d1cc559f61f`
- Network driver/internal state: bridge / `internal=true`
- Volume name: `elitesync-v10-mariadb-local-data`
- Volume driver/scope: local / local
- Volume mount: `/var/lib/mysql`
- Database name: `elitesync_v10_local`
- Username: `elitesync_v10_local`

The Docker daemon was started under this task's explicit authorization. No existing MySQL service was used or modified.

## 2. Isolation Validation

Passed:

- dedicated container identity;
- dedicated internal Docker network with one attached container;
- dedicated named volume, not a bind mount;
- no production endpoint, credential, mount, data, or route configured;
- existing machine MySQL listener on port `3306` was not used;
- database and user identity were confirmed from inside the dedicated container;
- database contained zero application tables before any migration.

Failed:

- requested HostConfig mapping: `127.0.0.1:43316 -> 3306/tcp`;
- effective Docker port state: `3306/tcp` has no published host binding;
- host listener count on port `43316`: 0;
- host connection to `127.0.0.1:43316`: refused.

The internal Docker network prevented the requested port from becoming an effective host mapping. Because host-side Laravel cannot reach this runtime, connection identity is incomplete and provisioning is not accepted as complete. The task stopped without rebuilding the container or weakening the network boundary.

## 3. Container / Database / User Status

- Container creation: succeeded
- Container health check: healthy
- MariaDB engine initialization: succeeded
- Dedicated database creation: succeeded
- Dedicated user creation: succeeded
- In-container identity query: succeeded
- Reported database: `elitesync_v10_local`
- Reported current user: `elitesync_v10_local@%`
- Reported container hostname: `d9fad232c221`
- Application table count: 0
- Host connection validation: failed
- Laravel migration execution: not entered

Credentials were generated as disposable, local-only random values and were not printed in command output or this report.

## 4. Files Created

Created local-only runtime configuration:

- `services/backend-laravel/.env`

The file is ignored by Git and contains only local loopback/runtime configuration plus the disposable database-user credential. It contains no production or shared value. Its current database endpoint is not usable because the effective Docker host port was not published.

Created report:

- `ELITESYNC_V10_LOCAL_MARIADB_RUNTIME_PROVISIONING_REPORT.md`

Not modified:

- backend source, config source, routes, migrations, Models, or Composer files;
- Flutter source, Android source, or infrastructure source.

No database file, credential, dump, backup, or container runtime state is staged for Git.

## 5. Rollback Identity

Exact disposable objects created by this attempt:

- Container: `elitesync-v10-mariadb-local` / `d9fad232c2210850293214b2c80f4863c8bdaa7abd92aec245b55fd109f66c28`
- Volume: `elitesync-v10-mariadb-local-data`
- Network: `elitesync-v10-mariadb-local-net` / `ed0eba3729e8f5acb7a12baab6e74bffe1691c752c208dc75a7b9d1cc559f61f`
- Local configuration: `services/backend-laravel/.env`

Rollback was not executed. Any future rollback must revalidate these exact identities immediately before removing the container, volume, network, or local configuration. The pulled image is not classified as an exclusive rollback target because Docker images may be shared across containers.

## 6. Known Limitations

- The runtime is healthy only inside Docker's internal network and is not reachable from host Laravel.
- The local `.env` therefore does not yet provide a valid application connection path.
- Repair would require a separately authorized network/container recreation or another proven local connectivity design.
- Docker Desktop remains running and the blocked container remains running for evidence and future explicit disposition.
- MariaDB migration compatibility, schema creation, application connectivity, Queue, Redis, and production parity remain unvalidated.

No production database accessed.

No production data used.

No migration executed.

No seed, dump, restore, Alibaba Cloud, server, or existing MySQL operation was performed.
