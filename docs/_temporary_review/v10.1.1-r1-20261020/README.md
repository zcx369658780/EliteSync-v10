# v10.1.1 R1 concentrated review copy

Status: NOT_YET_ACCEPTED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE.
Only B1 and directly related lock coordination/testing safety fixes. Source and
original task identities are in identity.json. Final race comparisons include
real kernel routes, MariaDB REPEATABLE READ, precise user-lock wait barriers,
private response bytes/body flags and persisted interaction/notice side effects.

The baseline loads the unmodified two controllers exported from 34a0b0ed4209895cebd4ef040519ac13a8054b6c via PHP prepend;
all current-authority decision code remains original in that comparison. The
fixed comparison omits prepend. Both retain all raw failures/exit codes locally.
The independent loader contains machine paths and is LOCAL_ONLY; its original
controller blobs are d9f192c58cfec9a57bf74f1084c423c23f842893 and
75b9141d74ac667d502040a592653a49e1d900db.

All runtime claims are CODEX_REPORTED, not Astra-executed. Raw SQL, credentials,
responses, APKs, device logs/screenshots and physical paths remain LOCAL_ONLY.
Script copies use placeholders; their hashes differ from executed originals.
Product source/Feature/concurrency scripts are available directly on candidate.
Do not merge this temporary review branch to product/main or remove old refs.
