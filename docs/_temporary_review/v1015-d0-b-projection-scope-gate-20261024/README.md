# v10.1.5 D0-B Gate 1 static review sources

Task Blob: `38667356cb487acc4d8fc0994f894eabf3fb82e0`.
Candidate base: `a9bb54d78e357ce15bf673a654baa849e264a32f`.

This is the minimal public-safe source review copy. It is not a runnable package,
fixture result, runtime proof, accepted product, or authorization to execute.
No source in this package was loaded, compiled, or executed in this task.

Review original versus revised sources and minimal.diff. The schema and 37-case
plan are byte-identical to the fixed originals. `fixture.ps1:8` dot-sources its
sibling Writer, line 95 constructs the same 13-field aggregate, and line 96 now
calls `Write-Aggregate`. The native function at `receipt_writer.ps1:127` checks
only the literal full paths `$.started` and `$.finished`, validates both before
the only two dictionary replacements (142-143), then passes that same body to
the unchanged parser factory at line 144. Other fields and case values are not
traversed, converted, or reassigned. The historical C# draft is unused and kept
LOCAL_ONLY; it is not part of this call chain.

Null, non-string and unexpected base types throw before serialization and file
publication. The existing receipt fallback and atomic publication code retain
their original bytes. The new aggregate function only produces JSON for the
existing fixture publication tail; it does not claim an added aggregate fallback.

The synthetic `C:` Unicode-path literal in the historical fixture is a test value,
not a personal path. External sibling names are source references only; no control
file, environment snapshot, device identity, private log, or fixture output is
included. Do not run these historical tests as part of this static review.

Runtime types after projection: NOT_OBSERVED. D0-A remains one consumed diagnosis,
15 Serialize attempts, about 0.688 seconds; no rerun. Target fixture, full 37-case
suite, Sandbox, Flutter/Gradle, Producer, libs.jar and 30 resolutions: NOT_RUN.

The independent non-author review is evidence for static Gate 1 only. Astra must
make the separate independent disposition. Do not merge this review branch into
main or the product candidate. Cleanup requires its own precise later instruction.
