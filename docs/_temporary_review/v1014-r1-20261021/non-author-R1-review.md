# v10.1.4 R1 bounded non-author static review

Separate non-author helper v1014r1_case_review; read-only source/Git inspection, no tests/DB/API/AVD executed by reviewer. One consolidated review and closure of the same findings.

Required/P1 originally found: unrelated SOURCE_REVOKED/revoke prematurely ended all participants' history; a still-readable APP card hid the entire history report context, preventing reports against a peer who left. Fixes: new revoke audits scope exact registration/grant, historical proof matches it; legacy unscoped terminal facts use only that row's time and fail closed on unproven same-time overlap, current unaffected participants stay eligible. APP retains historical targets alongside the ordinary card and isolates history form state.

Missing checks added: third-party block does not close A/B's window or late co-participation; APP live card with a withdrawn historical target still submits; exact old source hashes reconstruct both sources individually, including SELF_REPORTED; seal tamper/cross-case replacement suppress source facts.

Final same-review closure: 两个 Required 和最后的 legacy 测试缺口均已关闭，无剩余阻断。已核实 Commit 1062603bfd5866eb4c40b4773657343a1eca2af7，Root/apps/services Tree 均与所报身份一致。固定提交中的测试已逐条核对两条 source_id，并单独匹配 A 的 SELF_REPORTED 原始 hash。本次仅 Git/源码只读核对；未运行测试，不构成最终产品验收。

Fixed source: 1062603bfd5866eb4c40b4773657343a1eca2af7; Root aa4c47569d60a5e5638c25e9b0e3c0d7e1760da5; apps3468a3dd97da7accfda2539a0f8d8f68931a6110; services0cb1f9d19659291a462488b3686fd0a07a6698ac. Physical results remain CODEX_REPORTED / LOCAL_ONLY, not Astra acceptance.
