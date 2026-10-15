# v10.0.8 本地运行与复现说明

本说明用于冻结 [plan.md](plan.md) 的独立开发环境。候选源码、最终 AAR/APK 路径与 SHA256、实际运行记录和最终资源状态统一以 [manifest.json](manifest.json) 及本版执行报告为准；本文不预填尚未核定的包哈希或接受结论。以下是操作说明，文档编写本身不表示已执行重启或跨端验收。

## 固定环境与保护边界

| 项目 | 本版固定值 |
|---|---|
| 专用源码树 | `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10` |
| 版本分支 | `codex/v10.0.8-web-admin`；最终 commit/tree 见 Manifest |
| 本地证据目录 Q | `C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1008` |
| MariaDB | `mariadb:10.11`；容器 `elitesync-v1008-db`；volume `elitesync-v1008-db-data` |
| 数据库与入口 | `elitesync_v1008_dev`，`127.0.0.1:43318`，容器内 `3306` |
| Web | `http://127.0.0.1:8000/admin/login`；front `8000` → PHP/Laravel `8001` |
| Session | 本版数据库 session，专用连接和 cookie `elitesync_v1008_session` |
| Matching worker | database queue，队列 `v1008-matching`，单 job 尝试 1 次，timeout 180 秒 |
| Android | AVD `elitesync_v1007_api36`，固定 serial `emulator-5582`；应用 `com.elitesync` |
| 构建 | 已安装 PHP 8.5、Flutter/Dart、JDK 17、项目 Gradle wrapper及现有依赖锁 |

AVD 的历史名称包含 v1007；本版身份由固定 serial、最终安装包、本版 bootstrap/loopback 和数据库读回共同核定，不能凭 AVD 名称冒称环境隔离或包版本。

保留原 dirty 根 `D:/EliteSync-v10`、0.6 的 `43316`、0.7 的 `43317`、原 `3306` 数据库与所有无关容器、volume、PID、模拟器。不得挂载旧验收 volume、导入旧用户私密数据、执行数据库清空/重建或全局 Docker/进程清理。数据库所有写入限本版虚构账号与本版业务记录。

## 私配与账号

仅使用 Q 下现有 `secrets/runtime-env.json`、`secrets/db.env` 和 `secrets/accounts.json`。配置读取由 [dev-runtime.py](dev-runtime.py) 完成；不要打印这些文件、导出整个进程环境、把密码或 token 放入命令行、截图、日志、Git 或报告。账号从私密 `accounts.json` 交由获授权操作者本地使用；本文不提供凭据值。

账号具名键包括 `admin`、`alice`、`bob`、`pending`、`incomplete`、`roleonly`、`listonly`、`disabled`。测试过程可能已改变其审核或处罚状态，以当前 UI/同库快照和证据映射为准，不以 seed 初值推断当前状态。正常管理员同时满足当前角色、显式名单与未禁用条件；role-only 或名单-only 不具备管理权限。

## 仅重启本版资源

**本环境已经 init、migrate、seed；正常接续和最终重启不得再次执行 `init` 或 `seed`，也不需要重新 migrate。** 新增源码迁移若确有尚未应用项，只能在核对精确本版库身份后另行执行并登记；不能用重 seed 代替修复或重启。

在专用源码树设置本地路径变量：

```powershell
Set-Location 'C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10'
$evidenceRoot = 'C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1008'
```

1. 先按 Manifest/实际 joint-restart 记录核对现有资源身份。`dev-runtime.py` 目前没有 `stop`/`restart` 子命令；不要自行调用不存在的动作。
2. 仅从 Q 的 `owned-worker.json`、`owned-processes.json` 取得 worker、PHP 与 front 的具名 PID。逐一核对当前 PID 的可执行文件、完整命令行、启动时间和 `8000/8001` 端口归属；同时核对记录中的 cwd 是本专用树。PID 已退出可记录为停止；PID 复用、命令或归属不明则停止该项，不终止无关进程。`Get-CimInstance Win32_Process -Filter 'ProcessId = <已核PID>'` 与 `Get-NetTCPConnection` 可供核对。只对核验后的本版 PID 使用 `Stop-Process -Id <已核PID>`，先 worker，再 front/PHP；不得按进程名批量结束 PHP、Python、Java 或 emulator。
3. 确认 Docker 目标名称、版本 label、43318 loopback 映射及精确 volume 后，仅重启本版容器：

```powershell
docker restart elitesync-v1008-db
```

容器若处于 stopped 状态，可使用 `docker start elitesync-v1008-db`。保留同一 volume，不 `docker rm`、不删除 volume、不重新 `docker run`。等待该容器可用；端口占用冲突先核实归属，不终止前版资源。

4. 核实 `8000/8001` 已由本版释放且无无关占用，再使用原私配启动：

```powershell
python docs/versions/v10.0.8/dev-runtime.py $evidenceRoot start
python docs/versions/v10.0.8/dev-runtime.py $evidenceRoot worker
```

`start` 会检查两个端口是否空闲，并启动后台 PHP 与 front；`worker` 不会自动防止重复启动，调用前必须确认旧本版 worker 已退出。进程记录写入 `owned-processes.json`、`owned-worker.json`；日志分别追加到 Q 的 `laravel`、`front`、`worker` stdout/stderr。重启前后记录 PID、资源身份、完整退出码与状态，最终以 Manifest 和实际 joint-restart 记录为准。

5. Web/Laravel、数据库、worker 与 APP 重启后，按下文复查相同业务 ID 的持久化结果。不能把进程启动成功、单个 health 返回或 pending 当成业务完成。

## Android 与依锁构建

只操作固定 serial；先核 `adb devices -l` 和该设备 AVD 身份。若该 AVD 尚未运行，核空闲和已有实例后，可用既有 SDK 的 `emulator.exe -avd elitesync_v1007_api36 -port 5582` 启动；后台启动须隐藏窗口。不得 wipe、创建替代 AVD 或切换无关 serial。

```powershell
$adbPath = 'C:/Users/zcxve/AppData/Local/Android/Sdk/platform-tools/adb.exe'
& $adbPath -s emulator-5582 emu avd name
& $adbPath -s emulator-5582 reverse tcp:8000 tcp:8000
& $adbPath -s emulator-5582 reverse --list
```

应用通过该 reverse 访问本机 loopback `8000`，不改生产地址或全局代理。若指定设备不存在或归属不符，记录阻塞，不改用其它设备。

产品 Flutter 源码变更后必须重建模块 AAR 和 host APK，不能继续使用较早构建。使用本版 [build-local.ps1](build-local.ps1)，传入已配置且受控的专用 Gradle home；路径取实际构建记录/Manifest，不输出其中私配：

```powershell
./docs/versions/v10.0.8/build-local.ps1 -GradleHome '<已有专用Gradle目录>'
```

脚本执行项目 wrapper `assembleDebug -PflutterDartDefines=ELITESYNC_V1008_LOCAL_BUILD=true`。现有 `syncFlutterAar` 会用已安装 Flutter 执行 release AAR 构建，使用 `--no-pub`、本地 x64 target 和相同 Dart define。不得 `composer update`、升级 SDK/依赖、修改全局 Gradle 或代理配置；不要用 CI 预制旧 AAR 跳过最终源码构建。

`ELITESYNC_V1008_LOCAL_BUILD=true` 同时选择本地 host 运行方式与 About 页的 Android `development` 更新渠道。未携带此 flag 的包查询 `stable`，不能作为本版 B06 数据库闭环证据。它不代表 synthetic/mock 模式，也不授予生产权限。第四次及随后构建的实际来源、哈希和安装包身份按 Manifest；不以文件修改时间或“第四包”口头名称代替哈希。

host 输出位置为 `apps/android/app/build/outputs/apk/debug/app-debug.apk`；最终安装应使用 Manifest 锁定的包路径，先比对 SHA256，再仅向 `emulator-5582` 执行 `adb install -r <最终APK>`。不要卸载、清数据或 wipe 来制造通过。普通 APP 重启可对 `com.elitesync` 做定向 force-stop 后由设备界面重新打开，保留既有测试状态。

## B01～B06 真实复现

用真实浏览器访问独立 Blade 管理端，管理员与普通用户使用隔离会话；APP 仅登录本版虚构账号。操作前记录目标 ID、当前版本及预期结果，保留少量无凭据截图。所有管理写操作填写真实理由、当前 expected version 并明确确认；遇 stale/conflict 先刷新，不伪造新版本号重放旧决定。

| 模块与入口 | 实际操作与跨端核对 |
|---|---|
| B01 `/admin`、用户详情 | 搜索/筛选当前账号，确认具名禁用。核同用户 tokens/session 撤销、禁用状态及审计；APP 旧登录/refresh/业务拒绝，正常对照可用。检查自身/管理员目标、普通用户、role-only、名单-only、disabled 管理员、降权旧 session、无效 CSRF 与退出后访问均拒绝。 |
| B02 用户审核 | 将具名账号设为 pending/rejected/approved，填写原因及当前审核 revision。APP“我的”刷新运营资格卡，确认状态、原因和服务器 matching eligibility 一致。此审核是运营参与资格，非实名认证；approved 仍须满足当前有效问卷及其余准入条件。历史已发布 Match/CN/MC 不因审核改变被删除。 |
| B03 `/admin/reports`、用户处罚 | APP 举报本版公开动态/账号，记录 report 与目标 ID；浏览器具名处理、软删公开动态或执行 restrict/banned。APP 同目标核隐藏、限制新发布/新匹配/双向新私信或禁用。restrict 保留当前合法历史只读；restore 必须引用同目标真实 active sanction，未知旧处罚不得恢复。独立隐藏/metrics 和其它有效处罚保留；旧凭据、已撤销 MC/CN/block 不复活，私密互动须重新取得双方明确授权。审计不存私聊全文。 |
| B04 `/admin/matching` | prepare → 请求执行 → 刷新同 run，确认 database queue worker 实际领取并到终态 → 到公布时间后确认 reveal → APP 读回同 round/run/Match 与站内事件，最后按计划 close。pending/running 不冒成功。worker 停止时显示真实未完成；失败或过期 lease 按当前受控恢复入口和实际记录生成新的 retry attempt，不直接改表或篡改旧 run。零候选、重复/旧版本、worker 恢复及失败分支按证据索引复现；若当前页面不能表达某恢复动作，记录该限制，不把未执行步骤写成通过。Match 不自动授予 Connection/MC。 |
| B05 `/admin/questions` | 指定 low_drop 题 ID → 默认 dry-run 影响预览，核历史 answers/attempt、草稿与活跃 round/run → 基于预览 revision/signature 确认停用。APP 新题集合、有效回答不足的补答提示与新匹配资格应更新；旧答卷/attempt/已发布 Match 保持。已有草稿或最后一题提交遇 409/422 时保留当前答案并提示重新加载，阻止继续旧题提交；重载取新 bundle 后补答。其它网络失败不能冒称题库变更。恢复启用只针对本版可追溯停用记录及当前预览。 |
| B06 `/admin/releases` | 仅 Android/development 创建/编辑元数据，再单独激活或停用。校验版本/最低支持、URL、SHA256、理由与 revision；同渠道至多一条 active。APP 设置→版本中心→手动检查，显示 development、发布版本、更新说明与 `database` 来源。停用导致 `config fallback` 时明确非数据库有效发布，不提供旧生产下载；unknown/错渠道不确认更新。stable 仍保留人工下载确认。此流程不上传商店、不生产发布、不向真实用户强制升级。 |

匹配、媒体、私信及通知的既有使用点鉴权始终有效；历史合法只读不能替代新的双方同意。站内通知不等于系统 Push，旧通知权限、已读和计数须保持。RTC、算法许可、地图、外部 Push 等待恢复项目仍见恢复台账，不由本 Runbook 追认完成。

## 快照、持久性与证据

[snapshot.php](snapshot.php) 仅允许精确 `elitesync_v1008_dev:43318`，由 runtime 包装器带入原私配运行。需要生成新快照时使用唯一标签，避免覆盖旧原流：

```powershell
python docs/versions/v10.0.8/dev-runtime.py $evidenceRoot php '<唯一快照标签>' docs/versions/v10.0.8/snapshot.php
```

快照用于核对用户审核/处罚 revision、sanction、审计、questionnaire revision、answers/attempt hash、草稿摘要、round/run/Match、CN/MC、release 及 tokens/sessions 数量。脚本输出也可能含虚构举报/通知及审计原因，原快照留 Q 本地，不能未经脱敏整体上传。它不输出密码或 token 值；私配与账号文件始终 LOCAL_ONLY。

重启前后针对相同 ID 比较持久化状态；不要重 seed、换账号、重建库或只比总数。重点确认审核/处罚和动态软删不丢、旧凭据不复活、问卷历史 hash 不被运营启停改写、run/lease/retry 有真实终态、development release 和审计仍在，同一 APP 重新读取来源与资格保持一致。实际重启安全脚本、命令、原始 stdout/stderr/exit 与最终资源状态由主代理记录并在 Manifest/执行报告登记。

定向 PHPUnit/Flutter 测试用于源码验证，不能替代真实 Blade→共享 Laravel→独立 MariaDB→APP 联合证据。保留首轮失败和修复后的各次原流；未运行项写 `NOT_RUN`，不能用数量或 exit 0 概括成全部 AC 通过。

本地交付是待 Astra 独立终验的候选，不授权合并 main、生产发布、启动下一版本或删除旧证据。
