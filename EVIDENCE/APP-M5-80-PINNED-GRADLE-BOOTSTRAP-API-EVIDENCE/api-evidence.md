# M5-80 固定 Gradle API 文字证据
DOCS-ONLY CANDIDATE / REVIEW_PENDING。Gradle 8.14 公开文档证据，不是本地安装或运行证明；当前本地 Gradle 身份 UNKNOWN。8.14 仅来自 task 指定的 M5-10 plan 第44行历史基线，本轮未读该文件或本地工具。

## 两个来源及官方原文
1. https://docs.gradle.org/8.14/javadoc/org/gradle/api/invocation/Gradle.html
HTTP200；65176 bytes；SHA256 A155C40185552A66BFAAA9B7F8898A83CB3FA907F5FB55008C6C97043EC17307；strictUTF8；GET1/responseRead1。
anchor beforeProject(org.gradle.api.Action)：
“Adds an action to be called immediately before a project is evaluated.”
签名 void beforeProject(Action<? super Project> action)，Since: 3.4。可支持 evaluation 前 Action 回调的公开 API 合同；不能据此推断 Android 插件已应用、Extension 已建立或 FlutterPlugin 早期消费者已准备。
同页 anchor beforeProject(groovy.lang.Closure) 另写 “Adds a closure to be called immediately before a project is evaluated. The project is passed to the closure as a parameter.” 这是不同重载，不替 Action 增补未写的顺序保证。

2. https://docs.gradle.org/8.14/javadoc/org/gradle/api/plugins/ExtraPropertiesExtension.html
HTTP200；23997 bytes；SHA256 BA2D91FDE491FD4DC6518763CEE0FD637791262CA84AE779C5D4D4127E6D76B5；strictUTF8；GET1/responseRead1。
anchor has(java.lang.String)：
“Returns whether or not the extension has a property registered via the given name.”
可支持检查该 extension 的注册属性，不能以 Project.hasProperty 同名检查替代。
anchor get(java.lang.String)：
“Returns the value for the registered property with the given name.”
直接 get 缺项抛 ExtraPropertiesExtension.UnknownPropertyException；Groovy property notation 缺项抛 MissingPropertyException。缺项不能作为合法已安装值。
anchor set(java.lang.String,java.lang.Object)：
“Updates the value for, or creates, the registered property with the given name to the given value.”
它提供创建/更新能力，本身不保证只创建、不覆盖、类型正确或冲突首停；这些必须由未来行为规范单独约束。
anchor getProperties()：
“Returns all of the registered properties and their current values as a map. The returned map is detached from the extension. That is, any changes made to the map do not change the extension from which it originated.”
该段示例同时显示 project.version 与 project.hasProperty("version") 为真，而 project.ext.properties.containsKey("version") 为假。因此项目可见属性与此 extension 注册集合有区别；改返回 map 不能充当安装。

## 能支持与未证明
本次定位的是方法完整 section 的静态文字，HTML 解实体、去标签、空白折叠后回显；不执行网页示例。可支持对一个已取得的 ExtraPropertiesExtension 使用 has/get/set，及其 map 脱离语义。
本次窗口未回显类级 ownership/获取 extension 的完整说明；准确 rootOwn/child own 获取链 API 依据 NOT_COVERED。Project.hasProperty 的继承查找规则未取其官方页面，UNKNOWN；不能从本页例子补造继承算法。
beforeProject 是 evaluation 前回调，不等于任何特定插件 apply 之前的通用安装保证。真实 Android 插件、LibraryExtension 与 FlutterPlugin 早期调用顺序仍 NOT_PROVEN；实际安装者 locator/适用 hook 仍 NOT_FIXED。8.14 API 不能证明当前安装版本兼容。
没有复读 recipe 或重写 M5-79 bootstrap 合同，没有生成安装代码、工程或 SDK 材料。

## 唯一未来草案
DRAFT / NOT_ISSUED：由 Work 另立 SOURCE-ONLY bootstrap 候选任务，先取得准确 own extension 获取链、目标绑定及真实消费时序所需证据，再决定 API；上述缺口阻止当前直接宣称可用安装入口。本轮不发布或执行后继。

## 原回执、预算与限制
A=66ac6f，exit0；宿主原命令3254字符≤4096。main/cf8bfaa4a03b8c9a682105617b185141904413be；默认目录粒度status238，237旧成员缺0；目标原不存在，输出目录及到根完整祖先均普通。
PUBLIC_DOC_HTTP实际2；按序两URL各GET1/正文Read1，补请求0；无redirect/cookies/default credentials/proxy，credentials=null；每请求timeout30s、响应buffer≤1048576，各正文strictUTF8/hash来自同次内存。未保存HTML。
A输出限额≤8192 UTF8 bytes且≤10000字符，先核再输出；完整实际尺寸由宿主原回执另核。保存时B0/1，唯一报告文件工具新建一次；B只核报告身份与宿主全文，B后不改。
其它候选Parser/helper/Python/AST/compile/import/exec/transform/StaticTest/Kotlin/Gradle/SDK/Flutter/JVM/ADB/依赖解析/工程生成复制/构建安装启动0；普通治理和HTTP静态文字读取已执行。
dirty/untracked、十五冻结、rawfixture、M5-50输入阻塞、旧候选及闭预算保持；未Git写操作或HOME/SDK/cache读取。父tool独立stderr UNKNOWN，硬截止OS隔离 NOT_PROVEN；M5/隔离构建 NOT_READY、settings拒绝、loader-runtime false、earlypreflight PROPOSED及真实性/恢复/生产/UAC门保持。
停独立 Sol/high 与 Work LEVEL2，不自接受。
