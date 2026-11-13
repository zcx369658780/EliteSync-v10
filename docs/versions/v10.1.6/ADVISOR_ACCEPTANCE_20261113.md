# v10.1.6 顾问验收与 R1 补修决定

日期：2026-11-13（北京时间）。被审候选：222923bdec970bc2b2fcec4c51320edcb4f74688。任务基线：4471bed660d6d9a1eac00f56ee54b9bb9d9e8a1a。

## 结论

**CHANGES_REQUIRED：本版成果保留，两项补修完成后再验收。**

本轮确认一个影响展示受众的后端缺陷，以及三个部署文件身份与固定候选字节不对应的问题。当前不能接受“六项 AC 全部完成”为顾问最终结论。Codex 原工程自验报告保留，顾问判断另列，不追改历史运行记录。

立即下达同版 [R1 补充任务书](supplement-r1-20261113/TASK_ORDER.md)与[接续 prompt](supplement-r1-20261113/CODEX_SUPPLEMENT_PROMPT.txt)。仍在 v10.1.6 分支完成两项修复后集中报告；不启动 v10.1.7。SFU 当前退出单独结转，不是本 R1 的新增任务。

## 复核方式与已经确认的成果

顾问读取了固定提交的当前规则、计划、实施报告、manifest、相关 APP/后端/Web/迁移和定向测试源码，核对远端分支、提交差异、8个源码子树及manifest列出的6个部署文件字节。没有在Owner本机操作设备、读取私有回执或APK，也没有重新执行PHP/Flutter测试及真实链。

62项PHP测试/902断言、57项Flutter测试、双模拟器操作、APK安装字节和容器运行结果属于Codex具名工程报告。本机原证按任务保留LOCAL_ONLY本身不构成补材料或重新测试理由。

已经核实：

- 远端任务分支在复核开始时指向222923bd；源码候选fe9360b7是其直接父提交。
- manifest的8个源码子树均与Git实际树一致；backend app/routes/config/database/resources与df7de198一致。
- 8973568a到fe9360b7只有照片说明文字及README变化；fe9360b7到222923bd只有报告、manifest、ACTIVE_STATE及README。旧候选已具名的照片排序移除、需修改重提、断网、撤回拉黑和切号结果可以按相同逻辑范围继承，不要求重复全部操作。
- APP普通资料入口接实际API；草稿、提交、审核、本人确认发布、私有图片读取、revision及会话迟到结果防护有实际实现。
- 新审核绑定内容版本，待审/已发布快照分离；本人确认发布与管理员批准分别执行。
- 四项新增相识后能力保留最小契约，当前unavailable，未扩大为新增完整业务。

原功能结果见[固定实施报告](https://github.com/zcx369658780/EliteSync-v10/blob/222923bdec970bc2b2fcec4c51320edcb4f74688/docs/versions/v10.1.6/IMPLEMENTATION_REPORT.md)，身份声明见[固定manifest](https://github.com/zcx369658780/EliteSync-v10/blob/222923bdec970bc2b2fcec4c51320edcb4f74688/docs/versions/v10.1.6/artifact_manifest.json)。

## 六项 AC 的顾问判断

| AC | 本轮判断 | 范围 |
|---|---|---|
| AC16-01 | 功能与持久化成果保留，部署身份待R1-02对齐 | MariaDB与重启结果按Codex报告；不能把三处未解释字节差异记为完全对应固定源码 |
| AC16-02 | 本人编辑与照片功能限定认可 | APP源码与具名运行报告支持；保留继承证据范围 |
| AC16-03 | 真实审核与本人发布成果保留，运行身份待对齐 | Web/APP实现成立；三个控制器身份由R1-02确认 |
| AC16-04 | 好友作者入口范围限定认可 | 不扩大为所有发布内容在所有已有消费端均符合受众 |
| AC16-05 | **未通过，R1-01必须修复** | 旧慢约投影绕过本版新增受众选择 |
| AC16-06 | **待补修后完成** | R1-01修复与R1-02身份闭合后再判；SFU运行限制继续单列 |

## R1-01 展示受众未覆盖已有慢约投影

优先级：必须修复的功能/权限缺陷。以下为固定源码可确定的触发路径，未声称在Owner本机复演。

触发条件：A已有审核并发布的Showcase，受众仅为friends；B与A存在未到期、上下文仍有效的匹配提案，但B不是A的好友。仅relationship受众且B不是对应正式关系对象时同样存在问题。

本版 [ShowcaseWorkflow::publish](https://github.com/zcx369658780/EliteSync-v10/blob/222923bdec970bc2b2fcec4c51320edcb4f74688/services/backend-laravel/app/Services/ProfileShowcase/ShowcaseWorkflow.php#L184-L206)把获批快照及所选audiences保存，并设置public_display_eligible=true。新的详情/照片读取会核对所选范围；但既有 [SlowDatingService::projectLocked](https://github.com/zcx369658780/EliteSync-v10/blob/222923bdec970bc2b2fcec4c51320edcb4f74688/services/backend-laravel/app/Services/SlowDatingService.php#L137-L155)只用public_display_eligible取得发布记录，随后直接投影self_intro、interest_tags和lifestyle_tags，不检查audiences。

可达路径：

- GET /api/v1/journey → SlowDatingController::show → journey → proposal → projectLocked。
- POST /api/v1/journey/proposals/{id}/decision → decision → projectLocked。
- JourneyStore的提案命令重放也会重新调用projectLocked，属于同一处修复范围。

因此，拥有有效匹配并不等于获得了本人限定为好友或正式关系的展示授权。用户界面明确承诺“仅供当前符合所选范围的对象读取”，该旁路违反本版F16-02/F16-04及AC16-05。

目前确认影响的是自我介绍、兴趣标签和生活方式标签；没有据此判定照片已经绕过鉴权。修复应复用一致的当前发布/受众判定，无权时隐藏Showcase部分，保留合法提案状态和决策能力。不能靠扩大受众默认值或关闭整个匹配功能解决。

## R1-02 三个控制器的部署身份未对齐

manifest字段runtime.deployed_source_bytes声明工作树与容器文件SHA256。以下三项与固定Git提交的精确文件字节不对应：

- 文件：services/backend-laravel/app/Http/Controllers/Api/V1/ProfileShowcaseDraftController.php
  - manifest所记：868da4744bde6e301ef25ce1c98c7d5f71c356871ae06671acc6eb52685c5dd9
  - 固定Git字节：e3ddf8654e2a8d06107be18367bca92617cb5b46e2423621035768c9f6a9d02f

- 文件：services/backend-laravel/app/Http/Controllers/Api/V1/ProfileShowcasePublicationController.php
  - manifest所记：a3a38511d7bbe5a95e4ab8b4a1ef0cd7bf713b7d86bb93f1ccad7cc51753567c
  - 固定Git字节：b1c5e8402623bb5e1c903eace94ca5546520823ce95bc38e1cde4613ab5890aa

- 文件：services/backend-laravel/app/Http/Controllers/Web/AdminShowcaseController.php
  - manifest所记：277fc02b4c63ab82517b2962bb6ece369467d250d32ef728c25cbbb54df422fc
  - 固定Git字节：d07a286a83f4370313dbde5f994fd688ec575aff0354ff340097bc8deb36253b

顾问已确认本次读取文件的Git Blob SHA与222923bd的Git树吻合。LF/CRLF、UTF-8 BOM及常见末尾换行变体均未解释以上三个数值；不能直接称为换行差异。其余三项ShowcaseWorkflow、迁移、filesystems的声明SHA256与Git字节吻合。

这证明的是声明的部署字节尚不能对应固定候选，不证明Owner容器一定运行旧逻辑。由本地Codex读取这三个文件的Git Blob、工作树和实际部署对象，说明差异并绑定最终实际源码。若只是已证实的格式差异或记录错误，按实际最小范围纠正；若涉及逻辑差异，才补该差异影响的验证。不做全资产哈希工程。

## SFU与其他结转事项

最近工程回执为2026-11-13 15:57:02北京时间：DB/API/WS运行；SFU在恢复时发生约601—602ms的authority_sweep TimeoutError，沿既有最多3次重试退出，房间查询UNAVAILABLE；双APP停止且数据保留。

RTC源码子树与2687a39c一致，只能证明无直接RTC源码变动，不能证明共享API/DB环境完全无影响，也不能认定本次事件与旧故障同根因。本事件继续OPEN/UNKNOWN，按路线图并入v10.1.8相关通信工作。R1不追加SFU根因定位、25分钟观察或旧通话矩阵。

Owner对v10.1.5阶段收尾、整个v10功能优先、相识后新增工具仅接口、v10.1.12集中UI的决定保持有效。顾问最终接受和Owner最终接受仍待后续；本次没有合main、发布或在本机自动启动任务。
