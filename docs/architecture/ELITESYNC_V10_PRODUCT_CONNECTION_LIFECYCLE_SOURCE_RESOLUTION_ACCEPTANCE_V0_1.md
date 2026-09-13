# EliteSync v10｜Product Connection Lifecycle Source Resolution Acceptance｜v0.1

Status: `ACCEPTED — APP-T06 LIFECYCLE SOURCE RESOLVED FOR EXISTING AGGREGATE/REQUEST — ONE OWNER PRODUCT-LIFECYCLE GAP RETAINED — NO TECHNICAL-DESIGN OR IMPLEMENTATION AUTHORITY CREATED`

Date: 2026-09-13 (Asia/Singapore)

Accepted candidate:

`f20849c51aef722334b7bef526e7bd932e4aa018`

Accepted result blob:

`43aea0fbaf3f837ab03032c5390fd2a3af956e3c`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_LIFECYCLE_SOURCE_RESOLUTION_RESULT_V0_1.md`

## 1. Independent acceptance

The BA-04-SR01 source-resolution candidate is accepted for its authorized governance/source-resolution purpose.

It establishes that APP-T06 is the accepted Product Connection lifecycle source for the existing Connection/request aggregate, with explicit acceptance provenance and unchanged result blob at current main.

The source resolves pause, close, resume, expiry source/actor, and terminality for the existing aggregate/request. It does not resolve whether a later Product Connection lifecycle may begin after a terminal outcome or whether any such later lifecycle must use a new aggregate/request.

No lifecycle rule was invented, and no BA-04 technical design or backend implementation was performed.

## 2. Accepted source-supported lifecycle rules

For the existing aggregate/request, the accepted direct transitions are:

- `CN_NONE -> CN_PENDING`: request, either eligible candidate acting as initiator/requester;
- `CN_PENDING -> CN_ACTIVE`: accept, recipient only;
- `CN_PENDING -> CN_DECLINED`: decline, recipient only;
- `CN_PENDING -> CN_WITHDRAWN`: withdraw, requester/initiator only;
- `CN_PENDING -> CN_EXPIRED`: system with an established expiry policy;
- `CN_ACTIVE -> CN_PAUSED`: either connected participant may pause;
- `CN_ACTIVE -> CN_CLOSED`: either connected participant may close;
- `CN_PAUSED -> CN_ACTIVE`: resume by the participant who paused;
- `CN_PAUSED -> CN_CLOSED`: either connected participant may close.

Any unlisted direct transition is invalid for the existing aggregate/request.

The exact expiry duration/policy remains `UNKNOWN` and is not decided here.

## 3. Accepted terminality boundary

- `CN_CLOSED` has no successor for this Connection.
- `CN_DECLINED`, `CN_WITHDRAWN`, and `CN_EXPIRED` have no successor for this request.

This terminality is accepted only for the existing aggregate/request. It does not itself decide whether a later, distinct Product Connection lifecycle may be initiated.

## 4. Retained Owner product-lifecycle gap

Exactly one product-lifecycle decision remains:

1. whether a later Product Connection lifecycle may be initiated after `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, or `CN_EXPIRED`; and
2. if yes, whether it must be represented by a new Connection aggregate/request rather than reopening or mutating the terminal old aggregate/request.

The retained gap must be closed by explicit Owner product authority before BA-04 can claim a complete lifecycle matrix.

## 5. Preserved boundaries

This acceptance preserves:

- `Match != Connection != Conversation != Relationship`;
- recipient acceptance of the same `CN_PENDING` as the sole consent-establishing transition to `CN_ACTIVE`;
- no direct `CN_NONE -> CN_ACTIVE`;
- Match mutual acceptance does not create Connection consent;
- decline, withdrawal, expiry, and close are not guilt, Safety findings, punishment, fraud, deception, or objective incompatibility;
- Connection authority remains separate from messaging consent and Conversation authority;
- no backend/API/schema/storage/service/client implementation authority is created;
- Track-2/material-fact/legal blockers remain unchanged.

## 6. Next gate

BA-04 technical design remains blocked only on the retained Owner product-lifecycle decision in section 4.

Once that decision is explicitly closed and recorded, BA-04 may be re-dispatched under a new exact task sheet using APP-T06 as the accepted lifecycle source plus the Owner-accepted restart/new-aggregate rule.

## 7. Final classification

`BA-04-SR01 ACCEPTED — APP-T06 LIFECYCLE AUTHORITY FIXED FOR EXISTING AGGREGATE/REQUEST — ONLY POST-TERMINAL NEW-LIFECYCLE POLICY REMAINS — OWNER DECISION REQUIRED BEFORE BA-04 RESUME — NO IMPLEMENTATION AUTHORITY CREATED`
