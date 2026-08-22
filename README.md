# EliteSync

## Product Vision

EliteSync is a slow-dating product designed to support deliberate, meaningful connections rather than high-volume matching.

## Current Stage

EliteSync-v10 is in the repository bootstrap phase. This repository currently establishes the minimal product, architecture, migration-boundary, and development context required before implementation begins.

## Technology Stack

- Flutter client
- Android host
- Laravel backend
- MariaDB database

## Repository Structure

The intended canonical implementation paths are:

- `apps/flutter_elitesync_module` — Flutter client
- `apps/android` — Android host
- `services/backend-laravel` — Laravel backend
- `infra` — infrastructure definitions introduced only through future scoped work

These paths are migration candidates and are not populated by this bootstrap.

## Development Overview

Development proceeds through bounded implementation work against GitHub `main`. Architecture and migration boundaries are documented separately, and changes should be validated in proportion to their scope.
