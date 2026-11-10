# AUTH-138｜轻量服务器详情单次只读查看

2026-09-26，Work LEVEL 3 执行前裁决：Owner 在 AUTH-136 列表查看预算耗尽后新授权“直接在网页端的服务器详情查看信息”。仅看当前官方控制台已打开的上海轻量实例详情页，直接读取本页可见字段；不点击其他功能、页签或实例，不刷新、不重试。开始读取已认证详情前新预算 `0/1`；旧 AUTH-128/136 各 `1/1` 不重置。普通证据不保存页面原文、截图、账号、实例 ID、地址、端口、公钥/指纹原值。

执行前本地 `main` HEAD `5957832cb909e27bf12d268c6903503ff0a31f24`，仅两个既有无关未跟踪目录。AUTH-137 的 SSH 方向授权不放行连接；本任务更窄，仅取控制面详情页观察。

## 单次脱敏回执与审查

观察时点：2026-09-26，本次 Owner 新授权之后；未保留更精细时间戳。Work 仅读取当时已认证的官方上海轻量实例详情页一次，未刷新、导航或点击其他功能。新预算 `1/1` 已耗尽；旧 AUTH-128/136 各 `1/1` 不重置。

| 字段 | 结果 |
| --- | --- |
| `PRODUCT_CLASS` | `LIGHTWEIGHT_APPLICATION_SERVER` |
| `REGION_MATCH` | `YES` |
| `INSTANCE_PRESENT` | `YES`，页面有实例标识，原值不留存 |
| `RUNNING_STATE` | `RUNNING` |
| `PUBLIC_ADDRESS_MATCH` | `YES`，与 Owner 新提供的候选一致 |
| `PRIVATE_ADDRESS_MATCH` | `YES`，与 Owner 新提供的候选一致 |
| `IMAGE_LABEL_DISPLAY` | `UBUNTU_24_04`；仅是页面镜像标签，不是实例内运行证明 |
| `CLIENT_KEY_PAIR_NAME_MATCH` | `YES`；只关联客户端云密钥对名称，不是服务器 host-key |
| `COMMAND_ASSISTANT_LABEL` | `INSTALLED`；不证明执行身份、留存边界或现场授权 |
| `SSH_PORT_DISPLAY` | `UNKNOWN`；本页未直接显示有效 SSH 端口 |
| `SERVER_HOST_KEY_DISPLAY` | `UNKNOWN`；本页未直接显示现时公钥/指纹 |
| `FAILURE_CLASS` | `NONE_OBSERVED` |

Work LEVEL 3 **ACCEPT 仅上述控制台页面字段一致性观察**。Owner 指定的控制面目标与本页地址候选相符，但没有独立实例标识链，故先前严格的 `TARGET_BINDING=UNKNOWN` 不升格为独立技术绑定。`SERVER_TRUST_SOURCE=UNKNOWN`、`PORT_VERIFIED=UNKNOWN`、`LIVE_DB_SCHEMA=UNKNOWN`；不能从客户端 PEM、云密钥对名称、镜像标签或命令助手安装标签推导 SSH 首次握手可信、实例内 sshd 监听或数据库结构。`COMMAND_ASSISTANT_EXECUTION=0`、`SSH=0`、`DB_READ=0`、`DUMP=0`、`BACKUP=0`。后续需要独立新任务审查精确只读信任来源和 Owner 对具体现场动作的授权，不重读此页预算。
