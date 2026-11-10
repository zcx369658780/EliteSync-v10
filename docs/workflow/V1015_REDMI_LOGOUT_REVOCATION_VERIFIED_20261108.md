# v10.1.5 Redmi退出撤权集中补验通过｜2026-11-08

**ACTUAL_PHONE_APP_LOGOUT_API_DB_REVOCATION_VERIFIED / FOCUSED_SCOPE_COMPLETED_SPENT_1_REMAINING_0 / G2_FALSE**

Owner对上一条待确认的一次集中补验回复“请继续”，本范围只补真实APP退出、API及数据库撤权，不重放已通过的文字和冷启动测试。独立范围`V1015_REDMI_LOGOUT_REVOCATION_20261108_01`；旧case01–03、旧构建额度、claim和STOP不退款、不复用。

## 授权、环境与输入

最初指定手机不可见、现有Docker Linux引擎未运行，后台在claim前保持0耗/余1。Owner随后明确回复“手机已连接解锁，允许启动现有引擎一次”；同一目录、同一未用后端授权继续，原前置失败/STOP和累计手机计数保留。已安装Docker Desktop原exe hash与既有固定值一致，一次Hidden启动及Linux引擎就绪已记录；未创建新VM/Windows Sandbox、下载升级或接受新许可。

重连后核对同一Redmi、主用户0、已安装源码Debug APK SHA256 `974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`，实际已为空登录表单。本次没有先退出旧fixture，也不声称旧服务器已撤权。APK未重编/重装；构建源码c5e2dc34、apps树b673913保持。

本次服务源码88c3c7d097c6f3b8ae819794dac9fdd8de09c737，services树4530ae85754a2f3698d073182a47038708f2cb55；复用只读726文件快照和114包vendor，无SDK/源码重复物化、Composer安装或框架迁移。一次既有入口完成fresh输入/镜像/网络/资源核验；启动可用8863MiB、工作卷空闲355921518592字节，仅为本次历史观测。

## 实际退出与持久化证据

新私有空库初始化至93表、4个虚构账号，API/WS及health200就绪。未登录会话接口401；先由同一虚构A账号建立API哨兵会话，再由手机经实际APP登录A，数据库确认新增独立手机会话及两枚令牌元数据ID3/4。

APP导航使用本轮已审候选：点击目标需两次稳定观察，进入本地“我的”需两次特有页面内容确认，再从当前观察进入本地设置并正常退出。手机实际返回登录页；新phase、日志cursor、actor和完整会话UUID绑定的`POST /api/v1/auth/logout`实际200。

随后直接读取同一合格MariaDB：手机同一会话行从未撤销变为revoked_at非空，用户/device/T0身份未替换，手机access/refresh两枚令牌元数据ID3/4均已删除，无新增/丢失会话。另一个同账号API哨兵会话未撤销、T0及令牌ID1/2保持，并实际调用会话接口仍200。这不是只凭登录页面或退出码判定撤权。

本次集中退出撤权工程分项**通过**。未直接拿手机旧令牌再发HTTP请求，旧令牌HTTP拒绝NOT_DIRECTLY_TESTED；设备缓存零写入NOT_DIRECTLY_MEASURED。上一轮异常跳转原因仍UNKNOWN，本轮成功不追溯改写旧失败。文字往返和APP冷启动保持沿用上一轮对应原证，不写成本轮重测，也不拼成整版G2通过。

## 限制、收尾与接续

后端实际125.656秒，已耗1、余0；本轮现有引擎启动一次也已使用。后端合计2GiB、启动3072MiB、1800秒/共享收尾45秒、工作卷8GiB/输出2GiB采样、一次start/migrate/seed及0次DB restart保持，无重试。三个自有容器均停止/PID0/无OOM，WS/API/DB退出0/137/0，API137原样保留；新卷和网络保留，cleanup_errors为空。

手机累计75条ADB（含最初不可见的一条），1次Activity，0次force-stop/重装/SDK构建；两个USB reverse及自有UI临时文件均已移除，手机最后为登录页。152个既有容器完整State事后与引擎恢复后的运行前基线完全一致且全停止；无旧容器start/exec或旧库/卷操作。共享Docker引擎保留运行，不擅自关闭。

6项APP边界、12项退出事件/会话/token边界纯检查及语法/身份检查通过，既有导航候选5项纯检查承接，本轮没有重跑这5项。非作者Codex静态复核与实际原证复核分别记录，不是外部独立验收。LOCAL_ONLY根名`v1015-redmi-logout-revocation-20261108-case01`：先读`IMPLEMENTATION_REPORT.md`、`verified-phone-logout-revocation-private.json`、`fresh-phone-logout200-private.json`、前后DB快照、`logout-integration-cleanup-private.json`和最终本地/Git回执。保护ledger承接19155项，只追加本节点原证，不重扫旧SDK/AVD/Sources；设备标识、凭据、私有日志不上传。

整版仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。后续仍为消息权限完整矩阵与并发、图片/短视频、离线15/30天及清理失败、通知生命周期、合格双端RTC/AEC及同一最终候选API→MariaDB→独立Web→重启集中验收；不因本次分项通过放宽冻结标准。不合main/发布、不启v10.1.6，原dirty根/旧SDK/DB/备份/全部STOP与%SystemDrive%保护。
