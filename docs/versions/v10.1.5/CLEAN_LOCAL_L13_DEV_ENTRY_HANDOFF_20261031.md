# Clean Laravel13 candidate entry handoff
Services stopped; old Laravel11 remains default; Astra review pending.

CLEAN_L13_DEV_20261031 resolves through the Owner's LOCAL_ONLY source identity/completion receipt. Exact fresh-main source and new114-package vendor are preserved there. Private runtime config, test keys, synthetic DB and raw evidence stay on this machine.

## Explicit manual operation
Public scripts: clean_local_l13_dev/start-existing-dev.ps1 and stop-existing-dev.ps1. Local copies and entry-config-LOCAL_ONLY.json are in the task-owned manual directory. In existing PowerShell7, explicitly invoke the desired script with -ConfigPath pointing to that local JSON after Owner/Astra decides to use this candidate. This never reopens the sealed task ledger/budget or changes default/autostart pointers.

Start checks existing local Linux engine/context, Docker signature/hash, source HEAD/clean state, ownership/non-root/read-only containers, frontend no-masquerade and127.0.0.1 binding. It starts only the preserved own DB/API, with at most20 health attempts; readiness failure stops both. No pull/install/build/migrate/seed/solve, Desktop/WSL start, firewall edit or old-resource access. Stop validates ownership and stops only those two, deleting nothing. Missing/changed resources or port conflicts require review; do not bypass guards or recreate automatically.

Scripts passed parser checks. They were not stop/start tested after final shutdown because restart allowance was2/2; manual restart continuity after STOP remains NOT_RUN. Actual Windows HTTP was tested on the final container configuration.

## Gaps and rollback
Root question_bank JSON is not mounted into backend-only containers: optional regression remains58/60 passing with2 seed-input errors. Migration/seed allowances were conservatively fully charged; no extra seed/retest. Do not blanket-seed/fresh any existing DB. Any future mount correction must preserve accepted root assets and use applicable new authorization/budget.

Populated MariaDB process restart/recovery was not tested; synthetic data survived API recreation. Seven synthetic L11→L13 framework-binary session cases passed, not real user cookies, old keys, production or full APP/device E2E. Complete OS egress/exposure enforcement remains unproven.

All task services are stopped, all new files/images/volumes retained. Original Laravel11 and11066-file backup are untouched/default, so no rollback action is needed. To reject this entry leave it stopped and preserve evidence; do not reset/clean/move/delete assets, restore old DB or switch PATH/shortcuts. Further cleanup/default switch/runtime work needs applicable authorization.

No main merge, FUNCTION_ACCEPTED, AC05/G2 closure, production or v10.1.6 is authorized.
