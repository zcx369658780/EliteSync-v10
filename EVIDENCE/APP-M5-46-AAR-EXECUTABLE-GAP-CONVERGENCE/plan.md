# APP-M5-46｜AAR 可执行缺口收敛

DOCS-ONLY CANDIDATE — WORK LEVEL 2 / INDEPENDENT SOL-HIGH REVIEW PENDING。
2026-10-01；D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。
仅本 plan.md CreateNew；不是实现、SDK读取或运行授权。M5/隔离构建仍 NOT_READY。

## 已接受范围及未越过的门

M5-45 work-review.md L3：ACCEPT/CLOSED EXACT SYNTHETIC INMEMORY TEST SLICE，准确13方法已通过；M5-44 Static/145具名检查的接受与全部旧预算关闭以当前 authority 为准。测试证据覆盖冻结纯内存材料，不建立真实 Gradle/SDK 兼容。M5-43 的程序 display 限额和 PTY 全传输 NOT_PROVEN、M5-44 Work 原工具检索后段容量限制保持，不追认完整传输或后段检索已证。

本轮 A 对13个准确文件各只读一次，全文在命令内存中读取/hash/strict UTF8；仅回显按文件预算选择的小摘录，未复制大附录或全文源码。本 plan 的逐项结论限定于同次可见摘录。摘录缺少准确 locator/完整上下文时标 UNKNOWN / NOT_FIXED；这不证明完整证据文件没有该内容，更不证明对应 SDK 文件不存在。不得据此搜索、猜路径或补读本轮 A。

## 材料、消费者及上下文缺口

| 对象 | 已保存事实、消费者 | 真实落地仍缺什么 |
|---|---|---|
| 四片段 tasks-full / repo-block / init-full / plugin-deps | M5-38 plan.md L53：完整适配字节，plugin-deps逐byte不变；附件不插入scratch。aar_applied_materials.py L3明确无文件/路径安装或SDK求值。 | 局部片段应用不等于完整工程生成、Gradle配置或任务执行；真实完整文件上下文、输出工程路径与输入身份闭包尚未由本次材料证明。 |
| apply-helper | M5-29 plan.md L55–60、L218：id=apply-helper，placement=FLUTTER_PLUGIN_CLASS_MEMBER，before为空bytes，after完整block，executable_patch=False。aar_entry_materials.py L19可见符号 private fun esControlledModule(p: Project): Boolean；L11的tasks-after片段消费者为 esControlledModule(projectToAddTasksTo)。L210把它放入Attachment而非执行源码。 | 完整class名/源码准确绝对路径/成员唯一插入锚、Project类型import/API解析、消费者是否处于同一类/版本/作用域均UNKNOWN。before为空不能建立唯一SDK替换锚；不得从placement名称推定真实class或插入位置。 |
| apply-preflight-proposal | M5-29 plan.md L218：placement=APPLY_AFTER_THIS_PROJECT_ASSIGNMENT，完整before/after block，历史apply:47锚；M5-38 plan.md L188–190及aar_entry_materials.py L211继续携带这一非执行提案。所指消费者仅为拟议thisProject赋值后落地点，真实consumer尚未核定。 | 实际method/class、thisProject声明/赋值的唯一上下文、完整preflight block中方法符号、相关imports/API和配置副作用均UNKNOWN（本轮可见小摘录不足核定）。历史行号不固定当前SDK语法锚或调用阶段；不推断名为apply的方法完整签名。 |
| Invocation及四project属性模型 | M5-38 plan.md L53：runtime_ready=False；logical output-dir仍publication，原typed recipe保留。aar_applied_materials.py L126–146：保留package.invocation，要求property_installation长度4，在局部properties列表中区分普通recipe与RootProjectDirFilePath并拼接模型字符串。 | 这些是人工安装模型，不曾对实际Gradle Project写extraProperties、安装recipe或解析真实路径。真实rootProject/子project集合、属性隔离与作用域/时机、插件读属性及冲突传播均未运行证明。 |
| 完整module/plugin输入闭包 | M5-10 plan.md L13：module .android settings读local.properties并include Flutter SDK Gradle build，evaluate include_flutter.groovy；共享runner包/profile/release及模块build/host不能由最终输出目录隔离。M5-13 plan.md L3记录同次CLI生成tooling后进入Gradle，生成后运行前的可暂停审查边界未证明。 | 已接受人工projects/tasks字段不等于完整真实module/plugin/模板/工具classpath输入清单或配置副作用闭包。本轮未读取真实metadata/properties；实际输入集合/路径/当前身份/自动注入未新增证明。 |

准确引用的共同根：EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md；EVIDENCE/APP-M5-38-INMEMORY-AAR-APPLICATION-CONTRACT/plan.md；EVIDENCE/APP-M5-10-ISOLATED-SYNTHETIC-BUILD-CONTRACT/plan.md；EVIDENCE/APP-M5-13-FLUTTER-AAR-GRADLE-INVOCATION-CONTRACT/plan.md；两源均位于apps/android_synthetic_demo/tools/。上表行号是A同次文件摘录行号，不是SDK当前行号。

## 隔离构建门的收敛

1. 配置与生成边界：完整SDK/class/方法上下文尚未核定；CLI生成后与Gradle开始之间的受控分段不已证（M5-13 plan L3）。两附件不能直接安装，因此本轮不以继续添加常量record或固定false preflight弥补这一缺口。
2. 工具与缓存：实际Flutter/Python/JDK/Gradle/AGP身份、受控HOME/cache、环境注入与共享输入隔离的当前完整闭包UNKNOWN；M5-10 plan L42仅明确该独立隔离主题，本轮没有读取工具/缓存。最终输出目录不能替代配置隔离。
3. 依赖与任务图：真实settings/include/plugin注册、repository副作用及依赖解析、debug唯一任务/发布接线在人工材料之外未新增执行证明；M5-13 L9的旧gradle.dart缺行和L11截断记录不能用邻接代码填补。历史证据复用不重置旧预算。
4. 产物与设备：没有新的构建、APK/AAR坐标/字节/标记/端点/签名或安装启动证据；13内存tests不建立真实产物或设备状态。settings/v1全拒绝、loader/runtime false保持。

## 唯一最小后继建议（DRAFT — NOT ISSUED）

优先选择：核定两Attachment共同依赖的真实Flutter插件class/import/apply上下文；先补来源和唯一上下文，再评估可执行适配，不提出另一个永远false的校验器。

单一交付：一份source-context.md，记录准确来源身份、完整相关class/import/方法及两消费者/插入锚映射；每项给PROVEN或UNKNOWN，不实现patch、不生成工程。后继目录/写路径由Work在正式任务单固定；本建议不创建目录或占用task ID。

source locator：NOT_FIXED（本轮可见摘录未建立准确SDK绝对文件路径与当前身份）。已固定的仓库定位证据为M5-29 plan L218和M5-13 plan L9–20；其历史锚/文件名不足作为SDK读取allowlist。Work须从已有保存来源恢复并核定准确locator、大小/hash/读取片段后才可发布；不得自动搜索SDK或猜flutter.groovy/FlutterPlugin.kt路径。定位未固定时停止受影响来源任务，不能把泛化文件名当精确路径，也不能用旧hash当当前工具身份。

拟议允许路径：仅Work固定的一个source-context.md写路径；读取authority、已保存M5-29/M5-13定位证据，以及Work预先精确固定的一个相关SDK源路径与必要直接上下文片段。未固定项均不形成权限，禁止目录枚举/全局搜索/沿import自动扩展。

有限预算建议：locator固定后一次来源读取0/1（exact path、普通non-reparse、size/hash、strictUTF8、预定片段、回显<=16KiB）；一次交付文字/引用检查0/1；所有运行0。locator未固定不得启动来源轮。首次缺失、身份冲突、输出/编排或上下文不够即停，不修正重试、不继续读邻文件。未知保留UNKNOWN，候选交独立Sol/high只读与Work LEVEL2；不得自接受、发GO、执行SDK/Gradle或派后继。本草案没有ISSUED状态。

## A来源身份及预算回执

A新1/1完成并关闭；tool chunk_id=84efc7，exit_code=0，wall_time_seconds=0.2595574。13准确文件各一次ReadAllBytes，普通non-reparse（含祖先）、strictUTF8通过，两源与任务冻结大小/hash一致；来源回显提前UTF8<=16KiB。仅小摘录，未运行任何代码。完整来源身份表如下：

```text
A EVIDENCE/APP-M5-10-ISOLATED-SYNTHETIC-BUILD-CONTRACT/plan.md bytes=17741 SHA256=D0FD42495BCFF4D470741F4DFAD042EA6EDDBF9C2E1B0D1D3C60A5E3106721A5 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-10-ISOLATED-SYNTHETIC-BUILD-CONTRACT/work-review.md bytes=1234 SHA256=B6A80667CBDF63145EB34D1B9B102D5DBCDD70980E02148DA031AAEF06D334B0 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-13-FLUTTER-AAR-GRADLE-INVOCATION-CONTRACT/plan.md bytes=14282 SHA256=81CDEF819A3FD1E893858FEB3B0A4C61FB41179B744FE4C0F30BE7AD4016ACA7 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-13-FLUTTER-AAR-GRADLE-INVOCATION-CONTRACT/work-review.md bytes=1821 SHA256=955EBFCD8FDCD5A76858F8FE65354A987A75EDEE21ECFD68B26A32D956F53A88 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md bytes=40085 SHA256=B7477C177E1CB1860959BD4136E6B1A1B33A5D9F2B75E75BDB4F6FC442A95382 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-38-INMEMORY-AAR-APPLICATION-CONTRACT/plan.md bytes=137079 SHA256=7DB003A4620EEE403A310192DAE2C7BEEAAE5F88AE8D7A5B8CE6D962F8FC34BD ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-38-INMEMORY-AAR-APPLICATION-CONTRACT/work-review.md bytes=1497 SHA256=D154CAD6B53E8CEEBEA3B5B3831FFDB96BB03912F9D65A2568C7DE3A71CD868F ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-39-PURE-AAR-APPLICATION-SOURCE/work-review.md bytes=2014 SHA256=2B850801B7A8BBDCE02246BACC432BAE8096A2613EF64FD7B5A15DD56F260F9E ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-43-STABLE-APPLIED-HARNESS-REPAIR/work-review.md bytes=1934 SHA256=360D0A8374EC670BB6E1D9A4965B838954B2B26BFBF7C19A9F60FCBE4D36D260 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-44-FROZEN-APPLIED-STATIC-VALIDATION/work-review.md bytes=1865 SHA256=9EA47732089AD287A6B2A46CA281CE12A1B56BF35E1DC7DEBF4E047DBA866B46 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-45-FROZEN-APPLIED-MATERIALS-TEST/work-review.md bytes=2201 SHA256=4E140434138869D4FB0D5F2FCE086BEBA7173BCC4E695897BBC32796472E94A4 ordinary_non_reparse/strict_UTF8=PASS
A apps/android_synthetic_demo/tools/aar_entry_materials.py bytes=20338 SHA256=B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7 ordinary_non_reparse/strict_UTF8=PASS
A apps/android_synthetic_demo/tools/aar_applied_materials.py bytes=6510 SHA256=123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224 ordinary_non_reparse/strict_UTF8=PASS
```

B新0/1在本CreateNew保存时尚未执行；随后仅对本plan的文字/引用/size/hash/预算/工作区成员核定一次，最终B工具id与原结果在最终回复提供，不为补回执再改已核plan。任一B问题首停不改/重跑。A无失败；本轮终点是DOCS-ONLY候选交独立Sol/high与WorkLEVEL2，外部来源locator仍NOT_FIXED。

所有Python/AST/import/compile/算法/tests/checker/launcher/monitor/SDK环境读取/Gradle/Flutter/JVM/ADB/依赖解析/构建/staging拷贝/安装启动0；不改源/依赖/authority/旧证据。无Git mutation、真实数据/备份/密钥/生产DB/API/SSH、旧D:\EliteSync、SDK/cache/config/env/home/真实metadata/properties或UAC。保留dirty/untracked/旧候选/全部关闭预算。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及真实性/恢复/生产/UAC门不变。
