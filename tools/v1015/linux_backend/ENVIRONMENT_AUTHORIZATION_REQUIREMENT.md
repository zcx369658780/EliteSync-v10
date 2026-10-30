# 一次集中环境授权需求（说明材料，不是已发布后继任务）

当前已有 WSL2 2.6.3、已注册但停止的 Ubuntu-24.04 和 docker-desktop，以及 Docker29.3 CLI；指定本地引擎管道不存在。没有证明“未安装WSL/Docker”，更没有安装失败或必须重装的证据。

建议最小新增授权是：**由Owner启动/明确授权启动已有Docker Desktop的WSL2 Linux后端；只读确认Desktop/engine版本、许可、Ubuntu release和架构；然后在新的冻结综合预算内复用本预包继续真实solver和隔离API/DB。** 本轮的动态STOP和6项inventory不因这些说明恢复。

无需先申请重新安装WSL或升级宿主。若Owner选择安装而不是启用已存在组件，候选包仅为Docker官方Windows x86_64 Docker Desktop Installer.exe（官方入口 https://docs.docker.com/desktop/setup/install/windows-install/）；实际维护版本、下载跳转、SHA256和Microsoft/Docker签名必须事先重新冻结，当前均未取得，不存在可直接批准执行的任意latest安装器。WSL当前已安装，安装包数量建议0；禁止额外Linux发行版、Hyper-V切换、WSL update、VC或系统DLL变更。

许可：Docker Desktop个人/教育/符合小企业条件可免费；较大企业商业使用需付费订阅，组织资格由Owner确认，不由Codex推断或发起购买。镜像、PHP、Composer和MariaDB各自license/provenance仍需按实际选中版本归档。

权限及变更：仅用户会话启动已有引擎和既有WSL2后端，不授予UAC、Windows功能/服务/注册表/ACL/PATH/php.ini或全局VM配置修改。若启动要求系统更改，即STOP并一次性列出具体变更。Docker Desktop启动可能启动共享后台组件，必须由Owner批准；这不等于允许访问既有项目容器/数据。

保护及回退：不导出/迁移/注销任何既有发行版，不删除或清理镜像、volume、旧任务、数据库、ledger和dirty。后续只为新任务创建专属镜像/网络/volume与回环端口；失败保留原始回执。回退只停止由新任务创建且身份已核的服务；不自动shutdown整个WSL或退出Owner原有引擎，不删旧资产。

资源及下一综合预算建议：task-owned占用≤16GiB、服务组内存≤4GiB、单调窗口≤240分钟、受控官方镜像/依赖≤2GiB/500请求/8个Digest、build≤3、solver≤3、vendor≤2、PHP CLI≤120、Feature/Unit≤5、服务组≤4、业务HTTP≤240、迁移/seed各≤2。**这只是集中建议，不继承本轮余额，不在此材料中授予或启动任何动作。** 实际端口须在启动前检查一次并固定，禁旧43349/43359和所有占用端口。

Laravel13只为主候选，Laravel12为真实兼容阻断后的回退；先solver后源码适配和真实回归，最终仍待Astra与Owner取舍。无论Linux以后是否通过，Windows E_NOTIMPL和旧原生资格未通过的历史不改。
