# v10.1.6 R1 顾问验收通过

日期：2026-11-13（北京时间）。被审交付：5e20fe1393fb0ee43b59617e938beb80f110a032。R1源码：69b95628a35ceae6fb7a3f726b5034ddb0d1750a。

## 结论

**R1-01与R1-02均通过并关闭。v10.1.6六项AC在本次约定的本机开发、虚构数据与具名候选范围内接受。**

本轮不再下达R2。v10.1.6的真实后端接续、本人资料与照片、Web审核、本人发布/撤回及获准对象读取可以按版本目标收尾。SFU当前退出及既有外部条件继续分别结转，不扩大为整APP当前全部能力可用、真实Push已接入或正式发布。

原222923bd的[CHANGES_REQUIRED记录](../ADVISOR_ACCEPTANCE_20261113.md)保留原候选身份，本次以修复后5e20fe13作出新判断。Owner最终接受仍独立保留；Codex当前保持交付后停止状态，后续v10.1.7按既定路线再具体下达，本次不自动开启。

## 复核方法与证据边界

顾问完成远端分支与固定内容回读、两次提交的父级/差异核对、3个受影响服务与相关测试/旧APP消费者的定向源码复核、8个源码子树和8份相关文件的Git Blob/字节数/SHA256核对，以及3份控制器历史末行CR差异的独立复算。

顾问没有在Owner本机执行49项测试、容器权限夹具、普通Bearer HTTP或设备操作，也未独立读取本机工作树、容器和APK。运行、当前容器文件与事务回滚结果依[Codex R1报告](https://github.com/zcx369658780/EliteSync-v10/blob/5e20fe1393fb0ee43b59617e938beb80f110a032/docs/versions/v10.1.6/supplement-r1-20261113/README.md)和[具名清单](https://github.com/zcx369658780/EliteSync-v10/blob/5e20fe1393fb0ee43b59617e938beb80f110a032/docs/versions/v10.1.6/artifact_manifest.json)接受；远端Git字节与确定性CR变换由顾问独立验证。未把报告自验标成顾问实机复演。

## R1-01 受众旁路关闭

[ShowcaseWorkflow](https://github.com/zcx369658780/EliteSync-v10/blob/5e20fe1393fb0ee43b59617e938beb80f110a032/services/backend-laravel/app/Services/ProfileShowcase/ShowcaseWorkflow.php#L233-L278)集中判定当前账号、拉黑、合法关系上下文、发布状态、明确选定受众及public_display_eligible。对方详情、图片和慢约摘要经过同一判定。

[SlowDatingService](https://github.com/zcx369658780/EliteSync-v10/blob/5e20fe1393fb0ee43b59617e938beb80f110a032/services/backend-laravel/app/Services/SlowDatingService.php#L137-L158)只在取得当前获准发布版后返回介绍及标签，无权时showcase=null。journey、decision和有效幂等重放均重新投影当前权限；命令存储仍不保留Showcase内容，不会从旧响应恢复已失效展示。新私有草稿不会进入投影；缺少显式受众、撤回或当前关系不符时保持隐藏。

新candidate_available独立于展示资料可见性。[轮次投影](https://github.com/zcx369658780/EliteSync-v10/blob/5e20fe1393fb0ee43b59617e938beb80f110a032/services/backend-laravel/app/Services/MatchRoundProjectionService.php#L30-L79)依当前候选状态提供revealed和合法结果，避免隐藏展示后误关闭匹配。旧APP对showcase=null转为空Map；提案区、接受/拒绝/撤回及双方接受后的连接入口按各自状态判断。APP源码未变，本轮无需重建APK。

已读实际调用入口先持有有序用户锁，再读取当前发布及关系；未发现新锁顺序冲突、递归或剩余具体旁路。新增[权限回归](https://github.com/zcx369658780/EliteSync-v10/blob/5e20fe1393fb0ee43b59617e938beb80f110a032/services/backend-laravel/tests/Feature/ShowcaseJourneyAudienceTest.php)实际命中GET journey、POST decision及有效重放，覆盖：
- friends/relationship受众与有效匹配不符的反例。
- 正常好友、contacts与当前正式关系分享正例。
- 隐藏展示时接受、互相接受和拒绝仍可执行，轮次保持合法。
- 收紧受众、撤回、好友失效、正式关系暂停后的当前读取/重放。
- 私有草稿隔离、账号受限、拉黑和参与代次变化。

两个既有测试的变更补齐有效前置，未删除核心失败断言。判定：**R1-01 CLOSED**。

## R1-02 三控制器身份关闭

顾问用固定Git文件字节独立复算以下确定性变换：

```text
historical_bytes = git_blob[:-1] + b'\r\n'
```

即前面所有行保持LF，仅将最后一个LF改为CRLF。三个历史manifest SHA256全部精确复现；这与整文件LF/CRLF变换不同，解释了上一轮未能对上的数值。

| 文件 | 原声明字节数 | 当前Git字节数 | 旧SHA256精确重现 | 当前Git SHA256与新声明 |
|---|---:|---:|---|---|
| ProfileShowcaseDraftController.php | 3019 | 3018 | 是 | 一致 |
| ProfileShowcasePublicationController.php | 2248 | 2247 | 是 | 一致 |
| AdminShowcaseController.php | 3774 | 3773 | 是 | 一致 |

三文件Git内容与原候选相同，没有控制器逻辑差异。Codex已报告工作树和容器均写回精确Git字节；新清单分别记录Git Blob、工作树、容器及历史变换。顾问核对8份相关文件的Git对象、字节数和SHA256均与清单吻合，工作树/容器声明值与这些Git值相同。

上一轮“部署字节声明尚未对应候选”的问题现已明确解释并完成对齐，不再保留为未知部署逻辑风险。判定：**R1-02 CLOSED**。

## 验证与继承范围

| 材料 | 采用范围 |
|---|---|
| 49项、790断言 | Codex报告的PHP8.4.27/SQLite定向权限与轮次回归，测试设计已由顾问阅读 |
| 8次容器权限夹具 | 现行API容器、Laravel HTTP kernel和MariaDB上的具名权限回归；使用夹具认证及事务回滚，不记为普通用户完整主链 |
| 9次普通Bearer真实HTTP只读 | 当前已存在账号的本人草稿/发布、好友及无关系对象详情/图片、journey读回；不记为重新执行APP编辑/Web审核写链 |
| 原APP/Web成功链 | 按原具名候选继承照片、需修改重提、本人发布、撤回拉黑、切号与重启持久化结果；R1无关操作不重复 |

夹具业务行回滚与自增序号可能前移分开记录，未宣称数据库字节完全未变。本轮构建、安装与设备操作NOT_RUN，原62项PHP/57项Flutter结果保留原时点。

APP继续fe9360b7源码、10.1.6-dev / 1010601 / com.elitesync.v1015dev / arm64-v8a；APK 123715466字节、SHA256 444da1b6361734bcfd589ef2983add1fa823abb5709b6e7bfee238ca3db6bbf8。R1后端源码69b95628，5e20fe13仅增加结果、manifest及当前入口，身份继承成立。

## 六项AC最终顾问状态

| AC | 顾问状态 | 接受范围 |
|---|---|---|
| AC16-01 | 接受 | 实际API、持久数据库与具名重启结果；原三文件身份疑点已关闭 |
| AC16-02 | 接受 | 本人资料/照片编辑、顺序与移除、失败输入保留及重登读取 |
| AC16-03 | 接受 | 内容版本审核、反馈重提与本人明确发布的真实业务实现及具名结果 |
| AC16-04 | 接受 | 好友作者普通入口及获准对象当前发布版/私有图片读取 |
| AC16-05 | 接受 | 原已验权限与恢复，加本轮受众一致性、提案和重放修复 |
| AC16-06 | 带运行观察项接受 | 候选与交付可接续；SFU当前不可用及外部限制单列 |

这些接受以当前功能任务范围为界，不升级为所有设备、全历史功能或生产环境均已验证。

## 远端回读与剩余事项

Codex在推送及HEAD核对后遇到两次内容fetch连接关闭。顾问本轮已成功读取5e20fe13固定报告、manifest和受影响源码，并核对Git身份，远端内容回读已由顾问完成；不据此宣称Owner本机网络故障已修复，也不为那两次失败追加补修。

最新服务回执为2026-11-13 17:05:32.754北京时间：DB/API/WS运行，SFU exited、房间UNAVAILABLE、原因OPEN/UNKNOWN。设备仍引用15:57的停止/数据保留记录，本R1无设备及手机动作。SFU继续结转v10.1.8相关通信工作；真实Push、实人供应商、硬件和独立算法精度保留原限制。

当前完成顾问验收记录与状态同步后停止。本次不新增功能任务，不合main、不发布、不启动公司或内测。后续仍按既定路线先完善后端功能，v10.1.12集中UI/文字，相识后新增工具只保留接口。
