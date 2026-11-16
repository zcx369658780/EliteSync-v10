# v10.1.17 路线对齐确认

日期 2026-11-16。Codex 已核对稳定工程根、origin、任务分支、HEAD、工作区和 index，并保存原库及稳定根的局部恢复记录。原库 dirty/index、无关 `%SystemDrive%/`、私有配置、数据库、AVD 和历史原证继续保留。

本版唯一父基线为 `99a05c6f6d509c0607d8bff0d63b122d5cc84eec`，任务文档固定提交为 `8117980c8f2b2e8ada61db52450a9aca7b643e13`。20 份路线与任务文件逐 Git Blob 核对结果为 `LOCAL_DOCS_SYNCED`，详见 [同步回执](LOCAL_DOCS_SYNC_RECEIPT.json)。启动 Prompt 内历史任务 hash 差异已在回执记录，本次以 Owner 指定固定提交为准。

## 当前理解

- B3 是本版唯一授权范围。默认保留 Home、Progress、Messages、Me 四个底部入口，按用户目标整合现有功能。
- Home 使用 B2 user-state 及既有 next_actions。权威用户状态继续来自现有服务，客户端只负责呈现与导航。
- Progress 整理准备、参与、轮次与关系旅程，Match、Connection、Messaging Consent、Conversation 和 Relationship 保持各自合同。
- 自动化默认关闭，必须明确授权，沿 B2 生命周期、审计、幂等、lease/fencing 和有限重试合同。不得自动运行管理员匹配、接受匹配、建立关系、分享资料或发送消息。
- Buddy 独立于恋爱匹配，社区保持有限好友场景。必要隐私、关系承诺和不可逆操作确认继续保留。
- 九项旅程先测基线，再以相同虚构账号及相同逻辑状态后测。指标沿任务冻结标准执行。
- 视觉方向继续冻结，现有素材及实际模型 UNKNOWN 历史记录保持。B3 使用现有美术和主题。
- B4 运行时 AI、阶段 C 外部身份/信用/Push/支付未授权。Owner 整体实机验收在 B1+B2+B3 完成后进行，本版工程使用模拟器与隔离测试服务。
- 完成八项 AC、集中验证、独立包名候选、提交推送与同源回读后停止，等待 GPT 顾问验收。

编码前材料为 [现有旅程](CURRENT_JOURNEY_INVENTORY.md)、[操作成本基线](B3_OPERATION_COST_BASELINE.md)、[目标架构](TARGET_INFORMATION_ARCHITECTURE_V1.md) 及本确认。源码修改须在四份材料完成后开始。
