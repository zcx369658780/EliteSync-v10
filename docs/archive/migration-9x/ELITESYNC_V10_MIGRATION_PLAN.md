# EliteSync-v10 Migration Plan

## 1. Migration Objective

EliteSync-v10 moves the product from the EliteSync 9.x historical development line to a clean development line with a minimal, current context. The migration preserves canonical application behavior and server-owned business truth while excluding historical process material from routine implementation work.

History is preserved, but not loaded into daily development context.

This plan freezes migration design only. It does not authorize source copying, code changes, deployment, database access, or runtime mutation.

## 2. Source Baseline

- Source repository: `zcx369658780/EliteSync`
- Source branch: GitHub `main`
- Baseline: `13277df80c3b82f33887ffe110d807ad79b38d8c`
- Target repository: `zcx369658780/EliteSync-v10`
- Target branch: GitHub `main`

Later migration must read source from the exact baseline Git tree, not from a retained or dirty 9.x worktree.

## 3. Migration Assets

### Application source

- `apps/flutter_elitesync_module` — canonical Flutter client candidate.
- `apps/android` — canonical Android host candidate.

### Backend

- `services/backend-laravel` — canonical Laravel backend candidate and source representation of server-owned business behavior.

### Infrastructure

- `infra` — infrastructure-definition candidate. Its files require item-level validation against observed runtime facts before migration.

### Database knowledge

- Laravel migrations under `services/backend-laravel/database/migrations`.
- Eloquent Models and their relationship definitions.
- Database schema knowledge established by source migrations and Models.
- Verified limits: the live database schema and applied migration state were not inspected, so repository schema knowledge is not proof of deployed database state.

Candidate presence is not bulk-copy authority. Each asset remains subject to later bounded path selection and validation.

## 4. Excluded Assets

The following are not migrated:

- `docs/version_plans`
- historical tasks
- handoff history
- acceptance reports
- blocker reports
- old governance corpus
- worktrees
- build artifacts, binaries, caches, and logs
- local machine state, local configuration, credentials, environment files, local databases, and device state
- legacy non-canonical paths `apps/flutter_elitesync` and `services/api`

These assets are EliteSync 9.x provenance or machine/runtime residue, not EliteSync-v10 daily development context. Exclusion does not delete or rewrite their history.

## 5. Migration Order

1. **Backend** — establish the canonical server API, authentication, authorization, business rules, queue contracts, storage contracts, and realtime interfaces first.
2. **Database migration context** — bring forward the Laravel migrations, Models, relationships, and schema assumptions required by the backend, while keeping deployed database state distinct from repository knowledge.
3. **Infrastructure** — evaluate and migrate only the definitions required to run the established backend and runtime dependencies.
4. **Flutter module** — migrate the canonical client against the established server contracts.
5. **Android host** — migrate the host after the Flutter module and its integration boundary are available.

This order follows dependency direction: server is canonical business truth; database context supports the server; infrastructure runs it; the Flutter client consumes its contracts; and the Android host integrates the client.

## 6. Backend Runtime Considerations

Facts captured in `ELITESYNC_BACKEND_SYSTEM_MAP.md`:

- The inspected Alibaba Cloud runtime reports Laravel `11.48.0` on PHP `8.4.18` at `/opt/elitesync/services/backend-laravel`.
- The deployed source tree contains 34 Model files and 57 migration files.
- The deployment is a copied tree without `.git`, so it does not expose an exact deployed commit identity.
- Selected deployed backend blobs match the source baseline, but deployed `routes/api.php` does not.
- The live route inventory contains 126 routes and includes a `process-demo` media route not present in the baseline route file.
- Redis, Nginx, and PHP-FPM were running at inspection.
- No Supervisor unit or Laravel queue-worker process was observed.
- The Workerman systemd unit was in an auto-restart state after exit status 1; its failure cause was not inspected.
- Live database contents, applied migrations, effective environment configuration, storage provider, and endpoint behavior were not inspected.

These are migration risks and evidence boundaries, not repair instructions.

## 7. Known Migration Risks

- GitHub baseline and the deployed backend route file differ; the origin and intended lifecycle of the live route delta are unknown.
- The deployment has no Git metadata, so selected blob matches do not establish a complete deployed revision identity.
- Repository runtime definitions and observed runtime state differ: Supervisor is part of the frozen architecture, but no Supervisor unit was present on the inspected host.
- Workerman and queue-worker runtime state was not healthy or complete at inspection.
- Repository Models and migrations do not prove the live database schema or applied migration set.
- Infrastructure files are candidates only and may not represent current deployed configuration.
- Effective authentication, admin allowlist, HTTPS enforcement, storage configuration, and matching-operation enablement remain unverified.
- Legacy paths `apps/flutter_elitesync` and `services/api` must remain excluded from canonical migration.
- Worktrees, artifacts, logs, credentials, environment files, and local state must not enter the v10 source line.

## 8. Next Step

The next phase is **Code migration preparation**: convert this frozen order and boundary into bounded, evidence-backed migration scopes, starting with the backend. This document does not create or authorize a specific task.
