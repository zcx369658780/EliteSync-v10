# EliteSync-v10 Agent Rules

## Project identity

EliteSync-v10 is the new architecture authority for EliteSync 10.0.

EliteSync 9.x is a historical asset source. Historical assets may inform research, but its architecture, governance, task chains, roadmaps, and migration constraints do not govern v10.

## Current phase

Current phase: Product and Architecture Design.

The repository is not in product implementation mode. Architecture and product decisions must be reviewed before they authorize code, schema, API, migration, or service work.

## Roles

- Owner: final product authority.
- ChatGPT: architecture and product reviewer.
- Codex: bounded implementation and research agent operating only within the current task scope.

No agent may substitute its own approval for Owner authority or the required review gate.

## Forbidden actions

- Do not restore or reproduce EliteSync 9.x architecture as the v10 target.
- Do not create product code before the relevant architecture decision is reviewed and authorized.
- Do not automatically migrate legacy constraints, APIs, schemas, service boundaries, roadmaps, or governance.
- Do not treat historical reports or migrated source as current architecture authority.
- Do not expand a research or documentation task into backend, Flutter, Android, database, API, infrastructure, or deployment changes.

## Documentation rules

- System and domain architecture belongs in `docs/architecture/`.
- Product requirements, product decisions, and user journeys belong in `docs/product/`.
- Competitor analysis and other research materials belong in `docs/research/`.
- Architecture Decision Records belong in `docs/decisions/`.
- Historical migration and runtime evidence belongs in `docs/archive/`.

Keep evidence, proposals, reviewed decisions, and implementation authorization visibly distinct. Moving a document into an active directory does not itself make it an accepted decision.

## Working boundaries

- Preserve unrelated user changes and dirty-worktree evidence.
- Prefer bounded, reviewable changes.
- Never delete historical evidence during workspace organization; archive it with provenance intact.
- Stop for Owner direction when a file's authority or classification is ambiguous.
