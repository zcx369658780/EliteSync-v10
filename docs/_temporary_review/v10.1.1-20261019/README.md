# v10.1.1 temporary review evidence

**CODEX_REPORTED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED**

This is the public redacted copy under the current TEMP_REVIEW_EVIDENCE_PROTOCOL. It must not merge into product/main. Raw APKs, SQL, config, tokens, device identifiers, IP addresses, screenshots, logs and private conversation records remain LOCAL_ONLY. Original execution output is not uploaded; receipt hashes and exit values are reported, not independently re-executed by Astra.

`identity.json` binds source, candidate, report blob, product trees and artifact. `changed-paths.tsv` enumerates the change. Runtime JSON files contain selected redacted results. Overlapping test suites are not additive. Script copies replace private roots with `LOCAL_ONLY_ROOT`; required local credentials and runtime fixtures are intentionally absent. These copies are for source inspection, not ready-to-run deployment instructions. Original execution-source and review-copy hashes are distinct.

call7 is synthetic AVD audio/video on the earlier x86 package. call14 uses the final same dual-ABI APK on phone and AVD, proves audio transport, Owner-confirmed AVD-to-phone tone, and revocation. It does not prove final-package phone video, reverse human hearing, or AEC. Saved pre-revocation JWTs were issued by the official product issuer in a controlled fixture, not extracted from APP storage.

The 20-minute UDP authorization was used once and closed early; its exact temporary rule and AVD mapping were removed. All owned test services and containers stopped; volumes, artifacts and backups retained. No cloud/main/successor work is authorized by this package.

Historical field clarification: the inspected `scripts/rtc-final-revoke.py` retains its original contemporaneous `same_final_apk_both_sides` output field. The selected call7 JSON renames that field to `same_prior_x86_apk_both_sides` and supplies the original x86 artifact hash; raw historical receipts are unchanged LOCAL_ONLY. This is a schema/name clarification, not a claim of final dual-ABI video.

Hash convention: review-copy SHA256 and FILES_SHA256 describe canonical public LF bytes. Original execution-source hashes describe preserved LOCAL_ONLY bytes and may use CRLF. An initial public-manifest mismatch from Git normalization was detected and corrected without changing product source or raw evidence.
