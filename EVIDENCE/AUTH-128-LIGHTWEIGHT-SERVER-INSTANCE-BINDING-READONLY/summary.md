# AUTH-128｜轻量应用服务器一次只读目标绑定

2026-09-26，Work 临运行裁决：Owner 在当前 Work 会话确认目标仍为 AUTH-24 同一账号、华东2（上海）轻量应用服务器，并明确本人在场、亲自处理登录后允许只读查看一次“服务器列表→唯一服务器概览”。AUTH-127 的静态候选已独立 LEVEL 2 接受；入口固定为阿里云官方资料指向的 `https://swasnext.console.aliyun.com/servers/`。只允许单页、单次，登录控件交 Owner，不使用截图或页面原文作为普通证据。查看预算启动前 0/1；任何异常即停，不重试。服务器 host-key、SSH 端口、DB 与备份权限均不由本裁决放行。

## 单次执行与 Work LEVEL 2 结论

2026-09-26 约 14:07（Asia/Shanghai），Owner 在固定的同一浏览器页自行完成登录并回复“已登录”。Work 只读观察官方轻量应用服务器上海地域的服务器列表（1 条）及其唯一服务器概览；概览显示地域、实例 ID、运行状态和公网地址，列表与概览互相一致，现时地址与 AUTH-02 历史线索相等。未操作认证控件、服务器功能或远端连接；未刷新、重试或改走其他产品。页面原文、截图、账号、实例 ID、地址及密钥均未保存到证据。

`TARGET_BINDING=UNKNOWN`；`PRODUCT_CLASS=LIGHTWEIGHT_APPLICATION_SERVER`；`SOURCE=OFFICIAL_SAS_SERVER_LIST_AND_OVERVIEW`；`FAILURE_CLASS=PRECHECK_MISSING`；`VIEW_BUDGET=1/1`。虽然同一页中的唯一候选、地域及地址匹配，但实例 ID 在查看前没有独立固定的可信来源；历史地址只提供线索，无法单独确认这台实例就是预定备份目标。故 **ACCEPT 仅本次受限 UI 观察事实，不接受强目标身份绑定**。本次预算耗尽，不再查看或重试。

独立服务器 host-key 来源、实际 SSH 端口、SSH/DB 权限、数据库目标及真实备份均 `UNKNOWN`、未放行。下一步需另立独立来源与风险门；Owner 此次授权不涵盖任何远端或备份动作。
