# EliteSync-v10 Local MariaDB Runtime Provisioning Plan

## 1. Objective

为 EliteSync-v10 backend 提供一个安全、隔离、身份可验证的 local MariaDB runtime provisioning 路径。

Local MariaDB instance 不等于 existing machine database，也不等于 production database。本计划仅定义未来 provisioning 边界，不授权或执行服务启动、安装、container/database/user/credential 创建或 migration。

## 2. Current Blocker State

当前 blocker：**isolated MariaDB runtime unavailable**。

已确认事实：

- Docker CLI `29.3.0` 可用；
- Docker Desktop Linux daemon 不可用；
- 现有 machine-level MySQL service 正在监听 `3306`；
- 该 MySQL listener 不是 MariaDB，且归属、数据、凭据和隔离边界无法证明，因此被拒绝作为 target；
- 没有创建 container、database、user、credential 或 `.env`；
- 没有执行 migration。

## 3. Runtime Identity Requirements

未来执行前必须确认 Database engine 为 **MariaDB**，并冻结以下身份：

- container/service name 与 immutable image version/digest，或 dedicated service installation identity；
- host binding 必须为 local-only loopback；
- host port 与 container/service port；
- dedicated database name；
- dedicated local username；
- disposable credential boundary；
- storage/volume identity 与 disposal boundary；
- 明确不存在 production hostname、route、credential、mount 或 data source。

上述任一字段未知或与现有 machine database 重叠时，provisioning 必须 fail closed。

## 4. Provisioning Options Review

### Option A — Docker Desktop + dedicated MariaDB container

- Isolation: 强；可使用唯一 container、loopback-only port mapping、dedicated network/volume 与独立 credential。
- Reproducibility: 强；需要固定 MariaDB version 和 image digest。当前版本尚未选择，不能从 Docker CLI 存在推断 image/runtime 可用。
- Rollback: 清晰；未来可停止并删除精确识别的 container 与 disposable volume，但删除前必须重新核验名称、ID 与数据边界。
- Risk: Docker daemon 启动可能影响既存 auto-start containers；image pull 依赖网络；port/name/volume 可能冲突；不受控 bind mount 可能弱化隔离。

### Option B — dedicated local MariaDB installation

- Isolation: 中等；只有在使用专用 service name、独立 data directory、独立 loopback port 与独立 user 时才可接受。
- Reproducibility: 中等偏低；依赖 machine installer、service manager 和本机配置。
- Rollback: 较复杂；需要精确停止 service 并删除专用 data/config，容易与 machine-wide state 混淆。
- Risk: 可能与现有 MySQL service、PATH、port、data directory 或 service lifecycle 冲突；不得修改当前 MySQL listener。

### Option C — other isolated runtime

例如 dedicated VM、WSL distribution 或其他 container engine。

- Isolation: 可从强到未知，取决于 network、storage 和 process boundary 的可验证性。
- Reproducibility: 只有在 runtime/version/config 可固定时才成立。
- Rollback: 必须能够删除精确、专用且可证明无共享数据的 runtime/storage。
- Risk: 当前 capability、engine identity、network behavior 与 lifecycle 未验证；不能作为自动 fallback。

## 5. Recommended Boundary

推荐 **Option A：Owner 已明确启动并确认的 Docker Desktop + dedicated MariaDB container**，因为它最容易同时满足：

- loopback-only local access；
- disposable container and storage；
- no production access；
- clear container/image/network/volume identity；
- repeatable provisioning；
- precise rollback。

未来执行应使用唯一 EliteSync-v10 名称、执行时重新验证的非冲突 loopback port、固定的 MariaDB image version/digest，以及专用 disposable volume。不得使用 host `3306` 上的现有 MySQL service，不得挂载任何生产、共享或未知 data directory。

## 6. Data Boundary

禁止：

- production data；
- production dump；
- backup restore；
- real user/private data；
- existing machine database reuse；
- shared database volume or bind mount。

未来允许在独立授权下使用：

- empty schema initialization；
- 来源明确的 synthetic fixture data。

Synthetic data 与 seed execution 仍需单独验证，不得与 provisioning 隐式合并。

## 7. Environment Boundary

未来 local-only configuration 需要注入：

- MariaDB driver/connection name；
- loopback host；
- dedicated host port；
- dedicated database name；
- dedicated local username；
- disposable local password；
- 如需要，charset/collation boundary。

当前不创建真实值、password、user、database 或 `.env`。Future credentials 必须在 Git 外生成和保存，不得复用 production/shared credentials，也不得写入 report、command output 或 source-controlled files。

## 8. Execution Preconditions

未来 provisioning 前必须同时确认：

1. MariaDB engine identity、固定 version/digest 与 runtime source；
2. Docker daemon 或替代 runtime 已由 Owner 明确启动，且不会意外启动/修改无关 services；
3. network binding 仅为 `127.0.0.1`/loopback，chosen port 在执行时无冲突；
4. container/service、network、database 与 volume identity 唯一；
5. storage 为 disposable，且不是 production/shared/bind-mounted data；
6. credential 为新建 local-only disposable credential；
7. environment 中不存在 production hostname、IP、URL、credential 或 route；
8. rollback targets 已按精确 ID/name 记录且不包含共享 state。

任何 precondition 未通过时不得创建 container、database 或配置。

## 9. Validation Sequence

未来获得新的明确执行授权后，顺序为：

1. Start the isolated MariaDB runtime.
2. Verify engine, version/digest, container/service, network, port, and storage identity.
3. Verify loopback-only connection identity and absence of production routes.
4. Create a dedicated disposable database and local-only user.
5. Create ignored local environment configuration outside Git.
6. Revalidate database identity from Laravel's effective local boundary.
7. Execute migrations in a separate migration-execution gate.

Provisioning success不等于 migration success；第 7 步必须保持为后续独立执行与报告阶段。当前不执行以上任何步骤。

## 10. Non-goals

当前计划不执行或授权：

- Docker Desktop/service startup or change；
- container/image/network/volume creation or pull；
- MariaDB/MySQL installation or service mutation；
- database/user/password creation；
- `.env` or secret creation；
- database connection, migration, rollback, seed, dump, or restore；
- existing MySQL `3306` access；
- production/Alibaba Cloud access；
- backend source、migration、Model、config、route、Flutter 或 Android modification。
