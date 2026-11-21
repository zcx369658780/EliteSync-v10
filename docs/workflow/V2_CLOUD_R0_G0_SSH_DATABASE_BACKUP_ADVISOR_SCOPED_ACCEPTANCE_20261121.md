# EliteSync V2-CLOUD-R0｜G0 SSH、旧DB归属与历史备份目录补证：顾问独立限定验收

日期：2026-11-21，顾问审核。状态：`G0_INSTANCE_IDENTITY_VERIFIED / G0_SSH_READONLY_SCOPED_ACCEPTED / G0_LEGACY_DB_BINDING_SCOPED_ACCEPTED / G0_BACKUP_METADATA_LINK_SCOPED_ACCEPTED / BACKUP_RESTORE_NOT_RUN / CAPACITY_UNPROVEN / CLOUD_STAGING_NOT_DEPLOYED / REAL_ADMIN_RESTORE_NOT_RUN / PRODUCTION_NO_GO`。

## 固定来源和独立性

- Codex固定GitHub报告 [9baa82aa](https://github.com/zcx369658780/EliteSync-v10/blob/9baa82aa0cdf947dcc4996d2a584c92e4f4535f1/docs/versions/v2/cloud-r0-20261121/V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md)，Git blob `f9416e6f2020285317d2d1671e6dbd6c6a800e4a`，开发分支`codex/v2-cloud-r0-gradual-staging-20261121`远端 HEAD回读一致。相对早期R0工程报告`e431e0c9fca2be95fd1481d6afdcbaefac9cb6c0` GitHub ahead3/behind0，比较文件仅同一报告，**没有产品源码或部署配置新增变更**。顾问是`ADVISOR_REPORT_AND_GITHUB_COMPARE_VERIFIED`，SSH回执、云控制台、云DB与远端原件未经顾问独立登录/复跑；两轮只读证据是`CODEX_REPORTED_REMOTE_READONLY`并附私有日志SHA。
- 本轮以Owner更正后的独立SSH私钥进行固定RSA host key严格校验、公钥认证、无agent/转发的root只读。此前另外一把名称相似的历史私钥身份认证失败（exit255）已如实保留，不得据此修改known_hosts或禁用主机校验。两轮有限只读盘点均报exit0，未读业务行、未执行恢复/改库/部署。外部共享文档禁止暴露私钥、完整凭据、SQL/管理员姓名与联系方式。

## G0范围审查

| 对象 | 当前可接受事实 | 不得推论 |
|---|---|---|
| 当前云实例 | 2026-11-21控制台与Workbench报告显示上海轻量应用服务器`Ubuntu-zlxh`在线、实例ID尾号`02be9a`，旧Nginx、FPM与主机库均有现场只读联系；SSH主机校验PASS | 不能凭root SSH权限自动批准真实生产部署或新数据库写入 |
| 旧Laravel | 旧站80与回环8088均用同Laravel根及PHP8.4 FPM；旧应用缓存声明mysql回环3306，schema确实存在于主机MariaDB10.11.14 | 健康/up200不证明完整业务可用，8088**不是隔离的V2 Staging** |
| 旧Docker与LiveKit | 唯一在运行的Docker容器为LiveKit，host网络、无挂载；命名卷0，其他组件如MariaDB/Redis/FPM以主机服务运行 | “无Docker卷”不等于“无业务数据卷/应用数据”，不得清理Docker、重启LiveKit或占用其端口 |
| 备份 | 历史目录有21组manifest/gzip/sidecar，gzip合计8,386,152字节；2026-05-08三份本地副本与远端**声明元数据**匹配：SHA、长度、schema、port | **远端gzip未重新哈希**，备份未独立恢复、可能过时且管理员范围未知；不能称数据可恢复，更不能直接赋权 |
| 容量/网络 | Ubuntu24.04、2vCPU/2GiB RAM/40GiB盘，读回约627–628MiB available、swap0、根盘24GiB free；公网防火墙443放行但主机无443监听；MariaDB/Redis仅回环监听 | 不能推出有余量同时承载第二套PHP/FPM/worker/MariaDB；外部HTTPS和带宽/成本仍未知 |

**独立顾问G0限定接受：SSH及旧DB归属只读核验阶段完成；备份可恢复性、并行容量与费用/回滚门仍OPEN。** 当前后端云部署状态继续`NOT_RUN`，不得把SSH登录作为正式切换资格。

## 进一步建议与具体停点

1. 优先保护**现时旧MariaDB数据库及LiveKit**。不重装服务器镜像、不覆盖Nginx、PHP-FPM、旧Laravel、原MariaDB/Redis、80/8088/443配置和任何数据目录；原实例既有业务仍算生产保护面。
2. 由现有Codex准备**最小G0b只读补证计划**，在原明确授权之外的任何新SSH调用前，复核当前目标/预算/凭据及Owner边界；建议限于备份远端哈希与索引、磁盘与内存/负载监测、实际服务端口、现时账单及快照/独立恢复目标，不读真实业务行。不因root权限可用而扩展取证。
3. 资源策略：首选**单独隔离Staging实例**（或已有可验证独立资源），经过费用上限与资产身份核实再开通；2GiB旧机不建议未经测算增加整套四容器工作负载。另一条在旧机上再启新MariaDB/FPM/worker的路线目前`CAPACITY_NOT_APPROVED`。
4. 备份策略：可继续验证不包含业务内容的身份/哈希元数据；**真实SQL解压、解密、数据恢复或旧管理员账户读取**另需准确源、操作者、合法用途、隔离恢复目标与Owner具名许可。2026年5月快照与现时旧库不能视为同一时点。
5. 管理员恢复：合成账号链已在R0限定通过，真实管理员依旧`DATA_GATE_PENDING`。等合格Staging的独立新库与受控恢复流程就绪再迁移最小已核主体，重新签发密码/MFA，旧token/session不导入。
6. 手机实测：只有云端独立TLS、APP原生与Dart端点均锁定无旧站回退、Connection合成门禁正反通过且设备授权已确认才开始。R0 G1本地PHP8.4/MariaDB三盘运行证明维持；云端G1/G2/G3真实操作均NOT_RUN。
7. 原PC清理13项仍白名单0，已删除0；旧星盘A/B/C与注册离线可信T0仍Owner待决，全量PHP/真实供应商/正式A6/生产继续NO_GO。

本报告只是顾问核对及下阶段建议，**没有自动执行新的SSH、购买实例、云资源写入、旧管理员真实数据处理或手机操作**。
