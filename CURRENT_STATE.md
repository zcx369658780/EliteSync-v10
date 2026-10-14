# EliteSync-v10 当前状态

## 2026-10-14 v10.0.6 执行方案审议完成，正式计划冻结

**V10_0_6_FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED**。

依据Owner已批准的[APP恢复＋独立Web管理方向](PRODUCT_DECISIONS.md)，Astra接收Codex的 `V10.0.6 EXECUTION PROPOSAL — READY_WITH_FINDINGS` 并发布[正式计划](docs/versions/v10.0.6/plan.md)。本版只交付两条真实链：现有Android APP城市字段经实际API保存到同用户的users.city并在重进/重启后读回；独立Blade管理员登录、查询并禁用该虚构用户，旧token/refresh/新登录/资料访问失效，正常对照账号不受影响。不是mock展示、不是完整原APP恢复已经完成。

代码起点固定 `3a78c2c81859db682369fd6e03f6d98a3c2bbeb2`，Tree `59969abfc9d04185769b22af5f7ea5d629007a33`；[原草案](docs/versions/v10.0.6/PLAN_PROPOSAL_V0_1.md)在 `98649e89e223b92c5e7817b8f0f0361242c6c476`，与起点仅文档差异。允许复用专用clean工作树、版本分支与多次提交，不强制新建worktree或单父单提交。冻结发布身份以plan首次commit/blob为准，Owner手动派发后才执行。

### 本版明确环境范围，但尚未运行

- 复用Codex报告的PHP8.5.3/Composer2.9.5、现有锁定Laravel依赖和Flutter/Android工具链；允许按锁安装/补齐缺失包，不顺带升级技术栈。专用树vendor与配置独立，原根.env不复制。
- 启动已有Docker Desktop，建立独立MariaDB10.11容器/持久volume，必要时拉官方镜像并记录digest；库 `elitesync_v1006_dev`、loopback `127.0.0.1:43316`。原3306 MySQL9.6与原数据库不动。Docker管道当前不可用属于待实测环境问题，不是已运行事实。
- Laravel与Blade `/admin` 使用 `127.0.0.1:8000`；只创建管理员、待禁用用户、正常对照用户三个虚构账号。共享禁用动作、严格role＋明确名单、CSRF和session/token失效属于版本模块范围。
- 复用已有Android36.1 x86_64镜像创建专用 `elitesync_v1006_api36` AVD；允许ADB反向端口、从最终源码重建AAR/debug APK、安装操作截图及受控本地浏览器测试。宿主与Dart实际地址必须一致，禁止误用旧远端或mock。
- 原SQL gzip/VHDX只确认了Codex报告的存在性与大小，历史表/记录/媒体可恢复性仍UNKNOWN。本版不读取其内容、不解密/挂载/导入；历史数据恢复作为明确后续缺口保留，不阻塞新开发数据的真实链。

以上权限包仅随Owner明确派发正式计划生效；当前没有实施候选、服务/数据库启动、构建安装或测试结果。额外系统级安装/提权、版本升级、生产/真实数据和费用仍需具体授权；普通依赖/环境错误在已授权范围内同版修复，不再拆治理版本。

### 最近本地现场与读取边界

Codex报告专用工作树 `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，当前HEAD仍为3a78c2c、分支 `codex/baseline-v1005-be0636e`、CLEAN。此前九份新路线/指导已同步，原启动根 `D:/EliteSync-v10` 八份正文相同，AGENTS保留有效本地辅助约定。原dirty HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301` 和默认index保持，最近同步回执仅证明其相应范围及105项具名文件，不将旧109/11树计数作为永久门。

网页实际读取了GitHub当前入口、工作流、草案及ProfileController城市写入、Android宿主/构建和管理员中间件相关源码；Windows环境版本、端口/镜像/备份存在性、工作树保护属于CODEX_REPORTED。Astra未访问C:/D:原件、未启动本地环境。未来本专用实施树HEAD和源码将获准正常推进，原dirty根与无关成果仍不得覆盖。

### 保留成果、实际缺口和下一步

v10.0.0～v10.0.5的限定接受/集成保持，见[版本登记](docs/versions/README.md)。当前城市保存接口与用户禁用代码存在，但Web登录操作与完整跨端运行尚未实装或验证；本版必须用真实APP、浏览器、API和数据库证据，原Widget/领域PASS不能代替。

[恢复台账](docs/architecture/RESTORATION_CAPABILITY_MATRIX.md)在本版内更新A01/A02/A04/B01和A03明确未恢复范围，不另建来源研究阶段。原版完整功能清单、历史业务数据、全部管理模块继续按[路线图](docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)后续交付，不能默默删去。

BE-12消息运行代码、V57/H1/H2/D0旧任务本版不改不复活；旧预算不是本次获准开发操作前置。生产、真实账号/身份、设备发布和公开运营没有授权。完成本版候选后由Astra独立终验，不自动v10.0.7。

[冻结前状态](https://github.com/zcx369658780/EliteSync-v10/blob/98649e89e223b92c5e7817b8f0f0361242c6c476/CURRENT_STATE.md)作为历史，旧“待方案”不覆盖当前冻结结论；本轮只发布计划和状态文档，不重复同步任务、工具链治理或基线维护。
