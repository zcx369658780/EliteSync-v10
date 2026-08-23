# EliteSync-v10 Local Database Initialization Plan

## 1. Objective

建立 EliteSync-v10 Laravel backend 的安全、隔离本地数据库初始化路径。

Local database 不等于 production database。Repository migrations 不等于 production schema state。本文件仅设计未来流程，不授权或执行数据库连接、创建、migration、seed、dump 或 restore。

## 2. Current Database Source State

- Repository: `zcx369658780/EliteSync-v10`
- Backend: `services/backend-laravel/`
- Migration source: `database/migrations/`
- Model source: `app/Models/`
- Migration files: 57
- Model files: 34

57 个 migration filename 的时间/顺序前缀在静态检查中没有重复。Migration 和 Model source 的存在仅证明 schema intent 与 application mapping 已迁移，不证明生产数据库已应用任何 migration，也不证明生产 schema 或数据状态已知。

## 3. Database Architecture Boundary

EliteSync-v10 的 authoritative datastore architecture 为 MariaDB。未来 local development database 必须是身份明确、与生产网络和凭据隔离、可安全丢弃的本地实例或专用开发实例。

不得复用、连接或指向 production database。不得把本地初始化结果解释为 production parity。

## 4. Migration Strategy Design

未来获得明确执行授权后，应按以下边界准备：

1. 创建身份明确且可丢弃的 isolated local MariaDB database；
2. 在 Git 外配置仅面向该 local database 的环境变量；
3. 静态核对 57 个 migration 文件的 filename ordering 与 availability；
4. 在执行前再次证明 host、port、database name 和 account 均属于 local environment；
5. 仅对该 local database 执行 repository migrations；
6. 保存 migration exit status、applied migration inventory 与 local schema validation evidence。

任何身份不明确、可能路由到共享或生产数据库的配置都必须 fail closed。本阶段不执行上述步骤。

## 5. Seed / Data Boundary

Seed strategy 需要独立设计和明确授权。未来如需开发数据，应使用非生产、可公开说明来源的 synthetic 或 deterministic fixture data。

禁止：

- 复制或抽取生产数据；
- 导入 production dump；
- 恢复生产 backup；
- 使用真实用户、凭据、token、媒体或其他私有数据；
- 将 seed execution 与 schema initialization 隐式合并。

## 6. Model / Schema Relationship Review

静态 source evidence 显示：

- 57 个 migration 定义或演进 42 个明确的 created table names；
- 12 个 table names 还通过后续 `Schema::table` migrations 演进；
- 34 个 Models 覆盖用户/档案、问卷/MBTI、匹配/轮次、会话/消息、媒体、状态动态、审核、RTC、通知、发布与审计等业务实体；
- Model source 中存在 56 个 `belongsTo`、15 个 `hasMany` 和 2 个 `hasOne` relation declarations；
- migrations 还包含 cache、jobs、sessions、tokens 等 infrastructure tables，因此 Model 与 migration/table 数量不是一一对应。

这些是 source-level facts。Foreign keys、indexes、nullability、relation behavior 与 application access patterns 需要在未来 isolated schema validation 中核对；当前不连接数据库，也不推断 production schema。

## 7. Environment Boundary

未来 local database configuration 至少需要独立注入：

- local database connection/driver；
- local DB host；
- local DB port；
- local database name；
- local username；
- local password；
- 如适用，local charset、collation 和 socket boundary。

Repository configuration支持 `APP_DB_*` 与 fallback `DB_*` 变量族。真实 host、database name、username 和 password 不得写入 source-controlled template、plan 或 Git；应通过独立授权的 local secret injection 处理。Production values 不得复用。

## 8. Validation Sequence

未来建议顺序：

1. Prepare and prove the identity of an isolated local MariaDB database.
2. Configure local-only environment values outside Git.
3. Revalidate migration availability and ordering.
4. Run migrations only against the proven local database.
5. Verify locally created tables, constraints, and migration records.
6. Verify application database access with a non-production validation path.

每一步必须保留 target identity 证据；任一步无法证明 local isolation 时立即停止。当前不执行该序列。

## 9. Known Risks

- Production schema and applied migration history are unknown；
- Production and local data state are unknown；
- Model/schema compatibility has not been runtime-validated；
- Migration ordering is statically available but execution behavior is untested；
- MariaDB version, SQL mode, charset, collation, extensions, and permissions for the future local instance are not selected or validated；
- Migration side effects, rollback behavior, and application database access remain unverified；
- Environment misrouting could contact a non-local database unless identity is proven before execution。

## 10. Non-goals

当前计划不执行或授权：

- database connection；
- database creation；
- migration or rollback；
- seed or fixture execution；
- schema mutation；
- dump, backup, restore, or data migration；
- production recovery or production comparison；
- `.env`, secret, backend source, route, config, Model, or migration modification；
- server or Alibaba Cloud operation。
