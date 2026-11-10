# v10.1.5 Redmi文字往返与冷启动保持已实测，退出导航停止｜2026-11-07

**ACTUAL_PHONE_LOGIN_TEXT_ROUNDTRIP_COLD_T0_TOKEN_PRESERVATION_VERIFIED / LOGOUT_NAVIGATION_STOP / CASE03_SPENT_1_REMAINING_0 / G2_FALSE**

Owner明确回复“好的我授权”，另授修正观察器候选一次后端验证。case03使用同一源码Debug APK（SHA256 `974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`），源码身份22240c2c271b27446c8b01f8a204d9dfa360a54c、services树4530ae85754a2f3698d073182a47038708f2cb55；APK构建源码c5e2dc34、apps树b673913。复用只读726文件快照/114包vendor，未重建、重装或复制SDK，不重做框架迁移。

## 前置处理与实际成果

同机/主用户0/APK原字节重新核对。离线聊天页隐藏旧正文，本地MeLandingPage本来不显示账号姓名，不能把这些UI假设当实际身份显示证据。Android返回键未离开聊天，改用当前观察中的toolbar Back；基于上一轮已证实的虚构登录、同一开发包/用户及连续APP内导航，在APP正常退出旧fixture后取得空登录表单。原两次前置失败、STOP和输入原文保留，共用180命令计数；后台此时仍未claim。未卸载/清空、输入个人账号或启动旧库；旧服务器撤权NOT_RUN。

一次fresh入口核验启动可用9505MiB、卷空闲344332636160字节（仅本次历史值）。新空库迁移至93表/4个虚构账号，API/WS启动、health200；无新引擎启动/下载安装。正确未登录探针401、四个API虚构登录、A/B真实CN及MC放行、第三账号读拒绝404均通过。

手机经实际API登录虚构A，DB新增一个手机会话、初始T0基线及令牌元数据ID9/10。手机显示B的预置来信后发出文字，服务器确认进入实际APP UI。真实ChatMessage模型读取正文，和原始密文行按ID/actor/client_message_id/hash绑定通过；对端API读取手机文字200，再经实际API回复，手机显示回复，形成实际文字往返。直接DB消息证明在回复前采样为2行；回复API和后续手机读回有证据，不虚写最终DB行数已独立采样为3。

随后一次APP force-stop/Activity冷启动，新的phase、日志cursor、actor及完整UUID绑定的`auth/session/verify`实际200。冷启动前后同一个手机会话、T0/trusted_login_at、令牌元数据ID9/10保持，无新增会话；冷启动后手机重新打开聊天并显示自己的消息与对端回复。此为APP冷启动，不是数据库/服务重启验收。前轮密文比较和UUID截断问题在本次对应实际路径已越过。

## 最后停止与证据限制

退出前，记录显示点击了当前无歧义的“我的”按钮坐标，下一APP观察却是“慢约会旅程”页面。检查程序在该页面有界查找“本地设置”失败，随后停止；没有点击退出确认，当前后台日志无auth/logout请求，服务器会话撤销**NOT_RUN**。不能据此认定产品按钮映射错误或导航根因。

收尾后仅做一次离线原生UI诊断：当前“我的”按钮点击进入了预期本地Me页面，自有临时文件已删除，未重启后台/SDK、未恢复claim。该次成功不能解释此前异常，根因保持UNKNOWN。手机仍为本任务虚构登录状态，最后位于“我的”；后续须按当前APP实际状态正常退出/重新资格，不假定空登录。

独立未执行的导航候选先确认同一目标按钮在两次新观察中稳定，再要求连续两次看到本地Me特有内容，才允许查找设置；错误页面不再盲目滚动。捕获的错误目的页、目标变动、目标歧义和目的页不稳定等5项纯检查通过，真实导航修正/退出撤权复测NOT_RUN。未建后继后端scope/grant/claim，旧原件和STOP不改。

## 资源、收尾与接续

case03实际后端162.266秒，**已耗1、余0**；合计2GiB、启动3072MiB、1800秒/收尾45秒、工作卷8GiB/输出2GiB采样、一次start/migrate/seed及0次DB restart保持。三个新容器停止/PID0/无OOM，WS/API/DB退出0/137/0，API137不推测原因；新卷和网络保留。controller exit0/READY_SESSION_FINISHED不是整体PASS。

集成收尾时累计158条ADB（含全部前置处理），2次Activity、1次force-stop；其后8条离线诊断，共166/180条，无额度重置。一次手机登录/一次文字提交，SDK重编/重装0；两个reverse、原UI及诊断临时文件均已清理。149个既有容器完整State事后一致且全停止，共享引擎运行；旧库/SDK/AVD/备份/全部STOP和%SystemDrive%保护。

前置纯6/10/11项检查、观察复用边界检查与非作者静态复核分开保留，不冒充产品实测或外部独立验收。LOCAL_ONLY根名`v1015-redmi-source-debug-api-integration-20261107-case03`，先读`IMPLEMENTATION_REPORT.md`、`phone-text-roundtrip-proof-private.json`、`phone-cold-resume-proof-private.json`、`cold-fresh-verify-event-private.json`、`integration-case03-failure-private.json`、`integration-case03-cleanup-private.json`、`offline-tab-one-observation-private.json`与最终保存回执。保护ledger承接18393项，只追加本节点原证，不重扫旧SDK/AVD/Sources；密钥、设备原证、私有日志不上传GitHub。

仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING。文字权限完整矩阵/并发、媒体、离线15/30天、通知、合格RTC与同一最终候选API→DB→Web→重启集中验收继续未完成；本节点不等于整版接受。后续实际后端验证须另授一次，原手机/Docker许可保留；不合main/发布、不启v10.1.6。
