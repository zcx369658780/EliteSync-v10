# EliteSync v10.1.2｜Astra独立功能验收（含R1）

日期：2026-10-21；裁决主体：Astra，EliteSync GPT顾问；归档方式：**Astra直接写入**，不是Codex作者自行验收。

**V10.1.2_FUNCTION_ACCEPTED_WITH_OBSERVATIONS / R1_B1_CLOSED / R1_B2_CLOSED / MAIN_PRODUCT_INTEGRATION_NOT_STARTED / REAL_IDENTITY_PROVIDER_PENDING / V10.1.3_NOT_STARTED**

## 1. 精确接受对象

| 对象 | 固定GitHub对象 |
|---|---|
| 版本冻结计划Blob | `2ebd2ea05b3d7dae52cc3995de913eeb0fde375e` |
| R1审阅任务Blob | `75d98dd1be027230d923572be8e4ac94594839dd` |
| 原候选源码Commit | `ebade52179b6ac7b76ba2f2992d31981fa995a00` |
| 原完整交付Commit | `900942426e965092d3852771c4126d77210677c4` |
| **接受的最终源码Commit** | **`88ffeccce4042f13ce4edccf7604b835b06c8f2d`** |
| 接受的Root Tree | `42052f5f9ee596f82cf525884e1f77256fc7727b` |
| **接受的apps Tree** | **`365810451b6faad98e041835be6c86f4f81be0a9`** |
| **接受的services Tree** | **`96b2972a19ec49108cf5c11d144179e5693570a9`** |
| 最终实施报告Commit | `bdf86e69e4c9802699dfb3cda6dfc98b3227ed02` |
| 最终实施报告Blob | `6ad7e7f9678d2cb9f7f81f4c3812e5eed93712b4` |
| 原版制品清单Blob | `55eb35bc8bb8e2ff9dbc5ac5fba465a837f1a24a` |
| R1制品清单Blob | `efa0ea0c013f52fce1228adc2a0ba8c24f86d857` |
| R1独立脱敏审阅Commit | `94f41f4ef2455b7c89258437a5162c19cca2f1e8` |
| R1独立脱敏审阅Tree | `762ab7ee86ad41a5c548cd60ac637f7353a462ee` |

本次Astra直接通过GitHub核验完整Commit、Tree、两产品子树、R1相对原完整交付的15个实际变更产品路径与清单中15/15 Blob一致；R1源码的唯一Parent是原完整交付。原候选与R1候选分支及两份审阅分支HEAD保持既有对象。功能候选没有合并main。**归档此接受结论不等于安全集成已完成**。

## 2. 原阻断与R1最终判定

- **B1 / P1 已关闭**：原版真实合成HTTP无来源正式申请200、换键重发200；R1以当前ACTIVE好友或CN_ACTIVE、收件请求许可和source/permission revision为条件。不存在/禁用/Block/无来源/关闭许可统一拒绝，重复申请有冷却及共享限额；旧幂等返回不能绕过新授权；`activated_at`使**从未成立**关系暂停/恢复后不能脱离原来源，但**曾经真正ACTIVE**关系的独立恢复事实保留。
- **B2 / P1 已关闭**：退出匹配撤回旧未决并清双slot；暂停不显示Showcase或继续接受，用户仍可明确withdraw；重新报名新代际前拒绝未解决旧提案；当前Match、旧v1投影与新CN资格一并采用服务端当前状态，完成过的合法CN/MC不会因为退出报名被暗中撤销。
- 修复前8项R1测试中7项失败；最终44 tests、609 assertions、exit0，Flutter13项exit0；初次失败/误脚本/重启异常保留。Astra没有亲自运行Windows上的测试。
- 受控MariaDB10.11 `REPEATABLE-READ` 定向竞争：B1真实HTTP reader180 / writer179等用户PRIMARY锁，收件撤权COMMIT后404、零新增业务副作用；B2 reader185 / writer184等用户PRIMARY锁，EXIT COMMIT后200但Showcase=null、decision=false、WITHDRAWN、双slot0。保存了精确`INNODB_LOCK_WAITS`事务连接配对和COMMIT时序，不用500/死锁充PASS。执行仍为CODEX_REPORTED；Astra独立读取远端脚本与脱敏结果。
- R1开发DB受控重启后9表有序哈希/行数一致，反向HTTP仍拒绝；最初持久性脚本异常但exit0已按FAILED，修正后才计PASS。实际APP、数据库及模拟器本地证据属于CODEX_REPORTED/LOCAL_ONLY。
- 新APK `com.elitesync.v1012dev` / `10.1.2-dev` / `1010201`，两ABI，411524159 bytes；Codex报告AVD安装/回取SHA256 `d1f5f0850f68016c361c07f54ab7fccf8975def6409e84bc532d131dc057a410` 一致，与本接受源码绑定；本次顾问没有直接读取APK字节或操作AVD。

## 3. 保留观察／不被接受的外部事项

1. 真实身份核验供应商、真实账号正式恋爱ACTIVE、证件处理、费用与公网运营仍`PROVIDER_PENDING / NOT_RUN`；仅隔离合成TEST_ONLY。
2. R1 APP暂停未撤回就重新报名的错误提示仍较泛；旧缓存动作可能暂显示至刷新但服务端重新拒绝；R1收件人角色未再次单独登录APP，相关HTTP与Widget范围回归可用。
3. 本轮44/609、Flutter13是有界R1回归；前版71/713及Flutter39、算法/RTC其它原有效证据保留。2项Deprecations与2项PHPUnit Deprecations未消失。RTC媒体、真机、AEC、云端、物理删除、全Showcase人工审核、真实演示效果均未因此新获证明。
4. v10.1.0整版仍`PARTIAL / NOT_ACCEPTED`、AC-10.1-08仍PARTIAL；v10.1.1安全集成历史观察及开发库误清/恢复原证保留。
5. GitHub短期审阅包和原候选分支不自动删除，原LOCAL_ONLY SQL、APK、密钥、设备日志及备份不可无授权上传或清理。

## 4. 后续门禁

**最终裁决：`V10.1.2_ACCEPTED_WITH_OBSERVATIONS`。** 仅意味着冻结版本受控开发功能候选接受。Owner在2026-10-21另行明确批准**单次安全集成**；Codex仍须收到Owner手动派发后才能按本版安全集成任务实施。须从实际live main精确集成apps/services两子树、保留所有现行docs及治理，集中报告及必要静态验证、本地代码基线接续；独立完成集成验收前不得写`INTEGRATION_ACCEPTED`，不得自动启动v10.1.3。

依据：[原版与R1追加唯一实施报告](IMPLEMENTATION_REPORT.md)、[R1制品清单](r1_artifact_manifest.json)、[R1脱敏审阅](https://github.com/zcx369658780/EliteSync-v10/tree/94f41f4ef2455b7c89258437a5162c19cca2f1e8/docs/_temporary_review/v10.1.2-r1-20261021)。
