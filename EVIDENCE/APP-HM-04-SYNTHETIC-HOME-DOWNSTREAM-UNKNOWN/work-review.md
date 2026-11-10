# APP-HM-04 Work 独立审查｜2026-09-29

**LEVEL 2 REJECT 作为完整的下游未知状态边界；候选差异保留。** Work 核对作者摘要 SHA-256 `C38CDC5B0D987F803AC5A82B0ADE969F1E6F2828FFDFFFD098C646C445283C7A` 与最终文件哈希：provider `18338B3D5EDF4EDA86AAB9C3B19DAC68FD8CFB65726EE9D73518D028475580F3`，定向测试 `3D3DFD34D1009A8AB6D88BD496D6377F151A23B8632956800256482AF94F9640`。作者格式复核均退出 0，Flutter 定向测试首跑 8/8 通过，`git diff --check` 退出 0；旧预算耗尽。

候选对两类缺失来源正确清空了 synthetic `authoritativeNextDecision`，但 Conversation 缺失时 `ConversationAccessSnapshot.notYetEstablished()` 的内部默认 `state=ProductConversationState.locked`，Home provider 仍无条件输出 `conversation.state.code`，使 `HomeStateSummary.stateCode='CV_LOCKED'`。这与摘要的 `authority=notYetEstablished` 冲突：下游读取该状态码仍会把未建立当成已知锁定结果。现有新增测试只核对 Conversation 的 authority，未断言 `stateCode`。这正落在本任务“未建立时不冒充负向结论”的目标内，因此不能作为完整切片接受。

修复应仅让 Home 对无 synthetic Conversation 来源输出 `stateCode=null`，并加入对应负例；不要修改 ConversationAccessSnapshot 的安全默认、真实权威合同或其他领域。须另立新预算，APP-HM-04 的 1/1 验证不重置。APP-T12 G-08、真实 CN/MC 来源、AUTH-170、恢复/账号门均未因候选通过。无提交、pull、push或真实数据动作。
