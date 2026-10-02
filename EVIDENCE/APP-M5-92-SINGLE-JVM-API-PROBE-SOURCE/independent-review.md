# M5-92 independent GPT-6.1 Sol/high review
Reviewer: m587_review. Required, SOURCE-ONLY.

1. Invoke-GroovyApiProbe.ps1 lines 282-284: PREWRITE_DENIED replaces captured first/phase with a new exception without original disclosure.
2. Lines 260-269: mode/version/className lack string type checks; PowerShell array comparison permits equal single-element arrays through strict schema.
3. Line 37: hash create/compute failure followed by Dispose failure silently drops secondary.
4. Lines 98-105: unparenthesized mixed -or/-and integer type tests can swallow earlier authority rejection in the accepted int branch.

Seven authorized files each ReadAllBytes1/strictUTF8. Further disk reads, external reads/hash/enumeration, Parser/Process/JVM, writes all0. Cached-memory display only. Three candidates nativeAdd text and B hashes agree; original A/B exit0/truncated=false. Findings are static; failure paths NOT_EXERCISED. Review does not replace Work verdict.
