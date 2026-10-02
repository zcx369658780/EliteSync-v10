**2026-09-30 新Work接管核对通过：RESUMED / ISSUED，明确派发给既有Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。两新轮派发前各0/1，仅恢复下方原任务范围/预算/停点；旧PAUSED_BEFORE_DISPATCH为历史。Work本轮完成交接和派发后停止，候选仍须独立LEVEL2审查。**

**2026-09-30 Work交接停点：PAUSED_BEFORE_DISPATCH。任务已保存但未向Codex发送；两新轮均0/1，未执行。新Work只读核对交接后恢复本任务并明确派发，不重置旧预算。以下ISSUED为暂停前任务正文。**

# APP-M5-27｜AAR配置入口与依赖接线合并核定

ISSUED；LEVEL 2 DOCS-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，当前15 turns。
M5-26独立ACCEPT/CLOSED DOCS-ONLY，1/1关闭；先核根authority/local-workflow及M5-25/26 plan/work-review，M5-23四正文与M5-14/16已保存AAR init来源。唯一新增本目录plan.md，不改源码/authority/旧证据。

目标：合并核定真正AAR配置入口/is-plugin、app分类、Flutter任务生成与插件依赖路径，把局部host检查映射到完整可达条件，给下一受控配置修订方案。不能因局部host check直接新增app，不能因repo注入直接删仓库gate。

## 两轮新一次性来源预算，各1/1

1. 一次准确两源读取：D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/plugins/PluginHandler.kt（预期3B22349766754AFD7CCEA99549782FA6A20CBBF291FB277A31E6B46758B67857）与同根src/main/kotlin/FlutterPluginUtils.kt（预期E0EB454157E67127B7677D697E924EB6B0556C8A4E51405045BC5E7F77798FD0）。存在/普通非reparse/各≤256KiB/hash门，失败即停。Handler短全文回显，避免复用上轮失败的fun摘录器；Utils仅isFlutterAppProject、shouldConfigureFlutterTask、buildModeFor及直接相关property逻辑完整最小方法。状态/hash先输出，UTF-8主动累计≤32KiB；未回显记UNKNOWN，不修摘录器或补跑。
2. 一次准确两源读取：D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt（预期1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313）与 D:/flutter/packages/flutter_tools/gradle/aar_init_script.gradle（新任务允许的准确公开来源，先确认本地M5-14/16保存locator/哈希；不据聊天猜替代路径，不存在/locator不符即停）。各存在/普通非reparse/≤256KiB/hash门。插件完整apply中addFlutterTasks调用及所有提前return/is-plugin条件、addFlutterDeps完整body；init script短全文优先回显，记录is-plugin/output-dir/buildNumber、任务/publication、callback顺序与Flutter任务接线。不重复addFlutterTasks旧完整摘录，只引用M5-26已核正文。输出UTF-8≤32KiB主动限额；未回显明确UNKNOWN，不补读重跑。

每轮各源完整读一次入内存，定点选择不等于调用图闭合；总2/2。新预算只补未核语义，不重跑旧验证/注册/定位/NDK。入口authority和已存证据读取不算专业预算。源失败/缺失/hash变化/链接/大小超限即停，不下一轮、不修复重试；所有未执行项NOT_CHECKED。没有测试/运行预算。

## 唯一plan必须落到修订方案

列来源hash/行/可达条件/阶段/预算与同次回执；明确is-plugin的存在与布尔值是否区别、AAR init介入时序、com.android.library如何被分类、host check在所选AAR路径是否可达（未证保持UNKNOWN）。完整插件依赖与embedding接线、FlutterTask注册/参数/输入输出与registrant准确调用点，超出两轮四源的实现不扩读，只给直接准确引用/未知。

将仓库注入、SDK/config/engine、NDK/.cxx/native_assets、metadata与host/AAR拓扑合并成一份下一配置修订提案：准确列可改变四正文行、输入/property/调用合同、需保留的隔离前置条件。不是新增恒定record或逐行拒绝器；无证据的解决方案保持proposed，不能声称官方语义兼容。不自行采用远程仓库/PREFER_SETTINGS/删gate，不自行绕过版本/NDK检查。若最小standalone AAR接线已经有来源，优先给可实现SOURCE-ONLY修订；否则给精确阻塞，不靠新增app掩盖入口缺口。

禁止SDK/源码/renderer写、生成bundle、目录搜索/索引或其它源追读、配置/cache/env/home/真实properties/metadata/json/engine/插件材料读取、下载复制、算法/测试/Gradle/Flutter/JVM/ADB/构建安装启动/UAC、旧D:\EliteSync、真实数据/备份密钥/DB/SSH/API、Git提交/pull/push。保留dirty/untracked。两新轮关闭后停Work独立LEVEL2审查，不自接受/后继；M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与真实账号/Conversation/恢复门保持。
