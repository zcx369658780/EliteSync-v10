# BE-02 Work 独立审查｜2026-09-27

**LEVEL 2 REJECT 作为可实施的精确合同。** 接受作者按任务停在审查门和只写 docs-only 候选的有限事实，不接受 BE-02 `plan.md` 直接授权 repository 代码。审查对象 SHA-256 `0D4CE477567F505E07F579F8DD4120B8EB0CACB45947C6A7DFD1AA54F2B477AE`；作者静态预算 2/2 已耗尽，未运行代码或测试。

核对固定来源发现三处必须修正的合同缺陷：

1. `plan.md` §1 声称沿用 Common Authority 十一个严格绑定键，却写为 `owner`、`scope`；真实键为 `authority_owner`、`authority_scope`。`CommonAuthorityEvidenceContract::assertBindings` 要求精确键集，这两种形状不可互换。
2. §1 将顶层 `source_condition/currentness/freshness` 一起按 false/null 保守聚合；实际 `source_condition` 为 `PRESENT/ABSENT/UNKNOWN/UNAVAILABLE/STALE/SUPERSEDED/INCOMPARABLE` 字符串枚举，而 `currentness/freshness` 才是 bool/null。需固定确定性且保守的映射，不能让未知依赖被写成 `PRESENT` 或 true。
3. §1 定义 `MC_CURRENT_STATE` payload，却未给出它与现有 MC evaluator 的可核对来源关系：该 evaluator 可产生 transition derivation 和 read/send gate derivation，未提供独立 `evaluateCurrent` 结果。须明确当前态记录从哪一份来源携带证据构造、何处只作校验、何处调用 evaluator，不能把不存在的 evaluator 当前态输出当作接口。

候选对 CN/MC 分离、投影非授权、终态身份和 send 双输入复核的方向可作修订来源，但其 family 名、payload、代码路径尚未接受为实现合同。先进行一次精确修订和独立审查；真实 MC writer、auth/session、生产 DB、备份解密和账号回填仍未授权。BE-02 的 2/2 不重置。
