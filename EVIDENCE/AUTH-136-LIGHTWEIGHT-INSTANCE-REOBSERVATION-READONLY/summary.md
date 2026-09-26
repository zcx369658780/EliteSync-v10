# AUTH-136｜上海轻量应用服务器新预算只读复观

2026-09-26，Work 执行前 LEVEL 3 裁决：Owner 对精确问题选择“授权这一次只读查看（推荐）”。这是**新设**的列表→唯一概览 UI 查看预算 `0/1`，不是重用 AUTH-128 已耗尽的 `1/1`。入口和字段限定见 `TASK_CURRENT.md`；密码、真人识别、UAC 与任何实例内命令均不在授权内。普通证据不保存账号、实例 ID、地址、截图或页面原文。

执行前 Git：`main` HEAD `162a776a1124f1197d9399c11d76eb5ad490ec88`，仅两个既有无关未跟踪目录；本轮 `CURRENT.md`、`TASK_CURRENT.md` 与本文件为 Work 预运行记录。AUTH-128 仅接受旧 UI 观察且 `TARGET_BINDING=UNKNOWN`；AUTH-135 是本地 schema 与旧 CLI 聚合对照，不证明当前线上结构。本次只看控制面对象，不改变上述结论。

**执行回执：未开始。** 浏览器控制接口初始化两次均返回“failed to write kernel assets: 系统找不到指定的路径”，没有页面状态或已认证内容返回，也未创建/导航浏览器标签。`FAILURE_CLASS=LOCAL_BROWSER_TOOL_INIT`；`VIEW_BUDGET=0/1`；`PRODUCT_CLASS=UNKNOWN`、`REGION_MATCH=UNKNOWN`、`SINGLE_INSTANCE=UNKNOWN`、`OVERVIEW_MATCH=UNKNOWN`、`TARGET_BINDING=UNKNOWN`。此错误发生在控制台查看之前，不是登录失败或实例异常；未尝试其他入口、云 API、命令助手、SSH 或真实 DB。待工具恢复后仍须遵守原任务的单次范围和全部现场停点。
