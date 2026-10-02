# APP-T12-G12｜当前本地 Flutter 工具与定向证据状态

状态：`ISSUED`；风险 `LEVEL 2`（APP-T12 证据分类，docs-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 唯一交付

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-T12 重审结果 G-12 的**历史证据层级**、APP-G11-01～18 与 APP-HM-01～10 中已接受的 Flutter 定向回执、APP-M5-01～05 Work 审查。唯一允许新增本目录 `plan.md`；不改历史 APP-T12 文件、源码、测试或 authority。

最多两轮本地只读核对。第一轮只从当前已接受的 Work review/作者摘要提取 Flutter 定向 test/analyze 的实际命令、退出码、目标文件与限定结论；不得把多次单文件 PASS 拼成整套/设备 PASS。第二轮核对当前 `.dart_tool/package_config.json`、PATH 中 `flutter`/`dart` 命令解析、目标文件当前哈希与既有回执所固定哈希是否仍一致，并对照 M5 的 host、入口与设备 `UNKNOWN`。只对当前本地状态给出 G-12 的精确分类：哪些旧“工具不可用”事实已不适用，哪些当前工具/测试证据已建立，哪些全套、Android 构建/安装和真实账号依然 `NOT_CHECKED`。不改写 APP-T12 当时的接受结论，不据人工数据宣布 MVP 运行完成。建议一张真正增加验证覆盖且无需真实数据的后继任务；若无必要，明确 `NO_NONREDUNDANT_SLICE`。

`plan.md` 记录两轮来源、当前关键哈希、事实矩阵、未证项和下一步。预算 2/2；不运行新测试、分析、构建、adb、设备、网络、UAC 或真实数据，不读旧 `D:\EliteSync`、真实 DB/备份/密钥/SSH/云/生产 API。不得提交、pull、push、自接受或自行派发后继。旧测试预算不重置，M5 运行仍 `NOT_READY`；APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变。
