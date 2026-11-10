# 自主导航preclaim停止，原后端未耗一次保留｜2026-11-08

**PHONE_SCOPE06_PRECLAIM_NAV_STOP / BACKEND_SPENT_0_REMAINING_1 / PHONE_SUCCESSOR_PREPARED_UNAPPROVED / G2_FALSE**

Owner明确批准“新的后端及媒体验证一次”后，原scope06唯一入口执行。实际同Redmi用户0/已装b621fb88…包hash回核一致；原对话页显示连接/消息同意错误。程序只点观察到的Back一次，下一份原生快照仍是对话页，“我的”按钮未见，导航helper即抛错停止。14ADB（含精确自有UI清理1），输入/安装/Activity/force-stop/导入/截图均0；cleanup_errors空，无backend claim、未启动Docker/DB/API或引擎，**后端已耗0余1**。手机阶段已STOP，不能重开原入口或用未耗后端复活手机。

聊天页AppBar没有自定义返回处理/异步加载拦截；列表以push进入顶层聊天路由，通常保留下层消息页，但实际路由历史、触控命中、切页耗时及唯一原因UNKNOWN。现有快照只证明点后首份观察仍chat，不能确诊无pop栈或切页延迟，也不是图片上传/缓存修正失败证据。未到登录、选图或后端，图片/短片/冷启/播放/撤权全部NOT_RUN，新1f修正真机效果仍UNKNOWN。

仅修私有导航helper候选，不改产品源码：最多4份原生观测，等“我的”存在并稳定两份才点一次；若持续chat不出现则停止，无重复Back或猜点。前序原helper对保存chat立即失败，新helper在随后稳定目标出现时点一次、持续chat不点而停，3项host回归通过；另3项唯一未耗grant转交检查通过，原已审选图桥接保持。不是实际手机验证。

独立手机接续候选仅准备，**未授权、无transfer/claim/动态**：手机226条加前次14合计≤240，冷启/Activity/force-stop各1；复用已装包，不构建/安装。后端沿用scope06原未耗1（≤30分钟），新增后端次数0，不重复申请同一未耗次数。旧入口追加backend-stop封口，原phoneSTOP/claim不改；新的手机阶段获当前批准后，原子独占transfer绑定原批准hash、封口hash及唯一successor proposal/root，新backend仍新claim一次，原入口和其它successor不能消费。非作者静态/原证复核无P1/P2，manifest零差异；非外部验收。当前仍未批准新的手机阶段，不据本说明自动启动。

LOCAL_ONLY原根名v1015-autonomous-picker-media-20261108-case01（phone-media failure/STOP/orchestrator cleanup/14命令）；候选/最终回执根名v1015-autonomous-picker-media-continuation-20261108-case01（PREPARATION.md、最终manifest、host检查、独立复核、最终回执）。ledger承接24775项只追加两根新增材料及上一最终回执，不重扫SDK/AVD/Sources/保留缓存。产品apps/services树不变，原dirty main255/index及%SystemDrive%保持。仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，不合main/发布、不启v10.1.6；功能优先，UI最后按已定顺序。
