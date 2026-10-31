# v10.1.5｜Laravel13 本地开发三项缺口集中收口结果
日期：2026-10-31。任务：V1015_L13_DEV_3_GAPS_CLOSURE_20261031；正式任务 Blob：4080ba09cd83aa68537fcc719fb63f2dec312efc。
**CLEAN_LOCAL_L13_DEV_BASELINE_CLOSURE_CANDIDATE_AWAITING_ASTRA_REVIEW**。三项范围内实测PASS，未自行签署完整本地基线或整版功能接受。

## 来源与唯一范围
开工fresh main／候选sole Parent：e0baf03d4f63ab9fc22e65c8431b019017fded5f；Parent Root：0b8ad8ff8d88ab51ff68be0d76d54022c1b936fa。
已接受apps：3468a3dd97da7accfda2539a0f8d8f68931a6110；services：049a8676cc90b3b830e32a524c172720e800fa37。当前main、ACTIVE_STATE、正式任务、WORKFLOW、上轮Astra审查及bb94原Result/Manifest/Handoff、Seeder、四题库和两脚本均fresh读取。
既有入口来源仍为310456834fd653229b27748e44912de5ba9df66f，产品双Tree一致、Git clean；本轮不更新该入口源码/默认指针。前轮候选bb94a6c273c436aa9a88e9313f9ae662840aa6e7及Astra审查12072468f6a3f18b84ee508b2d9a0e03a6c33a6a仅为授权输入，不是本轮Parent。本轮只发布三份脱敏docs，不改main、apps/services、题库、Seeder、测试或上轮证据。

## 门一：QUESTION_BANK_MOUNT_AND_REGRESSION_PASS
正式main四份question_bank JSON分别核原生Blob、100644、UTF-8 JSON、尺寸/SHA256及本机身份，然后复制至本轮私有输入。新runner以四个ReadOnly挂载映射至 /workspace/question_bank；后端位于 /workspace/services/backend-laravel，保持原Seeder的base_path('../..')解析，不改逻辑、不使用旧单文件fallback。Runner受限UID、cap-drop ALL、只读root、network none；只挂新私有storage/cache/evidence，不挂MariaDB卷。
原 AuthQuestionnaireApiTest 两项首先实际运行：**2 tests /53 assertions /0 errors /0 failures /0 skipped，exit0**，JUnit及stdout/stderr/SHA保留。SQLite testing/:memory:门禁保持原Blob；父批次PREPARE前已预留SQLite迁移上界1、Seed批次上界2。
完整原60项本轮 **NOT_RUN**：定向两项需2批seed，再跑包含同两项的完整60需另2批，累计4超过任务上限3。不拆换、跳过原测试或重置预算来伪称完整60全绿。前轮58/60、284 assertions、2 errors原失败永久保留；本轮只证明两个原失败已真实转PASS。

## 门二：POPULATED_SYNTHETIC_MARIADB_PROCESS_RESTART_HASH_PASS
只触及授权的既有合成DB/API和唯一合成卷；启动前均停，卷无其它运行使用者，容器ID/image/mount/label/UID/cap/no-new-privileges/网络/端口与冻结配置一致。DB不发布宿主端口。没有旧/生产数据库接入。
启动后的重启前快照确认已有 **90表、83行、1个虚构user、4个token**。采用真实PDO只读事务取得每表DDL、列顺序、所有行：NULL独立表示，非NULL PDO原始字符串字节Base64编码，整行规范序列排序且保留重复，再SHA256；全部90表包括空表。原始行/逐表哈希序列、DDL、权限与可供恢复参考的逻辑快照只留LOCAL_ONLY，不宣称已做恢复试验。
对真正MariaDB容器执行stop→inspect确认Running=false/PID=0→start，同容器/同卷，之后观察新的启动时间和进程PID，卷文件系统身份不变。API未重建。再次采集90表，**所有逐表count、规范化全行hash及DDL完全相同**；schema/server_id/hostname/principal/MariaDB10.11.19/port和GRANT一致。授权合成用户可读回，系统schema SELECT越权仍被拒绝。没有对填充卷执行迁移、seed、drop或数据修复。
第一次本地身份比对因旧PDO元数据整数与本轮刻意stringify后的数值字符串类型不同而报错；文本完全一致，记录误报后仅规范数值元数据比较，行哈希口径未改，失败前没有执行重启。

## 门三：MANUAL_START_STOP_RUNTIME_PASS
新任务复制已核原生Git字节的原start/stop脚本及私有配置；旧原件未写。源start Blob38582fd4fe145961a30e3c74a0644bbaa41fb7c2、stop Blobf0bb6e41121b0efb912bdd5d51346be4f5aa0dcf，**无需脚本修订**。
真实PowerShell7从两服务停止态执行start-existing-dev.ps1，exit0；独立inspect确认两者运行。Windows宿主进程、禁止代理/重定向，实际获得健康200且DB ok、匿名401；专门MariaDB重启后再次200/401。最后通过原stop-existing-dev.ps1停两服务，exit0，再独立确认两者PID=0、runner已停、卷保留且无运行使用者。
本轮正常闭环实测通过；静态复核发现原start异常清理路径不检查stop结果，因此本轮不凭提示文字判断停态，而均独立inspect。健康超时/启动失败故障注入分支未测试，不把本次正常闭环提升为所有失败路径证明。Docker原 --time 参数弃用警告原样保留，不擅改冻结脚本。

## 单一服务序列与预算
顺序：独立SQLite定向测试→runner停→原手动start→Windows200/401→非空90表快照→真实DB stop/start→全行复核→Windows200/401→原手动stop→独立停态及保护回读。
为从严计费，脚本从STOP启动已有带数据DB也记DB进程启动/重启1次，加专门stop/start1次，共 **2/2**；API初始启动记1/2；手动闭环1/2；服务组2/2。脚本内部健康循环最多20次，在父进程前按20次上界预留；另有4次逐条Windows请求，**host HTTP预算计费上界24/30，不冒充实际发出24次**。源脚本成功条件证明至少一次内部健康成功，完整父进程日志与4条显式请求原始响应均保留。
其它计费：{"api_restarts": 1, "db_process_restarts": 2, "feature_batches": 1, "host_http": 24, "manual_cycles": 1, "php_cli": 4, "seed_batches": 2, "service_groups": 2, "sqlite_migrations": 1}。所有失败/超时/重试计入；SQLite子操作在父命令前预留，没有补造事前PREPARE。新增依赖/OCI供应、pull/build、Composer install/solver、填充MariaDB迁移/seed/drop、全局操作均0。
发布快照：802.110秒/10800；新root logical 2575549、allocated 2750568 bytes；另以 **2GiB保守上界计费**覆盖授权存量服务的本轮新增容器/卷/日志及宿主可写runtime mount增长，不借旧空间/预算洗白。已有不可变镜像/vendor保留，不重新供应。最终Git回读/封存后的真实计量与ledger SHA保存在LOCAL_ONLY终态回执，本文件不是最终峰值。

## 保护、交接与停止门
原默认Laravel11 HEAD4bebc8f394248e254c1368a06fbdee5d2c883301、dirty252、refs527、index/HEAD及旧vendor身份保持；旧备份11066文件/240617393 bytes，Manifest SHA2563f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d保持，按本轮触及范围抽核160项身份/尺寸/SHA。14项历史/来源STOP封存只读核验；旧18/两ACL/122原证/3183Seed/五保护根未触及，先前证明保留，不谎称本轮重新全盘复验。
原bb ledger和原脚本/配置保持原SHA；任务授权的活动服务缓冲区新增写入单列计量，历史raw logs/账本/验收未回写。没有删除、移动、覆盖旧版或备份，没有修改默认入口、Windows防火墙/ACL/PATH/策略、Docker context默认值或Desktop/WSL。
全部允许触及的服务现已停止，runner/合成卷保留，无自启动。候选仅三份docs；其Commit/sole Parent/Root及全文Blob由包含自身的native Git对象和最终fresh回读回执绑定，不制造循环自SHA。提交回读后永久STOP，余额不复用，不派后继。
三项运行事实属于CODEX_REPORTED_LOCAL_RUNTIME；Astra尚未独立验收本轮。旧合成L11→13七项只引用先前有界接受，本轮不重跑；真实旧用户Cookie、OS_ENFORCEMENT仍NOT_PROVEN。v10.1.5仍10 PARTIAL/1 OPEN、AC05 OPEN、G2 false、Push pending、v10.1.6 NOT_STARTED；Windows E_NOTIMPL、历史事故和EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED原样。完整APP/生产/真实用户/设备/RTC/AEC/Push/H264/物理15/30天均未运行。
