# EliteSync-v10 Backend Source Migration Plan

## 1. Objective

The objective is to migrate the canonical EliteSync 9.x Laravel backend into EliteSync-v10 while preserving its business capabilities and server-owned business truth.

The migration will not bring forward historical governance, production environment state, production data, credentials, or machine residue. This plan describes a future execution sequence; it is not execution authorization.

## 2. Source Boundary

- Source repository: `zcx369658780/EliteSync`
- Source path: `services/backend-laravel`
- Source baseline: `13277df80c3b82f33887ffe110d807ad79b38d8c`
- Target repository: `zcx369658780/EliteSync-v10`
- Intended target path: `services/backend-laravel`

Future execution must read from the exact baseline Git tree, not a retained worktree or cloud deployment copy.

## 3. Backend Assets To Migrate

### Application code

Candidate source assets are:

- `app/` — controllers, middleware, Models, Services, Jobs, Console Commands, providers, and other application classes.
- `routes/` — API, web, and console route definitions from the baseline.
- `config/` — version-controlled Laravel configuration definitions without runtime secrets.
- `resources/` — version-controlled Laravel resources.
- `bootstrap/`, `public/`, `tests/`, and backend-local `tools/` and `docker/` content where present and required by the canonical backend.
- Laravel project files including `artisan`, `composer.json`, `composer.lock`, `package.json`, `phpunit.xml`, and version-controlled build/configuration manifests.

Candidate status does not authorize copying in this phase. Generated or local content under these paths remains excluded.

### Database context

Code and knowledge candidates are:

- `database/migrations`.
- Eloquent Models under `app/Models`.
- Version-controlled factories and seeders, subject to later path review.
- Schema and relationship knowledge documented from migrations and Models.

Only code and schema knowledge are candidates. Production database data, live schema state, migration-table state, dumps, and backups are not migrated.

### Runtime configuration

May migrate later:

- Version-controlled configuration templates such as `.env.example`.
- Version-controlled runtime descriptions and service templates required to explain the backend contract.
- Non-secret defaults contained in source-controlled Laravel configuration.

Must not migrate:

- `.env` or any effective environment file.
- Credentials, tokens, keys, passwords, certificates, or secrets.
- Host-specific values, runtime process state, or machine-specific configuration.

## 4. Backend Assets NOT To Migrate

- `.env` and environment-specific overrides.
- Credentials and production secrets.
- Runtime logs, including tracked or local log residue.
- Framework, application, and opcode caches.
- Generated storage files, uploaded media, session data, and runtime filesystem contents.
- `vendor/` generated dependency state and `node_modules/`.
- Local databases, backups, dumps, worktrees, IDE files, and local machine state.
- Cloud deployment residue, copied-release metadata, service state, process state, and host-specific permissions.
- Historical governance, tasks, handoffs, acceptance reports, blocker reports, and archive material.

These exclusions remain provenance or runtime evidence; they are not v10 application source.

## 5. Cloud Runtime Difference Handling

Facts captured in `ELITESYNC_BACKEND_SYSTEM_MAP.md`:

- Cloud PHP version: `8.4.18`.
- Cloud Laravel version: `11.48.0`.
- Deployed source inventory: 34 Model files and 57 migration files.
- Live route inventory: 126 routes.
- The deployed `routes/api.php` blob differs from the GitHub baseline blob.
- The deployed environment contains `POST /api/v1/media/{assetId}/process-demo`; that route is absent from the baseline route file.
- The deployed tree has no `.git` directory and therefore exposes no complete Git revision identity.
- Selected deployed backend blobs match the baseline, but this does not establish full-tree identity.
- No Supervisor unit or Laravel queue-worker process was observed.
- The Workerman unit was in `activating/auto-restart` after exit status 1, with no matching `artisan chat:ws` process observed.

This plan does not determine whether the GitHub or deployed route variant is correct. The route drift and its provenance require a later Owner/Reviewer decision before backend source migration execution can claim a complete source boundary.

## 6. Migration Order

Future execution order:

1. Create the backend source copy in EliteSync-v10 from the exact GitHub baseline and an explicit path allowlist.
2. Review the configuration boundary so templates and non-secret defaults are separated from environment state.
3. Review database migration context: migrations, Models, relationships, factories, seeders, and documented schema knowledge, without accessing production data.
4. Validate backend structure and the intended Laravel project boundary.
5. Connect frontend contracts only in a later phase after the backend boundary is established.

No step is executed by this plan.

## 7. Validation Requirements

Future authorized migration must verify in the v10 environment that:

- Laravel boots without relying on excluded local or cloud state.
- Declared dependencies resolve from committed manifests and lock files.
- Routes load and the resulting route inventory is recorded.
- Migration files and Models are present and discoverable.
- Configuration uses clean templates and contains no `.env`, credential, secret, or machine-specific content.
- Only explicitly allowed backend paths changed.
- No production endpoint, database migration, queue operation, deployment, or server mutation is performed as part of source validation.

## 8. Known Risks

- GitHub baseline and cloud `routes/api.php` differ.
- The deployed-only `process-demo` route has unresolved provenance and authority.
- The cloud deployment lacks Git metadata, so its complete source identity is unknown.
- Live database schema and applied migration state were not inspected.
- Repository database knowledge does not prove production schema state.
- Supervisor is part of the frozen architecture, but no Supervisor unit was present on the inspected host.
- No Laravel queue-worker process was observed.
- Workerman was not in a stable running state at inspection.
- Effective runtime environment, authentication settings, storage provider, filesystem links, and endpoint behavior remain partly unverified.
- Generated, secret, local, and cloud-residue files may coexist with source paths and must remain outside the migration boundary.

## 9. Next Step

The next phase is **Backend Source Migration Execution**. It requires new explicit authorization identifying the exact source and target path allowlists, treatment of the route drift, validation commands, and commit/push boundary.
