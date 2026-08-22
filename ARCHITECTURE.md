# Architecture

## Canonical Components

- Canonical Client: `apps/flutter_elitesync_module`
- Android Host: `apps/android`
- Backend: `services/backend-laravel`
- Database: MariaDB

Server remains business truth.

## Runtime

- Redis
- Laravel Queue
- Supervisor
- Workerman
- Laravel media storage

## Legacy Candidates

- `apps/flutter_elitesync`
- `services/api`

Legacy candidates are not EliteSync-v10 canonical source. Any future migration or retirement decision requires separately scoped work.
