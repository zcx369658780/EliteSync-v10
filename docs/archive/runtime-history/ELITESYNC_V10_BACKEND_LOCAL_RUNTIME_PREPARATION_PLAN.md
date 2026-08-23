# EliteSync-v10 Backend Local Runtime Preparation Plan

## 1. Objective

为 EliteSync-v10 Laravel backend 建立安全、隔离的本地开发运行准备路径。

Local runtime preparation 不等于 production recovery。Source code、runtime configuration 与 production state 必须保持分离。本文件仅描述未来步骤，不授权或执行 runtime preparation。

## 2. Current Backend Source State

- Repository: `zcx369658780/EliteSync-v10`
- Backend: `services/backend-laravel/`
- Current phase state: source migration and static validation completed

当前 source 已包含：

- `composer.json`
- `composer.lock`
- Laravel source tree
- `database/migrations/`
- `app/Models/`

这些静态资产的存在不证明依赖可解析、Laravel 可启动或 runtime 已配置。

## 3. Local Runtime Requirements

### PHP

未来需要一个隔离的本地 PHP runtime。`composer.json` 的 source evidence 声明 PHP constraint 为 `^8.2`；该约束不是本计划对具体本地 PHP 版本的选择。locked dependency compatibility 仍需在后续授权阶段验证。

### Composer

未来需要使用 `composer.lock` 安装锁定依赖。依赖安装必须发生在隔离的非生产环境中。

### Database

未来需要 isolated development database。数据库应与生产环境隔离，不得连接或复用生产数据库。

### Redis

当前架构需要 Redis。未来本地配置必须使用隔离的 Redis instance 或明确隔离的 local namespace/database，不得指向生产 Redis。

### Queue

未来需要独立验证 Laravel Queue 的 connection、queue configuration 与 local worker behavior。本阶段不启动 worker。

### Realtime

Workerman 需要在未来独立验证。云端已观察到的 Workerman 不稳定状态不能作为本地配置，也不在本阶段修复。

## 4. Environment Configuration Boundary

未来需要：

- 无真实 secret value 的 environment template；
- 明确隔离的 local development configuration；
- 独立的 secret injection strategy。

不得迁移或复用：

- production `.env`；
- credentials；
- secrets；
- keys；
- certificates；
- cloud- or machine-specific configuration。

Secret injection 必须独立设计、授权和处理；任何 secret value 均不得写入 Git。本计划不创建或修改 `.env` 或 template。

## 5. Dependency Preparation Boundary

当前已有 `composer.json` 与 `composer.lock`。未来授权的准备阶段可基于 lock file 执行 `composer install`，以复现已锁定依赖。

本阶段不执行 Composer。`composer update` 不属于 local runtime preparation boundary，且被明确禁止。

## 6. Database Preparation Boundary

未来需要：

- 创建隔离的 local development database；
- 静态确认 migration availability 与 ordering；
- 在隔离环境中验证 schema initialization path。

禁止：

- production database connection；
- production migration；
- production schema mutation；
- production data dump restore；
- 根据 repository migrations 推断 production schema state。

## 7. Service Dependencies

未来需要分别验证：

- MariaDB；
- Redis；
- Laravel Queue worker；
- Workerman。

各服务必须使用本地隔离配置，并在单独授权后逐项验证。当前不安装、不连接、不启动任何服务或 worker。

## 8. Local Runtime Validation Sequence

后续获得明确执行授权后，建议按以下依赖顺序进行：

1. Prepare an isolated local environment with no production endpoints or values.
2. Prepare a non-secret configuration template and local configuration boundary.
3. Select a source-compatible PHP runtime and install locked dependencies with `composer install`.
4. Boot Laravel locally without connecting to production services.
5. Verify route loading against repository source.
6. Verify migration availability without applying migrations to production.
7. Prepare and validate an isolated local database strategy.
8. Verify Redis, Queue worker, and Workerman separately.

该顺序是未来验证设计，不是执行授权；本阶段不执行其中任何步骤。

## 9. Known Risks

- `.env` 与 `.env.*` 均缺失，当前没有 runnable environment configuration；
- local database state 与 production database state 均未知；
- locked dependency compatibility 尚未验证；
- effective runtime configuration 未知；
- Redis、Queue 与 Workerman 的本地配置尚未验证；
- cloud runtime 与 local runtime 可能存在差异；
- 若隔离边界未先建立，启动或安装依赖可能意外接触外部服务。

## 10. Non-goals

本计划不执行或授权：

- deployment；
- production operation or recovery；
- database connection or mutation；
- server、Alibaba Cloud 或 cloud runtime mutation；
- secret handling、credential creation 或 certificate/key management；
- route drift resolution；
- Workerman 或 Queue worker repair；
- backend source、dependency declaration 或 runtime configuration modification。
