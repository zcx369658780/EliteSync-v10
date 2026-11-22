# 共享 V2 Staging 操作手册

本手册的 Compose 已在独立本机 Docker 引擎演练。远端执行须绑定 Owner 已签发的实例、费用、网络及操作窗口。业务镜像从 P0.4.2 接受源码构建，正式计划须把本机镜像 ID 与私有仓库 manifest digest 关联。

## 1. 镜像与目标清单

在干净目录从固定 Git 对象提取构建上下文。以下命令以仓库根及单独的空目录 `$build` 为起点。

```bash
set -euo pipefail
src=7e0009df4fe69e48967c4fbc111717626c85ed80
git rev-parse "$src^{tree}" "$src:services/backend-laravel"
git archive "$src" services/backend-laravel | tar -xf - -C "$build"
docker build --platform linux/amd64 --pull=false --progress=plain \
  --label "org.opencontainers.image.revision=$src" \
  --label 'org.opencontainers.image.title=EliteSync-V2-shared-staging' \
  -t "$local_image" -f "$build/services/backend-laravel/docker/cloud-r0/Dockerfile" \
  "$build/services/backend-laravel"
docker image inspect "$local_image" --format '{{.Id}} {{.Os}}/{{.Architecture}} {{json .Config.Labels}}'
docker image inspect "$local_image" --platform linux/amd64 --format '{{.Id}}'
docker run --rm -i --network none --entrypoint /bin/sh "$local_image" \
  -c "$(cat "$ops/verify-image-lock.sh")" < "$ops/image-packages.sha256"
```

固定输入见原 Dockerfile 的 Node、Composer、PHP digest 和三份锁。Debian APT 仍用基础镜像的仓库配置，部署直接使用已固定的产物。若重建，构建后须核对版本清单、源码标签、平台和依赖锁，差异交由审核。Registry 发布、签名和远端 pull 依 Owner 批准的私有仓库和凭据执行，记录远端 digest、平台 manifest、源提交与回执。地址或 digest 不匹配即停止。

Owner 私表固定 `project`、`schema`、`server_id`、`instance_id`、域名、镜像 digest、镜像回退 ID、卷名、密钥所有者及时间窗；单独核对 `staging.env.example` 对应字段。准备独立的 APP_KEY、MariaDB 应用与 root 密码、TLS 秘钥和证书，存于 Staging 专属私有目录。Laravel 服务中的 `www-data` 必须能读取它所用挂载文件。只有数据库容器挂载 root 密码。镜像、日志和审批回执只引用密钥代号。校验只读挂载 DE440s 的 SHA-256 `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2`。

## 2. 初始部署，受限入口先保持关闭

从签字目标清单取值，分别验证 Docker 主机身份、镜像和 Compose 渲染结果。确认指定 project 尚无容器或卷，回环端口未被占用。部署机器先以主运行密钥和空目标库进行迁移。以下以 Bash、Docker Compose v2 及 Python 3 为例，`$env_file` 须为私有文件，其他变量均来自批准目标。

```bash
dc=(docker compose --project-name "$project" --env-file "$env_file" -f "$ops/compose.yaml")
guard=(python3 "$ops/verify-target.py" --compose "$ops/compose.yaml" --env "$env_file" \
  --project "$project" --schema "$schema" --instance "$instance_id" --server-id "$server_id")
"${dc[@]}" config --quiet
"${dc[@]}" create --pull never staging-app
"${dc[@]}" up -d --wait --pull never staging-db
"${guard[@]}" --empty
"${dc[@]}" run --rm --no-deps --pull never staging-app php artisan migrate --force --no-interaction
"${guard[@]}"
"${dc[@]}" up -d --wait --pull never
"${dc[@]}" ps
```

以严格证书校验访问回环 HTTPS `/up`，并验证 DB 身份、迁移状态、登录、三盘读回、私有图媒体和 Worker 作业。记录实际容器 ID、镜像、卷及内部网络成员。默认不运行 WebSocket profile，`STAGING_WS_ENABLED=false`。独立批准传输演练时，设置 `STAGING_WS_ENABLED=true` 并向同一 Compose 命令加入 `--profile websocket`。这只启 Workerman 传输。外层入口启用前需通过授权矩阵、正向 101、撤权关闭与新代重连。鉴权拒绝当前在边缘显示 502，须完成可区分的拒绝响应并复验。

独立边缘接入后，外层 TLS 按批准域名和证书身份校验上游回环 TLS，原样转发 HTTP/1.1 Upgrade 至相同路径，保留请求 Host，固定可信 HTTPS 转发语义。通过 VPN 或具名来源访问 API，另行限管 `/admin`、`/api/v1/admin` 及实际激活路由。配置落实后同时测试合法来源和拒绝来源，再由 Owner 决定开放具名访问。扩大来源、启运营计划任务或发布端口属于后续批准范围。

## 3. 合成备份、恢复和回滚

回滚前封掉新外层入口。停止 Staging 的 edge、app、worker 和已启用的 ws，使 DB 与媒体在一个静止窗口内一致。使用独立权限的备份目录记录实例、源 schema、时间、镜像 digest 和配套备份编号。备份失败时保留已有证据并按本次批准决定是否恢复这个 Staging 入口。

```bash
umask 077
"${guard[@]}"
"${dc[@]}" stop staging-edge staging-app staging-worker
# 如果已启用 websocket，在同一已封流窗口用 --profile websocket 停 staging-ws。
# 确认所有写入进程已停，再导出。
"${dc[@]}" exec -T staging-db sh -ec \
  'export MYSQL_PWD="$(cat /run/secrets/r0_db_password)"; exec mariadb-dump -u elitesync_staging_app --single-transaction --quick --skip-comments --skip-dump-date --order-by-primary "$MARIADB_DATABASE"' \
  > "$backup/staging.sql"
"${dc[@]}" run --rm -T --no-deps --pull never staging-app \
  tar -C /var/www/html/storage/app -cf - . > "$backup/media.tar"
(cd "$backup" && sha256sum staging.sql media.tar > archive.sha256)
```

恢复使用独立 project、schema、server_id、实例标识、回环端口及新卷，且目标与备份源分开。以同一 Compose 创建 app 容器和启动 DB，运行目标 guard 的 `--empty` 检查，确认媒体目录没有非目录项。只有可信来源且配对的备份可执行恢复。导入使用目标应用账号且 SQL 导出按位置参数指定源 schema，避免导出 `USE`、创建 schema 或跨库对象。密文依赖的 APP_KEY 由独立密钥流程恢复，随后轮换会话与凭据。实际恢复时 `dst` 和 `guard_restore` 用签字的恢复目标清单构建。

```bash
(cd "$backup" && sha256sum -c archive.sha256)
"${guard_restore[@]}" --empty
"${dst[@]}" run --rm -T --no-deps --pull never staging-app sh -ec \
  'test -z "$(find /var/www/html/storage/app -mindepth 1 ! -type d -print -quit)"'
"${dst[@]}" exec -T staging-db sh -ec \
  'export MYSQL_PWD="$(cat /run/secrets/r0_db_password)"; exec mariadb -u elitesync_staging_app "$MARIADB_DATABASE"' \
  < "$backup/staging.sql"
"${dst[@]}" run --rm -T --no-deps --pull never staging-app \
  tar --no-same-owner -C /var/www/html/storage/app -xf - < "$backup/media.tar"
"${guard_restore[@]}"
```

重导目标 SQL，核对媒体路径和 SHA-256。通过回环确认 TLS、Laravel 健康、获准合成读和媒体，确认密钥与会话规则。恢复失败时保留失败目标及证据并隔离，重试用新的恢复目标。仅镜像变更且 schema 向后兼容时，可换回上个已经验收的 Staging digest。schema 变化时将成对备份恢复到新目标，再按批准切换 Staging 入口。首次部署没有已验收远端镜像可回切，封掉新入口并停止新服务是退出动作。回滚全过程保留新卷、源卷及审计。
