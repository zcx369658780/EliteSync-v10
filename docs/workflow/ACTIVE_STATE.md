# 当前入口｜2026-11-10 功能主链与通讯安全封装

Owner普通工程长期授权持续有效：功能优先，随后安全封装和集中验收；持续推进直到Owner明确叫停，再保存、停止自有运行服务并手动交接。上下文压缩不是停止指令。手机由Owner使用，不连接、读取或操作手机。

- 产品根 `D:\EliteSync-v10-product-v1015-20261101`，分支 `codex/v10.1.5-software-continuation-20261101`；先核实际Git身份/index。原主库main/255项状态/index及无关 `%SystemDrive%/` 保留。资产清理已结束，不重盘点、复制SDK或恢复旧STOP。
- GitHub连接已恢复，a2487847及此前暂待同步的提交均已确认推送；未更换身份或修改系统网络。
- 已实现消息历史/重试/断网恢复、附件恢复、通知分页/偏好、消息列表更新、图片完整预览、短视频进度/重播及通话恢复。实际双模拟器已完成登录、双向文字、图片选取/发送/预览、短视频选取/发送/播放到结束；最新896候选又通过确认丢失后原UUID重试（message15仅一条）。各候选与原回执分开，详见PROGRESS。
- 当前已安装APK：源码 `a2487847d9df679c585aacb2cc598995eaa3dcba`，SHA256 `9b87b8580d792b16bcb2c4d772a42f7c368488cd9f5da8ea176c4ca8341f0972`，154104232字节，35.709秒构建。签名/身份及RTC/重放新JIT标记通过；本机call7语音双向RTP和UI挂断通过，0.938秒房间消失。此前612媒体、426通知、896重试/视频、ccf本机TLS兼容等原证继续按各自身份保留；不合并为最终整版PASS。
- RTC已证双方音视频RTP/生成画面、UI挂断、一次自动重连恢复，以及正常MC撤销后房间消失（call6为0.297秒；仅房间清理子证据）。当前call1–7均ended，无活动房间；MC generation3，旧房间未复活。call7已实际看到原生聚合波形活动；先前call6未见bands的原记录保留。AEC/听感、完整≤5秒停媒及旧JWT矩阵未完成。
- 重启登出缓存清理已修复：固定owner仅定位精确删除，不解锁读取/时钟；21项缓存＋5项auth检查、analyze与非作者复核通过。已在当前APK；Android底层清理独立核验仍NOT_RUN。未知旧未索引资产不扫描、不宣称全清。
- API TLS/同源与禁止redirect、正式Bootstrap拒绝外部端点覆盖、Android主资源禁明文/Debug精确本机例外，已合包并验证本机兼容。RTC URL校验45项及重放统一42项检查/analyze/非作者复核通过，已进入当前APK。未访问、部署或发布外部服务，不称整体加密或端到端加密完成。下一项为官方WebRTC补丁依赖升级，保留现有LiveKit架构。
- 自有开发服务和两模拟器仍运行；精确容器/卷/PID/端口在私有 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev\runtime-private.json`。专用ADB5038只连接emulator-5580/5582并排除USB。临时确认丢失代理已停止，API映射恢复；缓存核验debug forward已移除。源码Debug固定构建回执在 `v1015-source-debug-workspace/state/current-functional-build.json`。
- 仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING、真机缓存UNKNOWN。15/30边界、Android真实密钥库/清理、完整权限/并发、通知与RTC质量矩阵、剩余安全封装和最终集中验收未完成。UI按我的/设置→消息列表/聊天→首页/导航最后处理。

下一步：完成重放的传输封装与定向复核，再把RTC地址校验一并纳入必要候选；不重做已通过主链、不逐操作申请。Owner叫停时只收尾保存、停止自有服务/模拟器，保留数据卷和共享引擎；不合main、不发布、不启动v10.1.6。

[Owner长期授权](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md) · [工作流](CURRENT_WORKFLOW.md) · [进度及证据边界](../versions/v10.1.5/PROGRESS.md) · [资产版本摘要](../versions/ASSET_VERSION_SUMMARY_20261110.md)
