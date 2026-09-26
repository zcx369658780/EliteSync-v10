# AUTH-126｜目标产品类型冲突停点

**BLOCKED_WRONG_PRODUCT_CLASS；作者未交可放行候选，交 Work 作 REJECT/改派判断。** 2026-09-26，本地 `D:\EliteSync-v10`、`main`，启动 HEAD `6c89ec96d799d4f54da9fcf184a9493b328a44ff`。`TASK_CURRENT.md` 指定未来 ECS 控制台实例详情查看；本轮只允许写本 `plan.md`。

精确冲突来源：`EVIDENCE/AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET/packet.md` 第 9 行记录 2026-09-24 15:50～15:55（Asia/Shanghai）已登录控制台的受限观察：上海**轻量应用服务器**公网 IP 与授权目标一致，Owner 确认为后端服务器；同一观察中，ECS 上海列表未见实例，页面提示全部地域未见实例。第 13 行明确“轻量应用服务器不等于 ECS 或 RDS”；第 47 行说明该 UI 观察不等于云 API、全局资源或权限证明。旧观察不能证明今天仍无 ECS，但足以使本任务预设的 ECS 产品类别与已接受目标线索冲突。

`EVIDENCE/AUTH-02-ALIYUN-CORRECTED-KEY-SOURCE-IDENTITY/summary.md` 的历史 SSH 地址和 AUTH-17 的远端回执都没有把目标证明为 ECS；AUTH-123 的本机格式类别、AUTH-124/125 的静态路径也没有关闭资源类型缺口。因此停止把 ECS 页面写成可放行候选，不转去轻量应用服务器页面，不自行改任务范围。目标产品与新任务需由 Work 裁决；实例身份、现时公网地址、服务器 host-key 独立来源及有效 SSH 端口仍 `UNKNOWN`。

本轮仅匿名只读核对公开 ECS 实例详情文档和本地证据；**未打开 Owner 账号控制台、未登录或请求密码、未访问轻量应用服务器页面、VNC、Workbench、云助手、SSH/DB/备份，也未重读 `known_hosts`**。原 ECS 草稿已撤回为本停点记录。运行测试 0；静态检查 **0/2**，没有消耗；无提交或推送。AUTH-121/122/123 已耗真实读取预算不重置，AUTH-107 Phase B 仍未放行。

## Work LEVEL 2 结论（2026-09-26）

**REJECT 原 ECS 实例绑定候选；接受仅“错误产品类别、尚无现场动作”的停点事实。** Work 独立核对 AUTH-24 `packet.md` 第 9、13、47 行：2026-09-24 Owner 确认的后端目标为上海轻量应用服务器，而非已证实的 ECS 实例；同次 ECS 列表未见实例。作者及时撤回 ECS 草稿，未将候选改走轻量页面，SHA-256 `AAC3AA6911FADD327B5463961BFF0E3D644EF57ED0919FB9CCCB665B5409D060` 为写入本结论前的停点记录。此拒绝不证明今天的云资源现状；只能要求后继静态任务先以已接受的轻量服务器线索核对公开资料，不能依据本任务进入任何账号页面。静态检查 0/2、现场预算 0；AUTH-121/122/123 旧预算不重置。
