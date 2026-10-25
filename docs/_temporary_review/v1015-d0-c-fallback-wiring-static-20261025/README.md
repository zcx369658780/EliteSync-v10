# v10.1.5 D0-C aggregate fallback wiring: static source review

Task Blob: `99862cba631dbb5569049bb7f71c7632e195bfa0`.
Candidate base: `5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`.
This is a minimal public source evidence package, not a runnable test bundle.
No PowerShell source was loaded or executed and no Serializer was called in this
task. Gate 2 remains NOT_RUN and its one 15-second budget remains unconsumed.

Only the Writer Serializer statement is wrapped. `revised/fixture.ps1:8` keeps
the sibling dot-source, line 7 binds control.runId to RunId, line 95 constructs
the same body with runId=RunId, and line 96 calls the real Write-Aggregate.
`revised/receipt_writer.ps1:145` uses the unchanged parser factory and body.
On its exception, lines 147-151 retain the first error, set aggregate-level
field/type metadata and call the existing Write-IndependentFailure.
That function's manual JSON construction, failure state and independent atomic
publisher (96-105) remain byte-identical. The publisher (82-95) uses only
DeserializeObject, validates schema/run binding/metadata hash, strictly encodes
UTF-8, checks readback hash, moves the same-directory temp file and checks the
published hash. It does not serialize the aggregate or call Write-Aggregate.

If independent fallback succeeds, the original error is rethrown at line 158.
If it fails, line 155 throws AggregateException with the original aggregate
exception first and the fallback exception second. Neither branch returns a
successful aggregate or creates READY/PASS. This is a source-level contract,
not an observation of exception propagation, a valid receipt or atomic IO.

The two-field projection and type rejection paths before the Serializer are
unchanged and remain outside the added catch. Existing receipt methods and
fallback behavior are untouched. The configured Writer outputRoot is retained;
no new directory policy or schema is introduced. fixture/schema/plan are exact
copies of the Gate 1 accepted sources. The historical synthetic C-drive Unicode
path literal is a test value, not a personal location. Historical relative
sibling references are source only; no control files, runtime outputs, personal
paths, device identities, private logs, environment snapshots or C# drafts are
included. Do not execute the fixture main flow during this static review.

Review source hashes and minimal.diff, then the independent non-author seven
checks. This branch is temporary review evidence and must not merge into main
or the product branch. Static PASS still requires Astra independent review;
it does not authorize Gate 2, the 37-case suite or any downstream runtime.
