# R1 本人处罚申诉运行补充

沿用 [原Runbook](RUNBOOK.md) 的同一专用树、0.8数据库/volume/localhost服务、私配和指定AVD，不重新init/seed。仅新增迁移 `2026_10_15_090000_create_sanction_appeals`；实际已应用，正常复现不用再迁移。Docker启动后确认ready再访问，避免将初始握手失败当作源码缺陷。

最终R1包、安装hash和源码见 [R1_manifest.json](R1_manifest.json)，不要使用原Manifest里的初始APK代替新增申诉入口。私有账号仍仅在Q/secrets；新增具名键 `r1restricted`(ID11)、`r1peer`(ID12)、`r1stale`(ID13)，不打印密码或token。原账号保持原业务状态，尤其原Alice禁用不应为复现而恢复。

用原启动脚本安全复用已有容器、启动front/PHP，必要时启动指定AVD与ADB reverse8000。R1不需要Matching worker，没有新Matching任务。APP安装最终R1 debug APK后，正常退出当前账户并登录虚构r1restricted；不要卸载清数据或wipe模拟器。APP“我的”→“本人处罚与申诉”→读取，显示有效Restrict4与已提交appeal1。说明与状态从服务端读回，申诉不会解除限制。

已存在appeal1不可更改或再次制造首提：同文重试只返回同ID200，异文409；不要清空记录来制造201。如确需新的首提验证，须用具名追加fixture及现有UserGovernance产生新Restrict，保留原记录且标明fixture，不能改旧accepted业务事实。

Blade使用有权admin登录，访问 `/admin/users/11`，“被处罚者本人申诉”显示用户11/处罚4/申诉1及同一说明/提交时间；访问形成有限审计。本文不提供密码，也不授权外部用户查看。举报人原 `/moderation/reports/{reportId}/appeal`仍是另一合同，不用于处罚对象申诉。

正常负例：peer12对处罚4 POST404；禁用Alice旧token新申诉入口401；独立用户13已恢复处罚5，GET无有效处罚、POST404但appeal2历史仍保留。不要将正常403/404改成200来“修复”。r1restricted合法历史消息3仍可读；双向新消息发送拒绝。只有另行明确双方当前许可及合法账号状态能授予新互动，申诉记录本身不授予权限。

重启只能核归属后停止本版front/PHP、指定APP与0.8容器；保留同volume，不reseed。重启后重新在APP读取、Blade查看申诉1，并核DB记录、处罚、CN/MC、历史可读与新发送拒绝。实时查看会新增审计/已读，比较核心状态需区分这些预期副作用。R1实测快照在所有后续浏览器读之前取样，重启比较全部一致；后续详情读取追加view审计属预期。

最终测试标签、实际失败与修复、原始流及停止记录由R1报告和安全索引固定。物理包及私配仍LOCAL_ONLY，不上传GitHub；完整首版成功证据不重写。停止点为Astra R1独立复核。
