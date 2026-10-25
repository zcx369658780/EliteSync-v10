# v10.1.5 D0-C Gate 2 定点测试启动阻断交付

**D0_C_GATE2_TARGETED_BLOCKED / BUDGET_CONSUMPTION_REPORTED / FULL_37_CASE_SUITE_NOT_RUN / AWAITING_OWNER_DIRECTION**。

仅一次启动：Windows PowerShell入口被实际脚本执行策略拒绝加载，原始stderr为 `SecurityError / UnauthorizedAccess`，指向 `about_Execution_Policies`。这不是平台UI提示，也没有Writer缺陷的运行证据。入口未加载，正例、负例、Write-Aggregate、Serializer和fallback均NOT_RUN；不得记为正/负例FAIL或PASS。

## 权威、固定源码及入口

唯一任务Blob `420f372b74893bcb11abba2bcb957aa5a43eee28`；原综合任务 `009a12cae75ef3b714f0156d4edbca2db1660719`；Gate1 Astra接受 `d377b19756eebeaf4f01c3f69d6fd2326ed89780`；D0-C静态接受 `f8ce12a81bf303cf5fba37bb708927a3e2791b4b`。开工live main `2e6a9fb63769fabab69e5eb8f6d76e3012e3dedc`、Root `6bcfba5ec41e3e075060dfd1ece4b2aedf984613`，ACTIVE_STATE Blob `018ed198b8b5f573dbdfa664e393ae4eadffe28c`。

开工连续候选分支 `codex/v10.1.5-source-faithful-serializer-conditional-sdk` 远端与本地HEAD均 `7b8b9959c9e53994ec5c52736d1fb3ca00ba4239`、Root `8b51a383eebfc60e221b6b2936d17f398bb61e16`，工作树干净。本交付只新增本报告及Manifest，后继唯一Parent为该候选。最终Commit/Root/两Blob/原字节由提交后独立回执固定，避免自引用。候选apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`（1133条）、services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`（791条）保持；main仍是v10.1.4接受产品。

待测Writer由已接受D0-C原字节复制，Blob `a521201e2274927ebf0743c4d79811bb7ecf27ba`，SHA-256 `9b494ac7e45b4a27dfaaef73b48bb6c9b60d25dc6521c32a968b80f5e3297512`。fixture/schema/37案例plan及driver/controller/定点计划/发布片段的8项Hash在启动前后匹配，详见Manifest；接受源码未修改。

实际入口为固定Windows PowerShell可执行文件，参数 `-NoProfile -NonInteractive -File gate2_once.ps1 -RunId <synthetic UUID>`；完整绝对路径命令与自有PID只在LOCAL_ONLY启动/进程回执。没有ExecutionPolicy覆盖。准备的定点入口直接加载接受Writer，正例沿用固定fixture第96–99行实际调用/发布尾部并增加schema校验，负例原拟向cases注入循环触发真实Serializer及fallback；主fixture从未运行。单合成输入计划expected=actual=1，摘要是明确标记的合成输入，不是原37案例对象或历史案例运行PASS。

## 一次实际启动与预算

| 项目 | 实际结果 |
| --- | --- |
| 合成Run ID | `985d9dd3-ef81-4d76-88fb-789090768e92` |
| 启动时刻（Asia/Shanghai） | `2026-10-25T10:09:49.898897+08:00` |
| 授权启动次数 | **1/1，已消费** |
| 共享硬时限 | 15秒 |
| 监督总耗时（含退出确认、必要结果读回） | 0.375秒 |
| 外层命令工具墙钟（含控制器启动） | 0.7072825秒 |
| PowerShell子进程／监督命令退出码 | 1／1 |
| 子进程退出确认 | 已确认，非超时，无终止请求 |
| 原始stdout | 0字节，SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| 原始stderr | 413字节，SHA-256 `4e1bff4603e22f4e99ac7459faceb5fbe7367f5249e77e4fabeec044fce25bdd` |
| 控制器最终overallPass | false |
| 正例／负例实际Writer调用 | 0／0，均NOT_RUN |

未生成 `gate2-child-result.json`、positive/negative测试目录或任何receipt。故receipt字节/Hash、UTF-8/schema、Run ID绑定、计数/逐项状态、fallback、原异常重抛及原子发布的运行验收全部NOT_RUN。原始stderr明确表示此系统禁止运行脚本；未查询有效策略具体值，不推断其MachinePolicy/UserPolicy等来源。

一次性预算从实际启动阶段计入，短于15秒不授予剩余时间重试。未修改执行策略、未改用其他入口、未申请额外权限、未修复或重跑测试。D0-A既有15次Serialize/约0.688秒证据保持，未重跑、未重置预算。

## 准备、非作者证据复核与保护

启动前，新控制器初稿曾被非作者静态审查发现spawn后异常缺少完整进程收口；原稿和阻断复核已保存，控制器修订后重新绑定Hash并获静态支持。当时没有试跑或消费运行预算，接受Writer未动。随后只有上述一次实际启动。该准备记录不冒充运行失败或测试重跑。

非作者实际读取本地原始退出/监督回执、stderr、产物缺失及8项Hash，支持本次启动环境阻断与NOT_RUN分类；没有独立重跑或接受产品。原始413字节stderr为权威；派生UTF-8解码副本只为阅读，存在换行归一化差异，不替代原字节Hash。

发布前22428/22428份具名保护文件Hash、五历史根HEAD/branch/index/dirty及warning、516现有refs、原38份JSON及候选完整产品maps保持。此为具名范围保护，不是全盘、系统配置或活DB审计。正式候选ref的普通后继是具名授权变化，其它旧refs不得改写。

## LOCAL_ONLY与发布边界

完整命令、PID、原始stdout/stderr、计时、退出确认、准备源码/计划及Hash、非作者记录和工作树回执均LOCAL_ONLY。公开仅本脱敏报告和Manifest的必要事实、状态与Hash，不上传原始日志、完整目录、测试源码包或私密执行信息；没有新审阅分支。提交后回读Commit/sole Parent/Root、两文档Blob及原始UTF-8字节，并核对完整产品Tree。

保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。完整37案例suite、Sandbox、Flutter/Gradle/Producer、libs.jar和30项Configuration.resolve均NOT_RUN。交付后停止等待Owner/Astra裁决，不恢复预算、不修改策略或自动启动下一Gate。
