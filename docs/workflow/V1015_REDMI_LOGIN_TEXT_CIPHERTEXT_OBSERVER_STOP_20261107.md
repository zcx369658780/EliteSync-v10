# v10.1.5 Redmi真实登录及手机文字入库，密文观察器误判停止｜2026-11-07

**ACTUAL_PHONE_LOGIN_AND_OUTGOING_TEXT_SUPPORTED / CIPHERTEXT_OBSERVER_ERROR_STOP / CASE02_SPENT_1_REMAINING_0 / G2_FALSE**

Owner确认“已重新连接并解锁”后，在case02原目录继续同一尚未消耗的一次后端授权。重新核对同一Redmi、主用户0、源码Debug APK SHA256 `974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`及空登录表单，断开阶段STOP原字节和累计手机计数保留。清理先前自有UI文件后取得新的有效APP观察；没有重装、清空APP或使用旧快照放行。

## 实际已完成

既有入口一次fresh核验通过，实际可用10479MiB、工作卷空闲344476098560字节（仅本次历史观测）。源码身份1847651b589aaabcfee02a53a33e02a5fb65f51e，services树4530ae85754a2f3698d073182a47038708f2cb55；只读复用726文件快照和114包vendor，不重做SDK/源码物化、Composer安装或PHP/Laravel迁移。APK构建源码c5e2dc34、apps树b673913保持。

新私有空库93表/4个虚构账号，API/WS启动、health200。修正后的`GET /api/v1/account/sessions`实际401，前一不存在路由问题已越过。4个API虚构账号登录成功，A/B真实CN及双向MC为ACTIVE，第三账号越权读返回404；只覆盖本次具名场景，不代表完整权限矩阵。

同一手机通过真实API登录虚构A账号，DB新增1个手机会话，初始T0等于trusted_login_at，令牌元数据ID9/10；并非冷启动保持结果。手机显示虚构B的预置来信，随后通过APP发送一条目标文字，API POST messages实际200，目标正文及“服务器已确认此消息”同次出现在APP自身UI观察中。实际MariaDB快照包含两行：B→A预置来信及A→B手机发信，消息ID、双方actor和client_message_id均保存。

## 实际停止及离线复核

Codex检查程序使用`DB::table('chat_messages')`直接读取存储列，却以明文正文筛选，得到0条匹配后触发AssertionError；程序未进入后续对端API读/回复、冷启动或退出。产品`ChatMessage`写入encryptString、读取decryptString，原SQL检查绕过了模型getter。这是观察器错误，不是已证明的消息发送失败；原执行文件、原始断言和失败记录保持不变。

后端停止后，只对已保存的本任务虚构消息快照离线验证：使用现有本地cryptography库核验Laravel AES-256-CBC封装和HMAC，两条密文均还原为对应的已知虚构正文，并绑定原快照hash、消息ID/client_message_id及UI确认文件hash。未输出密钥、未请求API、未重启DB或操作手机。这支持已捕获的实际消息入库证据，不冒充再次DB读取或Laravel模型运行复测。

另发现私有router把UUID形式device_session_id转为整数，丢失完整会话身份；会阻断计划中的精确冷启动绑定。冷阶段尚未执行，因此这是静态潜在阻断，不是本次实际停止原因。

## 修正候选与收尾

独立`observer-corrections-candidate`保留原始密文行，另经真实ChatMessage模型读取语义正文；检查器绑定原始/语义行的ID、actor、client_message_id和密文hash，拒绝解密回退为原密文的假通过。router保留完整UUID字符串；未来异常增加不含局部变量的traceback。原程序对捕获快照的失败已离线复现，11项纯边界检查通过；非作者Codex对具体实现及原证复核无新P1/P2，非外部独立验收。语义结果形状为fixture，**真实PHP模型/修正后冷启动绑定NOT_RUN**。未创建后继后端scope/grant/claim。

后端合计2GiB、启动3072MiB、1800秒/收尾45秒、工作卷8GiB/输出2GiB采样限制保持；一次start/migrate/seed，0次DB restart。实际后端112.5秒，case02**已耗1、余0**，无重跑。三个自有容器均停止/PID0/无OOM，WS/API/DB退出码0/137/0；API137原样保留，新卷/网络留存。controller exit0和READY_SESSION_FINISHED不是整体验证通过。

手机累计79条ADB、2次Activity启动、1次手机登录提交、1次手机文字提交、0次重装/冷启动；包括断开前和重连后的命令。两个USB reverse及自有UI文件清理成功，后台cleanup_errors为空。146个既有容器完整State事后回核相同且全停止，共享Docker引擎保持运行。手机仍停在本任务虚构账号会话；未执行退出，不声称令牌已撤销。后续新运行须先处理已知虚构账号的APP退出/空登录资格，或明确同一虚构会话的接续方案；不清空/卸载、不操作个人真实表单。

LOCAL_ONLY根名`v1015-redmi-source-debug-api-integration-20261107-case02`，读取`RUNTIME_IMPLEMENTATION_REPORT.md`、`phone-login-family-proof-private.json`、`captured-message-ciphertext-offline-proof-private.json`、`integration-usb-resume01-failure-private.json`、`integration-usb-resume01-cleanup-private.json`、`observer-corrections-candidate-manifest-private.json`及最终回执。密码/密钥/设备信息/私有日志不上GitHub；保护ledger承接17995项，仅追加本节点原证，不重扫旧SDK/AVD/Sources。

整体仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING。对端API读/回复、冷启T0/令牌保持及退出撤权仍NOT_RUN；独立Web、媒体/Push/RTC及集中验收未扩大。本次新增后端额度已耗尽，修正后实际验证需要Owner另授一次，手机/Docker既有许可不重复询问。原dirty根、旧SDK/DB/备份/STOP与%SystemDrive%保留，不合main/发布、不启v10.1.6。
