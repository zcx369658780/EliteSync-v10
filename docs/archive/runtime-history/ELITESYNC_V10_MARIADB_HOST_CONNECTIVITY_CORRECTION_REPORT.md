# EliteSync-v10 MariaDB Host Connectivity Correction Report

## 1. Before State

MariaDB runtime before correction:

- Container: `elitesync-v10-mariadb-local`
- Container ID: `d9fad232c2210850293214b2c80f4863c8bdaa7abd92aec245b55fd109f66c28`
- Image ID: `sha256:8020e05c4c498d06c87f0a1db010eb79bd6f8fb30e9b763d4690c34ce1e61008`
- MariaDB: `10.11.18-MariaDB-ubu2204`
- State: running / healthy
- Network: `elitesync-v10-mariadb-local-net`
- Network ID: `ed0eba3729e8f5acb7a12baab6e74bffe1691c752c208dc75a7b9d1cc559f61f`
- Network boundary: bridge / `internal=true`
- Volume: `elitesync-v10-mariadb-local-data`
- Database: `elitesync_v10_local`
- User: `elitesync_v10_local@%`
- Application table count: 0

The container HostConfig requested `127.0.0.1:43316 -> 3306/tcp`, but its effective published-port set was empty. The host had no listener on port `43316` and could not connect.

The existing machine MySQL service on port `3306` remained running but was not connected to, reused, stopped, or modified.

## 2. Diagnosis

The MariaDB engine, database, user, internal network, and volume were healthy and identity-valid. The failure was confined to host publication: Docker did not create an effective published port for the database container while it used only the internal network.

Docker does not support safely adding a published port to an already running container without container recreation. Recreating or deleting the database container was explicitly prohibited. Attaching the MariaDB container directly to a non-internal network would also weaken its isolation boundary.

The selected correction was therefore a credential-free TCP sidecar. It preserves the MariaDB container and volume unchanged, publishes only a loopback endpoint, and forwards only to the named MariaDB container on the existing internal network.

An initial host identity query using the standalone `mysql.exe` client reached the server but failed because that client could not load its local `mysql_native_password` plugin. No server authentication setting was changed. The authoritative host validation then used PHP 8.5.3 `pdo_mysql`, which is the Laravel host runtime path, and succeeded.

## 3. Correction Performed

Pulled and fixed proxy image:

- `alpine/socat@sha256:3d9e7966201dd3a065df591020a09fd3c70845de7e7086e3531ea69db774406b`

Created dedicated host-publication network:

- Name: `elitesync-v10-mariadb-host-net`
- ID: `968f96426740f30aa39cd9f5fa7ee0ccb40a600272380248ddeb260c3e42215a`
- Driver: bridge
- Attached containers: 1

Created loopback proxy container:

- Name: `elitesync-v10-mariadb-loopback-proxy`
- ID: `505598c1440e042320d5be658dc2b10e24eea2dc8833b5dcd3c51ac1852d78a9`
- Restart policy: `no`
- Networks: `elitesync-v10-mariadb-host-net` and `elitesync-v10-mariadb-local-net`
- Published endpoint: `127.0.0.1:43316`
- Fixed forwarding target: `elitesync-v10-mariadb-local:3306`
- Volume mounts: none
- Database credentials: none

The MariaDB container was not deleted, recreated, restarted, reconfigured, or attached to the host-publication network. Its internal network and data volume identities remain unchanged.

## 4. Final Runtime Identity

Host validation path:

`PHP 8.5.3 pdo_mysql -> 127.0.0.1:43316 -> loopback proxy -> internal Docker network -> elitesync-v10-mariadb-local:3306`

Validation result:

- PHP `pdo_mysql` available: yes
- Host connection exit status: 0
- MariaDB version: `10.11.18-MariaDB-ubu2204`
- Version provider: `mariadb.org binary distribution`
- Database: `elitesync_v10_local`
- Current user: `elitesync_v10_local@%`
- Database container hostname: `d9fad232c221`
- Application table count: 0
- Effective loopback listener count on port `43316`: 1

The database, user, MariaDB engine, database container ID, volume, and internal-network identity are unchanged from the pre-correction state.

## 5. Rollback Identity

Connectivity-only objects created by this correction:

- Proxy container: `elitesync-v10-mariadb-loopback-proxy` / `505598c1440e042320d5be658dc2b10e24eea2dc8833b5dcd3c51ac1852d78a9`
- Host-publication network: `elitesync-v10-mariadb-host-net` / `968f96426740f30aa39cd9f5fa7ee0ccb40a600272380248ddeb260c3e42215a`

Future connectivity rollback must first revalidate these exact IDs, then remove only the proxy container followed by the dedicated host-publication network. It must not remove or alter:

- `elitesync-v10-mariadb-local`;
- `elitesync-v10-mariadb-local-data`;
- `elitesync-v10-mariadb-local-net`;
- `services/backend-laravel/.env` unless separately authorized.

Rollback was not executed in this task. The proxy image is not classified as an exclusive rollback target because Docker images may be shared.

## 6. Safety Validation

- Host endpoint is loopback-only: `127.0.0.1:43316`.
- MariaDB remains attached only to its dedicated internal network.
- Proxy contains no database credential and has no volume mount.
- Proxy forwards to one fixed internal container/port target.
- Existing machine MySQL port `3306` was not used.
- Database and volume identity remained unchanged.
- Backend source, migrations, Models, routes, config, Composer files, Flutter source, and Android source were not modified.
- Local `.env` was used only in-memory for the PHP PDO identity check; its values were not printed or changed.

No production database accessed.

No production data used.

No migration executed.

No seed, dump, restore, Alibaba Cloud, server, existing MySQL, Queue, Redis, or Workerman operation was performed.
