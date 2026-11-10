# 当前入口｜2026-11-10 APP 功能继续、双模拟器联测后置

Owner 已明确继续完善 APP；后续可同时使用两个模拟器进行功能联测，实际测试可等 APP 功能完成后安排。手机由 Owner 使用，不连接、读取或操作手机。Owner 已进一步给予普通工程长期授权，覆盖必要构建、本机独立开发服务/虚构数据库、双模拟器及常规Git；当前先继续消息/媒体功能，确需验证时自主安排。Owner 会另行要求停下保存、手动交接；不提前结束当前连续开发。

- 产品根：`D:\EliteSync-v10-product-v1015-20261101`；分支 `codex/v10.1.5-software-continuation-20261101`。原主库 main/255项状态/index 与无关 `%SystemDrive%/` 保留。
- 已实现聊天历史/发送恢复、附件上传重试和通知设置重试；本节点补齐通话入口模式保持/有限重试，以及私有视频进度拖动和重播。相关组件检查通过，详情见 PROGRESS。接着检查既有来电/接听/挂断流程。
- 本轮新增 APP/API 源码，当前代码身份以本分支功能提交为准。尚未产新 APK；最后已核包仍为 `b621fb883a16ad0956b0b2d049d8d023d5cb7a25e7451d6b08584d402580e57f`，不能将其当作包含本次改动。
- v10.1.5 仍 10 PARTIAL、AC05 OPEN、G2 false、真实 Push PENDING。主机定向检查不能代替双端 APP/API/MariaDB 联测、媒体播放、RTC/AEC 和真实通知验证。
- 资产整理已完成确认冗余项；[版本与资产索引](../versions/ASSET_VERSION_SUMMARY_20261110.md) 记录归档与保留项。旧 case07 STOP、case08 未激活、旧已耗/未耗事实保留；不继续退役冻结链。

开发顺序：完善 APP 功能与真实开发链 → 协议加密等安全封装 → 集中产品验收。普通实现连续推进，仅做受影响检查与必要验证，不逐动作询问。现有鉴权/数据保护保留，UI按既定最后顺序处理。

[Owner 功能优先决定](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md) · [工作流](CURRENT_WORKFLOW.md) · [进度与未完成项](../versions/v10.1.5/PROGRESS.md)
