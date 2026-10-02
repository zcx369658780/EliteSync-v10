# APP-M5-02｜当前 v10 仓库 Android host 精确定位

状态：`ISSUED`；风险 `LEVEL 2`（平台/构建图，docs-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 唯一交付与边界

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-M5-01 `plan.md`/`work-review.md`、当前 M5 路线图。唯一允许新增本目录 `plan.md`；不改源码、测试、项目配置或 authority 文档。

最多两轮本仓只读定位。第一轮仅对当前 v10 仓库的 `apps/` 与仓库根可见项目清单做**有界文件名索引**，寻找 Android host 的固定标记（`settings.gradle*`、`build.gradle*`、`gradlew*`、`AndroidManifest.xml`、Flutter `local.properties`/模块引用）；不得访问旧 `D:\EliteSync`、用户主目录、SDK 或其它仓库，不作全盘搜索。第二轮只读第一轮命中的准确文件与当前 `apps/flutter_elitesync_module` 的 `pubspec.yaml`/入口，判断 host 是否绑定此模块、源码是否与当前 main 一致，以及能否给出唯一可信构建入口；不因目录名相似就认定可安装。如果无命中，明确限于此次仓库范围 `NO_HOST_FOUND`，并建议一张安全有界的本地 host 创建/恢复任务或记录需要 Owner 选择的目标；不要自行生成 host。

`plan.md` 记录两轮准确命令/范围、命中路径、关键文件 SHA-256、绑定证据、未核实项与一个下一步。只读预算 2/2；不运行 Flutter/Gradle/adb/设备、网络、构建、安装、UAC、真实 DB/备份/密钥/SSH/云/生产 API。不得提交、pull、push、自接受或自行启动后继。M5 设备仍 `UNKNOWN`，APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变。
