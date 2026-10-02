# APP-M5-28｜受控module AAR入口适配合同

ISSUED；LEVEL 2 DOCS-ONLY / PROPOSED SOURCE ADAPTATION CONTRACT。
Assignee：Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，派发前18次启动，沿用。
Work：01a0f173-9add-7070-b57a-7660f75f5c40，独立LEVEL2裁决。
M5-27已独立ACCEPT/CLOSED DOCS-ONLY，最终plan hash 7B83055FD677DB5A53F18079696EBA59F7D6C5E0E19337146C15FE00709D21C9；两轮2/2关闭。所有旧预算关闭。

唯一允许新增或修改：本目录plan.md。不改SDK、renderer、其它源码、authority或旧证据，不产生可启动工程。方案中的Kotlin/Groovy片段仅为待审源材料，不宣称编译/官方兼容或可运行。

## 实质目标

基于已保存准确来源给完整before/after适配片段、纯内存转换接口、逐project property与调用合同，使后继可实现SOURCE-ONLY材料转换。重点统一解决library host依赖、FlutterPlugin项目Maven注入和module/plugin debug发布接线；不是新增恒定record或只重复NOT_READY清单。不增加app、不伪造app extension、不删FAIL_ON_PROJECT_REPOS、不采用PREFER_SETTINGS、远端repo、local-engine或跳过版本/NDK检查。

## 两轮新预算，各0/1，失败即停

第一轮：一次批量读取以下七份已保存证据，各普通非reparse、≤256KiB，总≤1MiB；一次入内存。不得重读SDK真实文件或回收其它日志。原回执wrapper文本解析其唯一JSON的output，仅提取所列语义，不执行其所存命令。
1. EVIDENCE/APP-M5-27-AAR-CONFIGURATION-ENTRY-CLOSURE/round-1-original-receipt.txt，SHA256 9FD10B2C9B46D2578F7BFD32E266248A4C45CEC74140A39A1ED734E5DC1EA8E6。
2. 同目录round-2-original-receipt.txt，SHA256 8B4657648F3BE8CA1A36E4DFCCED2CFAEA0FAFE18C6BB2B4DCEBD5EFB6B1FE44。
3. 同目录m526-original-receipt.txt，SHA256 FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062。
4. 同目录plan.md，最终SHA256如上。
5. EVIDENCE/APP-M5-23-CONTROLLED-MODULE-RENDERER-CONTRACT/plan.md。
6. EVIDENCE/APP-M5-24-PURE-MODULE-BUNDLE-RENDERER/summary.md。
7. EVIDENCE/APP-M5-26-NDK-LIBRARY-AND-METADATA-CLOSURE/plan.md。
后三份记录本次hash，不设预期。authority、当前task、各work-review的入口读取不计专业轮。

回显源身份、完整最小选段及同次回执，UTF8主动累计≤32KiB；先m526唯一SECTION FlutterPlugin.kt METHOD addFlutterTasks 349-533，再round2 apply:88-101/init完整或必要完整方法，再必要Handler/已有renderer合同。重复回显源行须一致；解析/缺行/hash/链接/大小/输出门失败即停止专业检查，未证记UNKNOWN，不能修摘录器/补读/扩源。已存摘录不是完整SDK文件；不得把选段拼成完整官方源码或用整文件hash宣称片段字节相等。

第二轮：完成唯一plan后一次静态一致性核对（只读本plan一次入内存，≤256KiB，输出≤16KiB）。允许标准库文本/类型/固定合同检查及hash计算，不执行适配算法、Kotlin/Groovy/Gradle或测试。检查关键属性/完整片段/作用域、原分支保留、来源范围、正负例完整预期和剩余门；同次保存结果/hash。失败即停，不修复重跑；最终plan可以附本次回执与停点，不能把自检当独立接受。总2/2；SDK读取、目录搜索/索引、算法测试及运行预算均0。

## plan必须给出的可实现合同

1. 准确原片段与新片段、提取规则（source id/SECTION/源行/UTF8 LF/行号剥离规则/尾换行）、片段自身hash；整SDK FlutterPlugin identity 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313及init identity B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2仅是历史版本锚。apply摘录省独占注释/空行，明示其材料域；若真实完整补丁字节未持有，不提供可直接写SDK的整文件补丁。
2. 固定纯内存接口、exact输入域/返回immutable片段与结构化invocation contract、异常/幂等行为。缺锚/重复锚/不一致源行、wrong hash/版本、已适配输入必须拒绝；不能接受任意文本对象/任意路径/任意覆盖。适配片段生成不是实际SDK改写。
3. 自有显式受控模式（可用elitesync.aar-entry=module-debug-v1，须与is-plugin区别）。错误值/错误作用域/非library/非:flutter/flavor/release等在受控模式拒绝，不静默回落。未启用模式的原分支文本保持；检查首次可见阶段与非法状态在外部动作前的限制，无法证明则列UNKNOWN。
4. addFlutterTasks原app分支之后、原host查找之前的专用library入口：无host，按本module libraryVariants只接debug、shouldConfigureFlutterTask、已有addFlutterDeps的准确参数；保留configurePlugins与低SDK/NDK检查，不只return丢失任务，不复制app host assets接线。说明回调/插件配置时序，未知AGP行为不能写成已验证。targetPlatforms及provider等变量引用必须在可见作用域有定义。
5. apply:97-101同模式下不注册项目Maven，保留SDK/engine/版本等原检查。settings仓库门保持；依赖仓库由后续受审本地材料合同提供，发布目的地另列，不能把删除注入当依赖材料齐备证明。真实plugin与included-build额外repo仍未证。
6. init专用受控debug路径的完整方法/片段：debug component/publication、每个参与插件debug task、module.debug libraryVariant相互绑定；缺失时拒绝，不把单一任务名当全图隔离。遍历使用rootProject.subprojects真实范围，不能重引直接子项目限制；精确允许项目集合由输入合同限定并拒绝意外后代。未受控路径保持原行为。M5-23 module debug筛选已存在，残留其它variants只记未证，不能声称一定发生。
7. 逐root/:flutter/人工plugin显式property表：is-plugin准确字符串false（存在性与布尔值分别核），output-dir逻辑bundle/publication、buildNumber人工input_id、模式值、SDK identity；在相关apply/评估前可见，不依赖root ext继承。仅结构化单任务assembleAarDebug且无前缀、没有额外任务/executable/env/path覆盖。真实绝对SDK位置、CLI启动器/argv及文件材料不在本轮实现。
8. 独立人工正例的全部输入和完整输出片段/调用预期；负例至少覆盖hash/锚/重复适配、project/library/property作用域/false缺失或冲突、flavor/release/多任务/带前缀任务、插件debug组件缺失、路径逃逸/意外项目、增加app/远端repo/删gate。仅列预期不运行测试；不能只验证拒绝不验证产生新接线。
9. 与四正文、Api/implementation、NDK/.cxx/native_assets/mergeAssets、metadata/registrant及发布材料的关系与后继写路径提案。Kotlin/Gradle编译、helper最终配置、TaskAction/registrant、AGP时序、输入闭包/系统隔离/manifest/POM/真实材料保持UNKNOWN；实际SDK适配落地/配置执行需新任务与独立门。

## 禁止与停点

不SDK真实文件/配置/cache/env/home/real properties/metadata/json/engine/plugin材料读取，不目录搜索/日志再回收、下载复制、源码/SDK写、落地bundle、算法/测试/Gradle/Flutter/JVM/ADB/构建/安装/启动/UAC，不旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH，Git commit/pull/push。保留全部dirty/untracked。两新轮关闭后仅交候选停Work独立LEVEL2审查，不自接受/后继；Owner已恢复持续循环授权不转移Work验收权。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与真实账号/Conversation/恢复门保持。