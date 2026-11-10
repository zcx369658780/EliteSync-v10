# v10.1.5 修正探针候选已获一次授权，USB断开在claim前等待｜2026-11-07

**NEW_ONE_SHOT_AUTHORIZED / USB_DISCONNECTED_PRECLAIM / SPENT_0_REMAINING_1 / BACKEND_NOT_STARTED / G2_FALSE**

Owner对上一节点修正探针候选一次后端验证明确回复“我授权，请继续”。新范围`V1015_REDMI_SOURCE_DEBUG_API_INTEGRATION_20261107_02`，后端合计2GiB、启动可用至少3072MiB、1800秒、收尾45秒、工作卷8GiB、输出2GiB采样；一次start/migrate/seed、0次DB restart，离线、不重编APK。case01仍已耗1余0，旧合同/claim/STOP均未修改；不是靠改目录恢复旧额度。

新输入引用同一只读726文件后端快照、同一现有114包vendor，无源码/SDK/依赖重复物化。源码身份1847651b589aaabcfee02a53a33e02a5fb65f51e，services树4530ae85754a2f3698d073182a47038708f2cb55。仅身份隔离及首探针改为已注册受保护的GET account/sessions；新DB/容器/网络/卷使用case02身份，不触碰旧库。尚未生成动态运行合同、claim或任何新Docker资源。

前置纯检查通过：6项APP过滤/可见坐标、10项取消/phase/端口边界、首请求拦截；语法和身份替换通过。非作者Codex复核未见新P1/P2，不是外部独立验收。源码Debug APK及已验真机热重载成果保持。

手机资格检查首先确认同一Redmi、主用户0、已安装APK SHA256 `974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`；Activity命令成功送达已有前台实例。随后uiautomator提示本任务唯一文件已导出，但返回255。未重做dump；只读一次该文件以查明结果时，ADB明确报告目标设备not found。未取得有效XML，因此不能把导出判作成功，也不推定为产品缺陷或手机锁屏。

当前**后台尚无claim，已耗0、余1**，API/DB/WS未启动、无登录/文字/冷启/退出验证。手机累计8条ADB、1次Activity启动、0次账号提交、0次重装；同范围180条命令/3次Activity额度累计，不重置。无reverse映射；本任务UI临时文件可能已生成，清理等待同机重新连接，不声称已清理。

已请求Owner重新接好USB并保持手机解锁，等待明确连接回复；不轮询连接、资源或自动启动后端。断开阶段STOP及输入原字节已封存。条件式接续脚本须先有Owner连接回复、核对旧STOP hash，再确认同设备/用户/APK、清理已知本任务临时文件并取得新的目标APP空登录观察；沿用相同手机计数和未用的一次后端授权。未将旧dump、旧资源快照作为启动依据，既有手机调试/Docker权限不重新询问。

LOCAL_ONLY根名`v1015-redmi-source-debug-api-integration-20261107-case02`，入口为`phone-disconnect-preclaim-seal-private.json`、`stopped-dump-artifact-diagnosis-private.json`、`owner-new-one-shot-grant-private.json`、`prepared-private.json`及保存回执。设备标识、原始日志和私有凭据不上传。检查前146个既有容器全停止；本阶段未发Docker start/exec或API请求，现有引擎保持运行。

仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING；不合main/发布、不启v10.1.6。原dirty根、旧SDK/DB/备份/STOP与无关%SystemDrive%保留。接续不需要再申请后端次数，须先恢复并核实USB连接。
