# M5-81 own extension API 证据
DOCS-ONLY CANDIDATE / REVIEW_PENDING。仅 Gradle 8.14 公开静态文档；当前本地 Gradle 版本 UNKNOWN，不证明安装者或运行兼容。M5-80报告REJECT/CLOSED，原文件未改、不整体引用。

## 官方原文与出处
1. https://docs.gradle.org/8.14/javadoc/org/gradle/api/Project.html
HTTP200；275261 bytes；SHA256 F4119EBD5E1DF98694F116C2153B0C37387E4D50DEE10FDC8217FDC6B3D14A53；strictUTF8；GET1/responseRead1。
anchor getRootProject()，签名 Project getRootProject()：
“Returns the root project for the hierarchy that this project belongs to. In the case of a single-project build, this method returns this project.”
Returns: “The root project. Never returns null.”
可支持取得该项目所属层级的根项目；不能据此把返回对象等同于某个材料 recipe 或隔离目标。
type-signature 原文：
“public interface Project extends Comparable < Project >, ExtensionAware , PluginAware”
这是类型声明，表明 Project extends ExtensionAware；不等于已取得 getExtensions 方法定义或真实目标绑定。
本次固定 inherited-context 定位结果 UNKNOWN，getExtensions 准确继承链接/上下文未回显，NOT_COVERED。没有重新定位、补请求或读取 ExtensionAware 页面，不能宣称该方法定义正文已读。

2. https://docs.gradle.org/8.14/javadoc/org/gradle/api/plugins/ExtensionContainer.html
HTTP200；45693 bytes；SHA256 979175F02C448B7B272C675154E22DB68D197CCE17A20E9635095B7A08001C7D；strictUTF8；GET1/responseRead1。
anchor getExtraProperties()，签名 ExtraPropertiesExtension getExtraProperties()：
“The extra properties extension in this extension container. This extension is always present in the container, with the name \"ext\".”
Returns: “The extra properties extension in this extension container.”
可支持 extra properties 属于该 extension container，且以 ext 名称始终存在。未证明手中 container 属于哪个实际 project；不能据此补造 rootOwn/child own 获取链。

## 缺口与唯一未来草案
Project → getExtensions → ExtensionContainer 的方法链接上下文本轮未覆盖，准确链条证据仍缺。Project.hasProperty 继承行为未读，UNKNOWN；真实目标绑定与适用 hook NOT_FIXED，Android插件/LibraryExtension与早期消费者顺序 NOT_PROVEN。不能宣称可运行、兼容、原子或真实 own 安装。
DRAFT / NOT_ISSUED：由 Work 另立准确来源和预算的 SOURCE-ONLY 前置证据任务，先补 getExtensions 链条与目标/时序依据，之后才决定实现范围。本轮不重写 bootstrap 合同、不生成脚本、安装代码、工程或 SDK 材料，不派后继。

## 原回执与预算
A=f9b2ba，exit0；宿主命令3977字符≤4096。main/cf8bfaa4a03b8c9a682105617b185141904413be，默认目录status239，238旧成员缺0；目标原不存在，输出目录到根完整普通祖先通过。
PUBLIC_DOC_HTTP2；两URL按序各GET1/正文Read1，补请求0；HttpClient无redirect/cookies/default credentials/proxy，Credentials=null，timeout30s，buffer≤1048576。正文同次内存strictUTF8/hash；HTML不落盘，示例不执行。摘录仅解实体/去标签/折叠空白。
A完整输出先核≤8192 UTF8 bytes且≤10000字符，宿主实际尺寸另核。报告宿主先核≤6144 bytes，文件工具新建一次，保存时B0/1；B仅报告身份及宿主全文，不HTTP/补读，B后不改。
所有候选Parser/helper/Python/AST/compile/import/exec/transform/StaticTest/Kotlin/Gradle/SDK/Flutter/JVM/ADB/依赖解析/工程生成复制/构建安装启动0；治理与HTTP静态文字读取另记。无Git写操作、HOME/SDK/cache读取。
dirty/untracked、十五冻结、rawfixture、M5-50原阻塞、旧候选闭budget保持。M5/隔离NOT_READY、settings拒绝、loader-runtime false、earlypreflight PROPOSED及真实性/恢复/生产/UAC门保持；父toolstderr UNKNOWN，硬截止OS隔离 NOT_PROVEN；未实测timeoutkill/Disposeemit失败 NOT_EXERCISED。
停独立 Sol/high 与 Work LEVEL2，不自接受。
