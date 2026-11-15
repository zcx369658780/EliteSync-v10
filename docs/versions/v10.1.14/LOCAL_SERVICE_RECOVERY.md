# 本机开发服务与隔离恢复

2026-11-15。适用稳定根 `D:\EliteSync-v10-product-v1015-20261101`，本机虚构开发库 `elitesync_v10_1_5_dev`。

## 当前资源

| 资源 | 入口或持久位置 |
| --- | --- |
| APP | `com.elitesync.v1015dev`，模拟器5580的Android用户11 |
| API与Web | `http://127.0.0.1:8021`，容器 `v1015-current-dev-api` |
| WS | `127.0.0.1:8022`，容器 `v1015-current-dev-ws` |
| MariaDB | 10.11.19，容器 `v1015-current-dev-db`，卷 `v1015-current-dev-db-data` |
| 私有媒体 | 卷 `v1015-current-dev-storage`，最终归档整个容器目录 `/app/storage/app`，涵盖已有私有disk |
| SFU | 既有 `v1015-current-dev-sfu`，本机入口7880，运行验证结果见证据摘要 |
| 配置与原证 | Owner本机 `EliteSyncDev\v1015-current-dev`，本版原证在其 `v10114-current` 子目录 |

本版复用现有主媒体外键和MediaAsset类型，迁移为NONE。已有图片记录继续使用原字段。候选回退须同时考虑APP能否显示新增视频记录，保留本版候选和数据库备份。

## 启动与就绪

先启动已有Docker Desktop。恢复原容器，依次检查数据库、API、WS。以下命令使用已经配置的本机容器环境。

```powershell
docker start v1015-current-dev-db
docker exec v1015-current-dev-db sh -c 'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE" -e "SELECT 1"'
docker start v1015-current-dev-api
docker start v1015-current-dev-ws
Invoke-WebRequest http://127.0.0.1:8021/admin/login
Test-NetConnection 127.0.0.1 -Port 8022
```

数据库就绪以实际SQL成功为准。`mariadb-admin ping`在认证尚未准备好时也可能报告服务存活，本版首次隔离导入因此失败，改为SQL探测后恢复演练通过。

API还需用虚构账号读取本人业务记录确认数据库连接。HTTP页面可达与业务记录可读分别核验。WS端口可达后，由APP进入既有合法会话确认业务路径。

需要RTC评估时，启动既有SFU并检查入口及容器日志。

```powershell
docker start v1015-current-dev-sfu
docker exec v1015-current-dev-sfu python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:7880/').status)"
docker logs --tail 40 v1015-current-dev-sfu
```

本版实际启动原SFU，容器内LiveKit健康入口返回200。主机7880接入鉴权网关，根路径返回403，网关只接收获准的 `/rtc` 和 `/rtc/validate`。验证后停止SFU，保留原配置及容器。SFU进程、HTTP就绪、RTC信令、双向音视频及人耳听感分别记录。历史非注入SFU/RPC精确根因沿原记录UNKNOWN。

模拟器沿用AVD `v1015_current_a`、用户11和USB排除的ADB5038。本版私有启动助手为 `C:\Users\zcxve\EliteSyncDev\v10114_android.py`。启动参数保留AVD数据，使用无窗口模式与具备令牌鉴权的本机模拟器控制接口。素材导入所需的模拟器adbd重启后，重新建立8021/8022端口转发，再运行APP。

## 数据库网络依赖恢复

API和WS共享DB容器的网络命名空间。DB容器重启后，其网络命名空间可能变化，已有API/WS仍引用旧空间。出现APP连接失败时，先确认DB的SQL就绪，再恢复原API/WS。

```powershell
docker inspect v1015-current-dev-db --format '{{.NetworkSettings.SandboxKey}}'
docker inspect v1015-current-dev-api --format '{{.HostConfig.NetworkMode}}'
docker restart v1015-current-dev-api v1015-current-dev-ws
```

恢复后用原虚构账号重新读取具名ID、版本、归属和受众，并检查容器ID及卷。v10.1.13首次逐次探测回执缺失与原连接关闭错误保留。自动透明恢复仍沿历史范围记NOT_RUN。

## 备份

备份放Owner本机私有目录。数据库使用 `mariadb-dump --single-transaction --routines --events --triggers --databases`，通过容器现有环境读取凭据。媒体从现有私有存储目录打包。Windows保存二进制流时，本版使用Python的二进制文件句柄承接原始输出，并共同检查退出码和stderr。

记录数据库与媒体归档的字节数、SHA256、时间、数据库名、容器身份和源码身份。副本恢复完成后再记录校验结果。配置、密钥、SQL、归档和完整哈希索引由Owner本机保管。

本版开工备份为私有 `v10114-current\backup-before-content`，包括约3.2MB数据库备份和399360字节媒体归档。已恢复104张业务表，表行数逐项相等，20份私有媒体内容哈希逐项相等。最终语料备份与演练身份由最终证据摘要记录。

## 隔离恢复演练

实际执行助手位于 `C:\Users\zcxve\EliteSyncDev\v10114_recovery.py`，可在Owner本机核查完整命令及私有回执。恢复容器 `v10114-isolated-restore-db` 使用独立卷 `v10114-isolated-restore-data`、既有MariaDB镜像及 `--network none`。导入目标在启动前逐项核对，恢复数据库与现有开发容器保持独立。

1. 核对备份归档SHA256与清单。
2. 为隔离容器生成临时凭据，在本机私有文件保管。
3. 创建具名独立卷和容器，使用实际SQL确认就绪。
4. 以标准输入导入备份，检查退出码和错误流。
5. 比较业务表及记录，核对测试语料和主媒体引用。
6. 将媒体归档恢复到本机独立目录。解包前验证目标绝对路径属于该目录，再逐文件比较内容哈希。
7. 保存结果并停止隔离容器，保留卷及演练原证。

现有开发库、卷、AVD、历史原证、原主库dirty/index及 `%SystemDrive%/` 均属于保护资产。需要恢复真实开发库时，由Owner选择具体恢复点和覆盖范围。

## 停止顺序

结束APP操作后，先保存业务回执和候选身份，再停止APP及具名模拟器。需要停止整套开发服务时，按SFU、WS、API、DB顺序执行，保存当前容器和卷身份。

```powershell
docker stop v1015-current-dev-sfu
docker stop v1015-current-dev-ws
docker stop v1015-current-dev-api
docker stop v1015-current-dev-db
```

本版最终保留的运行资源以manifest为准。完整开发数据库、媒体、配置和备份继续留本机。

## 本版最终演练结果

最终备份为Owner本机 `v10114-current\backup-final`。数据库3235863字节，媒体归档18237440字节。独立恢复容器 `v10114-final-restore-db` 使用新卷 `v10114-final-restore-data` 和network none。104张表逐表行数及canonical全部行值一致，59个媒体文件逐个哈希一致。原数据库和原卷保留。两次隔离恢复容器均已停止，卷和回执保留。

原服务按WS、API、DB停止，再SQL确认DB就绪、启动原API及WS。每次探测记录在本机 `service-restart-rehearsal-private.json`。容器ID、挂载卷和网络模式与演练前一致，25条内容、消息136及CN/MC状态读回一致。API登录页200和WS TCP可达。重启后的WS帧投递本版NOT_RUN。

最终DB/API/WS运行，SFU停止。两个模拟器停止，AVD和数据保留，临时输入设置已恢复。Owner评审素材及凭据继续本机保管。
