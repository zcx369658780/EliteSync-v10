# EliteSync Backend

当前锁定 Laravel 13、PHP 8.4，稳定本地开发服务使用持久 MariaDB 10.11。以下早期 Laravel 11 / MySQL 8 环境说明保留为历史记录。

## v10.1.6 展示资料闭环

本机 API 与管理端入口为 `http://127.0.0.1:8021`，沿用既有 Docker 容器和数据库卷。私有配置由 Owner 本机 `EliteSyncDev/v1015-current-dev/runtime-private.json` 定位，凭据和数据库留在本机。迁移 `2026_11_13_120000_complete_profile_showcase_workflow` 增加内容版本、不可变提交快照、私有照片引用和运营申请，启动过程保留现有业务。

启动时按私有清单恢复既有 DB、API、WS 容器，DB 就绪后开放 API。MariaDB 数据卷为 `v1015-current-dev-db-data`，私有媒体位于 `v1015-current-dev-storage` 卷。迁移通过现有 API 容器执行 `php artisan migrate --path=database/migrations/2026_11_13_120000_complete_profile_showcase_workflow.php --force`，不执行 seed。具体服务身份、配置及许可证保持本机清单管理。

普通 APP 使用 `/api/v1/profile/showcase/draft` 保存，`draft/submit-review` 提交，`photos` 上传。Web `/admin/showcase` 处理具名版本并返回反馈。本人显式 POST `publication` 后发布，DELETE 可撤回。`/api/v1/profile/showcase/{owner}` 及其 `photos/{photo}` 根据当前关系、受众和发布版本逐次鉴权。照片存于私有 `v1016_showcase` disk，最多6张，解码后重编码并去除原始元数据。发布快照与后续草稿分离。

修改携带 `expected_revision`，发布另带 `publication_revision` 与明确确认。已审核的内容不能自动批准新版本。旧草稿可重新提交，受限账号保留本人只读。移除和撤回约束后续读取，已发布的旧快照在替换或撤回前继续按其既有受众生效。

运营参与申请使用 `/api/v1/profile/operating-application`，管理端在账号页面审核，普通展示资料独立可用。相识后新增能力的应用层定义见[扩展契约](../../docs/versions/v10.1.6/AFTER_ACQUAINTANCE_CONTRACT.md)。

## 历史环境建议

- PHP: `8.4+`（`composer.lock` 当前包含 Symfony 8 组件，需 8.4）
- Composer: `2.9.x` ✅
- Docker CLI: `29.x` ✅
- phpMyAdmin: `5.2.3` ✅
- Redis: 建议优先用容器版（避免 Windows 发行版兼容问题）
- MySQL: 建议优先使用容器中的 `8.0.36`（与当前迁移脚本一致）

> 即使你本机安装了 MySQL 9.x，也建议先用容器里的 MySQL 8.0.36 进行迁移联调，避免语法/默认行为差异影响开发。

## 已知环境阻塞（2026-03-12）

- 本机 PHP 8.3.6 + 缺失 `ext-fileinfo` 时，`composer install` 会失败。
- 若 Docker Desktop 配置了不可达代理，`docker compose up --build` 可能在拉 `composer/php` 镜像时失败。

建议优先顺序：
1. 修复 Docker 代理并使用容器启动（推荐）。
2. 或升级本机 PHP 到 8.4 并启用 `fileinfo` 后执行本地调试。

## 已迁移接口（Phase 2 - batch 2）

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`（需 Bearer Token）
- `GET /api/v1/questionnaire/questions`（需 Bearer Token）
- `POST /api/v1/questionnaire/answers`（需 Bearer Token）
- `GET /api/v1/questionnaire/progress`（需 Bearer Token）
- `GET /api/v1/matches/current`（需 Bearer Token）
- `POST /api/v1/matches/confirm`（需 Bearer Token）
- `GET /api/v1/matches/history`（需 Bearer Token）
- 兼容别名：`/api/v1/match/current|like|history`

## 快速启动（推荐 Docker）

仓库根目录：

```bash
# 优先
./scripts/start_laravel_stack.sh

# 或手动
# docker compose -f infra/docker-compose.laravel.yml up -d --build
# 若你的环境没有 compose 子命令，就用：
# docker-compose -f infra/docker-compose.laravel.yml up -d --build
```

服务端口：
- API（Nginx）: `http://localhost:8080`
- phpMyAdmin: `http://localhost:8081`
- MySQL: `localhost:3306`
- Redis: `localhost:6379`

## 历史本地（非 Docker）调试

```bash
cd services/backend-laravel
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8001
```

## 测试

```bash
cd services/backend-laravel
php artisan test
```

## 聊天 WebSocket 网关（已可用）

```bash
cd services/backend-laravel
php artisan chat:ws --host=0.0.0.0 --port=8081
```

Android 客户端默认连接：
- `ws://10.0.2.2:8081/api/v1/messages/ws/{userId}`

可与 HTTP 服务并行启动：
- `php artisan serve --host=0.0.0.0 --port=8080`

## 历史开发态匹配联调

以下按用户 ID 配对及旧 Drop 命令已退役，仅保留历史记录。当前旅程使用正常报名、匹配与关系路径。

当本周没有匹配数据时，可手动触发：

```bash
# 生成当周匹配（按用户ID顺序两两配对）
curl -X POST http://127.0.0.1:8080/api/v1/admin/dev/run-matching \
  -H "Authorization: Bearer <token>"

# 发布当周 Drop（让 /matches/current 可见）
curl -X POST http://127.0.0.1:8080/api/v1/admin/dev/release-drop \
  -H "Authorization: Bearer <token>"
```

## 历史调试就绪检查

```bash
# 1) 依赖安装成功
composer install --no-interaction --prefer-dist

# 2) 应用密钥 + 迁移
php artisan key:generate
php artisan migrate --seed

# 3) 冒烟测试
php artisan test
```
