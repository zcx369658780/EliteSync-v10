# APP-M5-38｜完整内存片段应用与人工属性安装合同

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。
唯一仓库 D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；执行会话 01a0f1ec-ff46-7311-a52f-780a64e3d4fb。M5-37 已独立接受冻结纯材料 SOURCE-ONLY及12/12人工tests，M5-36 STATIC ONLY关闭，所有旧预算关闭。本文提出新实现合同，不实现或运行。

## 1. 准确入口、材料常量和文字解释规则

唯一拟议公开入口：
```text
apply_module_debug_materials(*, materials, config) -> AppliedModuleMaterials
```
两个参数均必填 keyword-only，无默认、无位置参数、无额外参数。内部只调用已接受 adapt_module_debug_entry(*, materials=materials, config=config)，获取唯一受控 EntryMaterials；不接收外部 EntryMaterials、PatchOperation、自由operations、目录或安装根参数。该内部调用只是后继实现要求，本轮未调用。

附录 A 完整转录固定测试源的字面文本，不执行它。本文常量 O 为该附录 ORIGINALS 的完整四项 tuple；EC 为 EXPECTED_CODE 的完整字面 dict；ES 为 EXPECTED_SCRATCH 的完整三项字面 dict。每个原文 str-literal.encode('utf-8') 表示其中完整字符串经 UTF8 编码的 bytes，按该字面定义解释转义、保留缩进、LF和最终LF，无BOM。不调用生产私有 _CODE、expected、测试或转换算法来建立预期。附录中 def/import/if 只是封存来源文本，不是本任务可执行代码；主文完整对象手工引用这些已定义字面常量。

O 的准确顺序是 tasks-full、repo-block、init-full、plugin-deps，四项 bytes 全文在附录 A 的 ORIGINALS 中各定义一次；不得只用hash替代。ES三个完整结果全文也在附录A定义一次。定义：
```text
OT = O[0][1]; OR = O[1][1]; OI = O[2][1]; OD = O[3][1]
AT = ES['tasks-full']; AR = ES['repo-block']; AI = ES['init-full']
INPUT = (('tasks-full',OT),('repo-block',OR),('init-full',OI),('plugin-deps',OD))
FRAGMENTS = (('tasks-full',AT),('repo-block',AR),('init-full',AI),('plugin-deps',OD))
```
上式是命名引用与固定完整tuple定义，不是调用 adapter 或从实际输出回算预期。附录 B 完整转录已接受 M5-29 合同，给EC所对应完整14正文、原Invocation/Attachment/recipe字段来源；其历史候选标题和历史budget仅为引用，不授本轮额外预算。本文是应用层新合同。

## 2. 精确输入域与异常

materials 为 exact tuple，四成员每项 exact tuple 长度2，id exact str、body exact bytes。config 为 exact dict，必须且仅有以下11键：mode、flutter_identity、init_identity、input_id、projects、properties、tasks、sdk_root、maven_root、publication_root、repositories_mode。材料顺序、原四hash、大小、唯一锚、身份及固定值沿用附录B已接受合同。每份材料≤256KiB，总≤1MiB；原hash绑定原输入，不在scratch变更后重要求原hash。

exact类型排除子类；bool不能冒充int，bytearray/list/custom object不能冒充bytes/tuple；properties为四项exact tuple，每项(project,六项(key,value)tuple)，key/value exact str。projects/tasks exact tuple of exact str。config余下每个值及嵌套六property值 exact str，固定域和64个ASCII小写hex input_id按附录B。先类型检查，后schema/值域；不调用自定义对象方法。沿用adapter的 TypeError('TYPE') 和 ValueError('CONTRACT')，不回显输入或路径。

公开类型不符或子类→TypeError('TYPE')；exact类型但键/顺序/hash/固定值/ID等不符→ValueError('CONTRACT')。原适配输出重新当原输入因hash/材料身份不符→CONTRACT。原config调用者其后改动不改变已返回对象。失败不修改输入，不回传局部scratch/部分installation/result；不存在将错误转为legacy/default或UNKNOWN成功的分支。

## 3. 精确不可变返回域

所有新类型均 frozen dataclass(slots=True)，无默认槽；容器仅tuple，值仅exact str/bytes/bool或已有frozen类型；不返回list/dict或调用者引用。返回恰好如下字段，禁止额外调试输出域或实际路径：
```text
AppliedModuleMaterials(
  fragments: 四项 tuple[(exact str, exact bytes)]，固定顺序 tasks-full,repo-block,init-full,plugin-deps,
  attachments: 两项 tuple[Attachment]，原包准确顺序和值,
  invocation: InvocationContract，原包全部字段和值,
  model_installation: 四项 tuple[ModelProjectInstallation]，固定四project顺序,
  model_only: exact bool，固定True
)
ModelProjectInstallation(
  project: exact str，固定所在project,
  scope: exact str，固定LOCAL_EXTRA,
  phase: exact str，固定BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS,
  root_token: exact str，固定B/module/.android,
  own_properties: 六项 tuple[(exact str,exact str)]，准确六键及顺序,
  model_only: exact bool，固定True
)
```
四fragment没有省略/自由项。Attachment/Invocation原类型及所有字段精确定义于附录B，不增加或删字段。fragments是完整适配片段而非operations，plugin-deps必须逐byte等于OD。两Attachment仍executable_patch=False，不插入scratch、SDK或class。Invocation.runtime_ready=False，logical_properties中的output-dir仍publication，property_installation仍原typed recipe；不把其逻辑token改成模型字符串。

无对象identity跨调用保证；值相等及输入脱离是合同。相同输入重复调用值相等，无环境/时钟/随机状态读取。

## 4. 六步scratch规则与完整正例推导

内部adapter先验证全部原输入并返回完整包，再建立局部scratch字典，仅保存四份原bytes的局部引用。只按包operations准确order0..5操作，不按caller字段开放patch入口。每操作target/kind/order/anchor_id及before/after必须与固定包一致；input_fragment_sha256永远指各target原始片段，不指前一步scratch。

REPLACE_UNIQUE：在当前target bytes中before准确非空且count=1，以after替换这一处。
INSERT_BEFORE_UNIQUE：before准确非空且count=1，插入after在它之前，保留before原bytes。共享init-all锚先插helpers后替换guard；insert后它仍唯一。

一项P1完整推导（均为手工合同，不是本轮运行结果）：
定义 C0={'tasks-full':OT,'repo-block':OR,'init-full':OI,'plugin-deps':OD}。
对任何本步骤before，L/R为当时完整target中唯一before两侧的完整bytes；这是唯一分解，不strip/规范化任何byte。
```text
order0 target=repo-block kind=REPLACE_UNIQUE:
  before=EC['repo-before']; after=EC['repo-after']
  C1.repo-block=AR（完整EC['repo-after']），其余等C0。
order1 target=tasks-full kind=REPLACE_UNIQUE:
  before=EC['tasks-before']; after=EC['tasks-after']
  OT=L1+EC['tasks-before']+R1
  C2.tasks-full=L1+EC['tasks-after']+R1=AT，其余等C1。
order2 target=init-full kind=INSERT_BEFORE_UNIQUE:
  before=EC['init-all-before']; after=EC['init-helpers']
  OI=L2+EC['init-all-before']+R2
  C3.init-full=L2+EC['init-helpers']+EC['init-all-before']+R2，其余等C2。
order3 target=init-full kind=REPLACE_UNIQUE:
  before=EC['init-all-before']; after=EC['init-all-after']
  C4.init-full=L2+EC['init-helpers']+EC['init-all-after']+R2，其余等C3。
order4 target=init-full kind=REPLACE_UNIQUE:
  before=EC['init-afterProject-before']; after=EC['init-afterProject-after']
  C4.init-full=L4+EC['init-afterProject-before']+R4
  C5.init-full=L4+EC['init-afterProject-after']+R4，其余等C4。
order5 target=init-full kind=REPLACE_UNIQUE:
  before=EC['init-projectsEvaluated-before']; after=EC['init-projectsEvaluated-after']
  C5.init-full=L5+EC['init-projectsEvaluated-before']+R5
  C6.init-full=L5+EC['init-projectsEvaluated-after']+R5=AI，其余等C5。
final四份完整结果=FRAGMENTS；C6.plugin-deps=OD。
```
14个before/after正文已在EC完整定义，无省略正文。L/R不包含被换锚，但含剩余所有原byte，因而callback原body、host分支及所有非替换范围逐byte保留；helpers只插一次。C1–C6不成为公众输出。

adapter验证来源后，上述内部count/order/kind/target仍做防御检查。若后半程内部不变量违例，抛ValueError('CONTRACT')，丢弃全部局部结果；这是内部实现缺陷的防御，不是当前允许公众注入任意操作来触发的用例。本合同不提供通用应用外部EntryMaterials API。所有scratch和installation均完成后才构造一个完整结果。

## 5. 固定人工安装模型

唯一根token ROOT_MODEL='B/module/.android'，唯一分隔符为ASCII '/'。这不是用户参数或真实目录。RootProjectDirFilePath固定base ROOT_PROJECT_DIR、child_components=('..','..','publication')、result FILE_PATH、phase准确；在本模型只拼接固定token得到：
MODEL_OUTPUT='B/module/.android/../../publication'。
保留两个..，不normalize/canonical/resolve，不调用Python pathlib/os.path、Java File.path或宿主I/O。LiteralString仅取其既定key/value。固定按四project分别生成六own属性；scope/phase是模型说明，不声称真实Gradle属性安装或bootstrap已发生。

PHASE='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS'。
每个ModelProjectInstallation.root_token=ROOT_MODEL、scope='LOCAL_EXTRA'、phase=PHASE、model_only=True。Invocation里的logical output-dir和recipe不改。人工字符串投影不证明Java/Windows separator、真实File.path、目录存在性、ACL/symlink或OS隔离。

## 6. P1/P2完整config、属性及安装表

本文共享常量一次完整定义：
```text
F='1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'
I='B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2'
IDA='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
IDB='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
P=(':',':flutter',':sample_alpha',':sample_beta')
T=('assembleAarDebug',)
PROP_A=(
 ('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),
 ('output-dir','publication'),('buildNumber',IDA),
 ('elitesync.sdk-identity',F),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
PROP_B=(
 ('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),
 ('output-dir','publication'),('buildNumber',IDB),
 ('elitesync.sdk-identity',F),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
LA=((':',PROP_A),(':flutter',PROP_A),(':sample_alpha',PROP_A),(':sample_beta',PROP_A))
LB=((':',PROP_B),(':flutter',PROP_B),(':sample_alpha',PROP_B),(':sample_beta',PROP_B))
CONFIG_A={
 'mode':'module-debug-v1','flutter_identity':F,'init_identity':I,'input_id':IDA,
 'projects':P,'properties':LA,'tasks':T,'sdk_root':'materials/flutter_sdk',
 'maven_root':'materials/maven','publication_root':'publication',
 'repositories_mode':'FAIL_ON_PROJECT_REPOS'
}
CONFIG_B={
 'mode':'module-debug-v1','flutter_identity':F,'init_identity':I,'input_id':IDB,
 'projects':P,'properties':LB,'tasks':T,'sdk_root':'materials/flutter_sdk',
 'maven_root':'materials/maven','publication_root':'publication',
 'repositories_mode':'FAIL_ON_PROJECT_REPOS'
}
P1_INPUT=(materials=INPUT,config=CONFIG_A)
P2_INPUT=(materials=INPUT,config=CONFIG_B)
OWN_A=(
 ('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),
 ('output-dir','B/module/.android/../../publication'),('buildNumber',IDA),
 ('elitesync.sdk-identity',F),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
OWN_B=(
 ('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),
 ('output-dir','B/module/.android/../../publication'),('buildNumber',IDB),
 ('elitesync.sdk-identity',F),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
INSTALL_A=(
 ModelProjectInstallation(':','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_A,True),
 ModelProjectInstallation(':flutter','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_A,True),
 ModelProjectInstallation(':sample_alpha','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_A,True),
 ModelProjectInstallation(':sample_beta','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_A,True)
)
INSTALL_B=(
 ModelProjectInstallation(':','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_B,True),
 ModelProjectInstallation(':flutter','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_B,True),
 ModelProjectInstallation(':sample_alpha','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_B,True),
 ModelProjectInstallation(':sample_beta','LOCAL_EXTRA',PHASE,ROOT_MODEL,OWN_B,True)
)
```
CONST引用均在本文完整定义；不是缺字段或caller默认。安装表每个project六键完整且同序，只变buildNumber绑定。

## 7. 两份完整Invocation与非可执行Attachment预期

下列recipe及结构完整定义，不调用附录expected函数：
```text
FILE_RECIPE=RootProjectDirFilePath('output-dir','ROOT_PROJECT_DIR',('..','..','publication'),'FILE_PATH',PHASE)
RA=(
 LiteralString('elitesync.aar-entry','module-debug-v1'),LiteralString('is-plugin','false'),FILE_RECIPE,
 LiteralString('buildNumber',IDA),LiteralString('elitesync.sdk-identity',F),
 LiteralString('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
RB=(
 LiteralString('elitesync.aar-entry','module-debug-v1'),LiteralString('is-plugin','false'),FILE_RECIPE,
 LiteralString('buildNumber',IDB),LiteralString('elitesync.sdk-identity',F),
 LiteralString('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
GI_A=(InstallationGroup(':','LOCAL_EXTRA',RA),InstallationGroup(':flutter','LOCAL_EXTRA',RA),
      InstallationGroup(':sample_alpha','LOCAL_EXTRA',RA),InstallationGroup(':sample_beta','LOCAL_EXTRA',RA))
GI_B=(InstallationGroup(':','LOCAL_EXTRA',RB),InstallationGroup(':flutter','LOCAL_EXTRA',RB),
      InstallationGroup(':sample_alpha','LOCAL_EXTRA',RB),InstallationGroup(':sample_beta','LOCAL_EXTRA',RB))
ATTACHMENTS=(
 Attachment(id='apply-helper',placement='FLUTTER_PLUGIN_CLASS_MEMBER',historical_sdk_identity=F,
            before=b'',after=EC['apply-helper'],executable_patch=False),
 Attachment(id='apply-preflight-proposal',placement='APPLY_AFTER_THIS_PROJECT_ASSIGNMENT',
            historical_sdk_identity=F,before=EC['preflight-before'],
            after=EC['preflight-after'],executable_patch=False)
)
INV_A=InvocationContract(
 mode='module-debug-v1',requested_tasks=T,projects=P,logical_properties=LA,
 property_installation=GI_A,property_install_phase=PHASE,
 sdk_root='materials/flutter_sdk',maven_root='materials/maven',
 publication_root='publication',publication_repository='publication/outputs/repo',
 repositories_mode='FAIL_ON_PROJECT_REPOS',module_project=':flutter',module_variant='debug',
 plugin_projects=(':sample_alpha',':sample_beta'),plugin_variants=('debug','debug'),
 aar_task_edges=((':flutter:assembleAarDebug',':sample_alpha:assembleAarDebug'),
                 (':flutter:assembleAarDebug',':sample_beta:assembleAarDebug')),
 publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository',
                     ':sample_alpha:publishDebugPublicationToControlledDebugRepository',
                     ':sample_beta:publishDebugPublicationToControlledDebugRepository'),
 sdk_identity=F,init_identity=I,input_id=IDA,runtime_ready=False
)
INV_B=InvocationContract(
 mode='module-debug-v1',requested_tasks=T,projects=P,logical_properties=LB,
 property_installation=GI_B,property_install_phase=PHASE,
 sdk_root='materials/flutter_sdk',maven_root='materials/maven',
 publication_root='publication',publication_repository='publication/outputs/repo',
 repositories_mode='FAIL_ON_PROJECT_REPOS',module_project=':flutter',module_variant='debug',
 plugin_projects=(':sample_alpha',':sample_beta'),plugin_variants=('debug','debug'),
 aar_task_edges=((':flutter:assembleAarDebug',':sample_alpha:assembleAarDebug'),
                 (':flutter:assembleAarDebug',':sample_beta:assembleAarDebug')),
 publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository',
                     ':sample_alpha:publishDebugPublicationToControlledDebugRepository',
                     ':sample_beta:publishDebugPublicationToControlledDebugRepository'),
 sdk_identity=F,init_identity=I,input_id=IDB,runtime_ready=False
)
EXPECTED_P1=AppliedModuleMaterials(FRAGMENTS,ATTACHMENTS,INV_A,INSTALL_A,True)
EXPECTED_P2=AppliedModuleMaterials(FRAGMENTS,ATTACHMENTS,INV_B,INSTALL_B,True)
```
四fragment、14EC、Attachment正文在附录A字面常量完整定义，plugin-deps用完整OD；P1/P2仅既有动态ID和buildNumber及其引用表不同。所有bytes及两Attachment两例相同。没有从production _CODE复制预期，没有运行expected或adapter；Invocation全部字段具体值保持附录B的准确原域，人工安装表另存。

## 8. 负例、内部失败和必要后继测试

以下每项独立从完整P1/P2改变，固定异常，无部分结果、不修改输入：
| 改变 | 异常 |
|---|---|
| 顶层materials/config类型或子类；嵌套tuple/str/bytes子类、bool/null/custom object | TypeError('TYPE') |
| exact材料缺/多/乱序/id错、bytes/hash/身份错、已有适配输入、材料任一byte变异 | ValueError('CONTRACT') |
| config缺/额外键；自由root/op/EntryMaterials/recipe/env/executable字段 | ValueError('CONTRACT') |
| exact str mode错误/空；mode为null/bool | 值错误CONTRACT；类型错误TYPE |
| projects缺/多/乱序/app/未知后代；tasks非法/release/profile/多任务/前缀 | ValueError('CONTRACT') |
| properties缺project/六键缺多重排重复、only-root/值冲突；其值非str | schema/值CONTRACT；类型TYPE |
| input_id不合64ASCII小写hex、P2任一buildNumber仍IDA；任一ID不一致 | ValueError('CONTRACT') |
| logical output-dir绝对/UNC/drive/../或直接模型路径、root覆盖、repo策略绕过 | ValueError('CONTRACT') |
| 公共调用提供任意操作包或Model根参数 | 不属于公开入口；额外keyword参数为Python调用TypeError，不定义动态patch通道 |

最后一项是签名拒绝，不声称TypeError消息必须TYPE；TYPE固定消息属于函数已进入后的输入域检查。位置参数/缺必填参数同样遵从Python签名TypeError，不与adapter错误消息混淆。合法输入后内部scratch不变量失败属于实现缺陷，防御性CONTRACT并丢弃局部结果；不为了测试该路径新增公众op注入能力。

下一实现候选路径仅建议：
D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_applied_materials.py
D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_applied_materials.py
本任务不创建它们。新任务必须准确允许加载已接受adapter，固定来源/测试预算、纯内存边界和独立审查门。

必要人工测试：两例完整AppliedModuleMaterials逐字段等值；四完整fragment bytes（含OD原样）、两Attachment/Invocation原样、四project完整OWN表；六操作所有未替换byte/共享锚/helpers一次；输入脱离/不可变/确定性；适配输出再输入拒绝；上述类型/schema/order/hash/project/task/ID/path/额外入口负例。expected必须本文独立literal，不从实际输出或生产私有常量回算。未来只通过准确加载唯一测试文件，不discovery/真实工程落地；实际新算法与全面负例覆盖本轮 NOT_CHECKED。原12 tests结果不自动证明此新应用层。

## 9. 权限和终点

仅文档A/B预算各1；所有Python/AST/adapter/expected/算法/测试/checker/launcher/SDK/Gradle/Flutter/JVM/ADB/构建安装启动预算0，实际0。完整附录只作为文字材料，不执行。原两source、harness与旧证据不改；无commit/pull/push/reset/clean/stash、旧D:\EliteSync/真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/metadata/properties访问、目录索引搜索/下载复制/真实落地/UAC。

M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false；真实账号/Conversation/恢复/生产/UAC门保持。SOURCE-ONLY人工模型不证明真实兼容、可恢复、路径隔离或安装。候选完成或首失败后停Work独立LEVEL2；不自接受、后继或恢复旧预算。


## 来源A同次身份回执
```text
SOURCE EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md BYTES=40085 SHA256=B7477C177E1CB1860959BD4136E6B1A1B33A5D9F2B75E75BDB4F6FC442A95382
SOURCE apps/android_synthetic_demo/tools/aar_entry_materials.py BYTES=20338 SHA256=B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7
SOURCE apps/android_synthetic_demo/tools/test_aar_entry_materials.py BYTES=74376 SHA256=F067B5D169E21F690369B573A1882CD6D7082979E730FEC203954C07DA9A45D2
TOTAL_BYTES=134799 READ_COUNT=3 A_BUDGET=1/1
```
A为3次准确ReadAllBytes；payload UTF8 507 bytes。来源正文不回显；直接将同次内存中的冻结原测试和已接受合同完整文本转录为以下文档常量附录，不运行提取器、不解析AST或求值。工具chunk/exit/wall元数据在B后仅附回执。

## 附录 A｜已冻结人工测试完整文字（不可执行）
```text
from __future__ import annotations

import importlib.util
import sys
import unittest
from dataclasses import FrozenInstanceError

ORIGINALS = (
    ('tasks-full', "    private fun addFlutterTasks(projectToAddTasksTo: Project) {\n        if (projectToAddTasksTo.state.failure != null) {\n            return\n        }\n\n        FlutterPluginUtils.addTaskForJavaVersion(projectToAddTasksTo)\n        FlutterPluginUtils.addTaskForKGPVersion(projectToAddTasksTo)\n        if (FlutterPluginUtils.isFlutterAppProject(projectToAddTasksTo)) {\n            FlutterPluginUtils.addTaskForPrintBuildVariants(projectToAddTasksTo)\n            FlutterPluginUtils.addTasksForOutputsAppLinkSettings(projectToAddTasksTo)\n        }\n\n        val targetPlatforms: List<String> =\n            FlutterPluginUtils.getTargetPlatforms(projectToAddTasksTo)\n\n        val flutterPlugin = this\n\n        if (FlutterPluginUtils.isFlutterAppProject(projectToAddTasksTo)) {\n            // TODO(gmackall): I think this can be BaseExtension, with findByType.\n            val android: AbstractAppExtension =\n                projectToAddTasksTo.extensions.findByName(\"android\") as AbstractAppExtension\n            android.applicationVariants.configureEach {\n                val variant = this\n                val assembleTask = variant.assembleProvider.get()\n                if (!FlutterPluginUtils.shouldConfigureFlutterTask(\n                        projectToAddTasksTo,\n                        assembleTask\n                    )\n                ) {\n                    return@configureEach\n                }\n                val copyFlutterAssetsTask: Task =\n                    addFlutterDeps(variant, flutterPlugin, targetPlatforms)\n\n                // TODO(gmackall): Migrate to AGPs variant api.\n                //    https://github.com/flutter/flutter/issues/166550\n                @Suppress(\"DEPRECATION\")\n                val variantOutput: com.android.build.gradle.api.BaseVariantOutput = variant.outputs.first()\n                val processResources: ProcessAndroidResources =\n                    try {\n                        variantOutput.processResourcesProvider.get()\n                    } catch (e: UnknownTaskException) {\n                        // TODO(gmackall): Migrate to AGPs variant api.\n                        //    https://github.com/flutter/flutter/issues/166550\n                        @Suppress(\"DEPRECATION\")\n                        variantOutput.processResources\n                    }\n                processResources.dependsOn(copyFlutterAssetsTask)\n\n                // Copy the output APKs into a known location, so `flutter run` or `flutter build apk`\n                // can discover them. By default, this is `<app-dir>/build/app/outputs/flutter-apk/<filename>.apk`.\n                //\n                // The filename consists of `app<-abi>?<-flavor-name>?-<build-mode>.apk`.\n                // Where:\n                //   * `abi` can be `armeabi-v7a|arm64-v8a|x86_64` only if the flag `split-per-abi` is set.\n                //   * `flavor-name` is the flavor used to build the app in lower case if the assemble task is called.\n                //   * `build-mode` can be `release|debug|profile`.\n                variant.outputs.forEach { output ->\n                    assembleTask.doLast {\n                        // TODO(gmackall): Migrate to AGPs variant api.\n                        //    https://github.com/flutter/flutter/issues/166550\n                        @Suppress(\"DEPRECATION\")\n                        output as com.android.build.gradle.api.ApkVariantOutput\n                        val packageApplicationProvider: PackageAndroidArtifact =\n                            variant.packageApplicationProvider.get()\n                        val outputDirectory: Directory =\n                            packageApplicationProvider.outputDirectory.get()\n                        val outputDirectoryStr: String = outputDirectory.toString()\n                        var filename = \"app\"\n\n                        // TODO(gmackall): Migrate to AGPs variant api.\n                        //    https://github.com/flutter/flutter/issues/166550\n                        @Suppress(\"DEPRECATION\")\n                        val abi = output.getFilter(com.android.build.VariantOutput.FilterType.ABI)\n                        if (abi != null && abi.isNotEmpty()) {\n                            filename += \"-$abi\"\n                        }\n                        if (variant.flavorName != null && variant.flavorName.isNotEmpty()) {\n                            filename += \"-${FlutterPluginUtils.lowercase(variant.flavorName)}\"\n                        }\n                        filename += \"-${FlutterPluginUtils.buildModeFor(variant.buildType)}\"\n                        projectToAddTasksTo.copy {\n                            from(File(\"$outputDirectoryStr/${output.outputFileName}\"))\n                            into(projectToAddTasksTo.layout.buildDirectory.dir(\"outputs/flutter-apk\"))\n                            rename { \"$filename.apk\" }\n                        }\n                    }\n                }\n            }\n            // Copy the native assets created by build.dart and placed here by flutter assemble.\n            // This path is not flavor specific and must only be added once.\n            // If support for flavors is added to native assets, then they must only be added\n            // once per flavor; see https://github.com/dart-lang/native/issues/1359.\n            val nativeAssetsDir =\n                \"${projectToAddTasksTo.layout.buildDirectory.get()}/../native_assets/android/jniLibs/lib/\"\n            android.sourceSets\n                .getByName(\"main\")\n                .jniLibs\n                .srcDir(nativeAssetsDir)\n            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n                projectToAddTasksTo,\n                getPluginHandler(projectToAddTasksTo).getPluginList()\n            )\n            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n            if (projectToAddTasksTo.rootProject.hasProperty(\"flutter.hostAppProjectName\")) {\n                projectToAddTasksTo.rootProject.property(\n                    \"flutter.hostAppProjectName\"\n                ) as? String\n            } else {\n                \"app\"\n            }\n        val appProject: Project? =\n            projectToAddTasksTo.rootProject.findProject(\":$hostAppProjectName\")\n        check(appProject != null) {\n            \"Project :$hostAppProjectName doesn't exist. To customize the host app project name, set `flutter.hostAppProjectName=<project-name>` in gradle.properties.\"\n        }\n        // Wait for the host app project configuration.\n        appProject.afterEvaluate {\n            val androidLibraryExtension =\n                projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)\n            check(androidLibraryExtension != null)\n            androidLibraryExtension.libraryVariants.all libraryVariantAll@{\n                val libraryVariant = this\n                var copyFlutterAssetsTask: Task? = null\n                val androidAppExtension =\n                    appProject.extensions.findByName(\"android\") as? AbstractAppExtension\n                check(androidAppExtension != null)\n                androidAppExtension.applicationVariants.all applicationVariantAll@{\n                    val appProjectVariant = this\n                    val appAssembleTask: Task = appProjectVariant.assembleProvider.get()\n                    if (!FlutterPluginUtils.shouldConfigureFlutterTask(project, appAssembleTask)) {\n                        return@applicationVariantAll\n                    }\n\n                    // Find a compatible application variant in the host app.\n                    //\n                    // For example, consider a host app that defines the following variants:\n                    // | ----------------- | ----------------------------- |\n                    // |   Build Variant   |   Flutter Equivalent Variant  |\n                    // | ----------------- | ----------------------------- |\n                    // |   freeRelease     |   release                     |\n                    // |   freeDebug       |   debug                       |\n                    // |   freeDevelop     |   debug                       |\n                    // |   profile         |   profile                     |\n                    // | ----------------- | ----------------------------- |\n                    //\n                    // This mapping is based on the following rules:\n                    // 1. If the host app build variant name is `profile` then the equivalent\n                    //    Flutter variant is `profile`.\n                    // 2. If the host app build variant is debuggable\n                    //    (e.g. `buildType.debuggable = true`), then the equivalent Flutter\n                    //    variant is `debug`.\n                    // 3. Otherwise, the equivalent Flutter variant is `release`.\n                    val variantBuildMode: String =\n                        FlutterPluginUtils.buildModeFor(libraryVariant.buildType)\n                    if (FlutterPluginUtils.buildModeFor(appProjectVariant.buildType) != variantBuildMode) {\n                        return@applicationVariantAll\n                    }\n                    copyFlutterAssetsTask = copyFlutterAssetsTask ?: addFlutterDeps(\n                        libraryVariant,\n                        flutterPlugin,\n                        targetPlatforms\n                    )\n                    // TODO(gmackall): Migrate to AGPs variant api.\n                    //    https://github.com/flutter/flutter/issues/166550\n                    val mergeAssets =\n                        projectToAddTasksTo\n                            .tasks\n                            .findByPath(\":$hostAppProjectName:merge${FlutterPluginUtils.capitalize(appProjectVariant.name)}Assets\")\n                    check(mergeAssets != null)\n                    mergeAssets.dependsOn(copyFlutterAssetsTask)\n                }\n            }\n        }\n        getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n        FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n            projectToAddTasksTo,\n            getPluginHandler(projectToAddTasksTo).getPluginList()\n        )\n    }\n\n".encode('utf-8')),
    ('repo-block', "        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n".encode('utf-8')),
    ('init-full', "// This script is used to initialize the build in a module or plugin project.\n// During this phase, the script applies the Maven plugin and configures the\n// destination of the local repository.\n// The local repository will contain the AAR and POM files.\n\nimport java.nio.file.Paths\n\n\nvoid configureProject(Project project, String outputDir) {\n    if (!project.hasProperty(\"android\")) {\n        throw new GradleException(\"Android property not found.\")\n    }\n    if (!project.android.hasProperty(\"libraryVariants\")) {\n        throw new GradleException(\"Can't generate AAR on a non Android library project.\")\n    }\n\n    // Snapshot versions include the timestamp in the artifact name.\n    // Therefore, remove the snapshot part, so new runs of `flutter build aar` overrides existing artifacts.\n    // This version isn't relevant in Flutter since the pub version is used\n    // to resolve dependencies.\n    project.version = project.version.replace(\"-SNAPSHOT\", \"\")\n\n    if (project.hasProperty(\"buildNumber\")) {\n        project.version = project.property(\"buildNumber\")\n    }\n\n    project.components.forEach { component ->\n        if (component.name != \"all\") {\n            addAarTask(project, component)\n        }\n    }\n\n    project.publishing {\n        repositories {\n            maven {\n                url = uri(\"file://${outputDir}/outputs/repo\")\n            }\n        }\n    }\n\n    if (!project.property(\"is-plugin\").toBoolean()) {\n        return\n    }\n\n    String storageUrl = System.getenv('FLUTTER_STORAGE_BASE_URL') ?: \"https://storage.googleapis.com\"\n\n    String engineRealm = Paths.get(getFlutterRoot(project), \"bin\", \"cache\", \"engine.realm\")\n        .toFile().text.trim()\n    if (engineRealm) {\n        engineRealm += \"/\"\n    }\n\n    // This is a Flutter plugin project. Plugin projects don't apply the Flutter Gradle plugin,\n    // as a result, add the dependency on the embedding.\n    project.repositories {\n        maven {\n            url \"$storageUrl/${engineRealm}download.flutter.io\"\n        }\n    }\n    String engineVersion = Paths.get(getFlutterRoot(project), \"bin\", \"cache\", \"engine.stamp\")\n        .toFile().text.trim()\n    project.dependencies {\n        // Add the embedding dependency.\n        compileOnly (\"io.flutter:flutter_embedding_release:1.0.0-$engineVersion\") {\n            // We only need to expose io.flutter.plugin.*\n            // No need for the embedding transitive dependencies.\n            transitive = false\n        }\n    }\n}\n\nvoid configurePlugin(Project project, String outputDir) {\n    if (!project.hasProperty(\"android\")) {\n        // A plugin doesn't support the Android platform when this property isn't defined in the plugin.\n        return\n    }\n    configureProject(project, outputDir)\n}\n\nstatic String getFlutterRoot(Project project) {\n    if (!project.hasProperty(\"flutter-root\")) {\n        throw new GradleException(\"The `-Pflutter-root` flag must be specified.\")\n    }\n    return project.property(\"flutter-root\")\n}\n\nvoid addAarTask(Project project, component) {\n    String variantName = component.name.capitalize()\n    String taskName = \"assembleAar$variantName\"\n    project.tasks.create(name: taskName) {\n        // This check is required to be able to configure the archives before `publish` runs.\n        if (!project.gradle.startParameter.taskNames.contains(taskName)) {\n            return\n        }\n\n        // Create a default MavenPublication for the variant (except \"all\" since that is used to publish artifacts in the new way)\n        project.publishing.publications.create(component.name, MavenPublication) { pub ->\n            groupId = \"${pub.groupId}\"\n            artifactId = \"${pub.artifactId}_${pub.name}\"\n            version = \"${pub.version}\"\n            from component\n        }\n\n        // Generate the Maven artifacts.\n        finalizedBy \"publish\"\n    }\n}\n\n// maven-publish has to be applied _before_ the project gets evaluated, but some of the code in\n// `configureProject` requires the project to be evaluated. Apply the maven plugin to all projects, but\n// only configure it if it matches the conditions in `projectsEvaluated`\n\nallprojects {\n   apply plugin: \"maven-publish\"\n}\n\nafterProject { project ->\n    // Exit early if either:\n    // 1. The project doesn't have the Android Gradle plugin applied.\n    // 2. The project has already defined which variants to publish (trying to re-define which\n    //    variants to publish will result in an error).\n    if (!project.hasProperty(\"android\")) {\n        return\n    }\n    if (project.android.publishing.singleVariants.size() != 0) {\n        return\n    }\n\n    Closure addSingleVariants = {buildType ->\n        if (!project.android.productFlavors.isEmpty()) {\n            project.android.productFlavors.all{productFlavor ->\n                project.android.publishing.singleVariant(\n                        productFlavor.name + buildType.name.capitalize()\n                ) {\n                    withSourcesJar()\n                    withJavadocJar()\n                }\n            }\n        } else {\n            project.android.publishing.singleVariant(buildType.name) {\n                withSourcesJar()\n                withJavadocJar()\n            }\n        }\n    }\n\n    project.android.buildTypes.all(addSingleVariants)\n}\n\nprojectsEvaluated {\n    assert rootProject.hasProperty(\"is-plugin\")\n    if (rootProject.property(\"is-plugin\").toBoolean()) {\n        assert rootProject.hasProperty(\"output-dir\")\n        // In plugin projects, the root project is the plugin.\n        configureProject(rootProject, rootProject.property(\"output-dir\"))\n        return\n    }\n    if (rootProject.name == \"gradle\") {\n        // Skip the \"gradle\" project, we are looking only for the \"android_generated\" project.\n        return\n    }\n    // The module project is the `:flutter` subproject.\n    Project moduleProject = rootProject.subprojects.find { it.name == \"flutter\" }\n    assert moduleProject != null\n    assert moduleProject.hasProperty(\"output-dir\")\n    configureProject(moduleProject, moduleProject.property(\"output-dir\"))\n\n    // Gets the plugin subprojects.\n    Set<Project> modulePlugins = rootProject.subprojects.findAll {\n        it.name != \"flutter\" && it.name != \"app\"\n    }\n    // When a module is built as a Maven artifacts, plugins must also be built this way\n    // because the module POM's file will include a dependency on the plugin Maven artifact.\n    // This is due to the Android Gradle Plugin expecting all library subprojects to be published\n    // as Maven artifacts.\n    modulePlugins.each { pluginProject ->\n        configurePlugin(pluginProject, moduleProject.property(\"output-dir\"))\n        moduleProject.android.libraryVariants.all { variant ->\n            // Configure the `assembleAar<variantName>` task for each plugin's projects and make\n            // the module's equivalent task depend on the plugin's task.\n            String variantName = variant.name.capitalize()\n\n                Task moduleProjectTask = moduleProject.tasks.named(\"assembleAar$variantName\").get()\n                assert(moduleProjectTask != null)\n                Task pluginProjectTask = pluginProject.tasks.named(\"assembleAar$variantName\").get()\n                assert(pluginProjectTask != null)\n                moduleProjectTask.dependsOn(pluginProjectTask)\n        }\n    }\n}\n\n".encode('utf-8')),
    ('plugin-deps', "        private fun configurePluginDependencies(\n            project: Project,\n            pluginObject: Map<String?, Any?>\n        ) {\n            val pluginName: String =\n                requireNotNull(pluginObject[\"name\"] as? String) {\n                    \"Missing valid \\\"name\\\" property for plugin object: $pluginObject\"\n                }\n            val pluginProject: Project = project.rootProject.findProject(\":$pluginName\") ?: return\n\n            getAndroidExtension(project).buildTypes.forEach { buildType ->\n                val flutterBuildMode: String = buildModeFor(buildType)\n                if (flutterBuildMode == \"release\" && (pluginObject[\"dev_dependency\"] as? Boolean == true)) {\n                    // This plugin is a dev dependency will not be included in the\n                    // release build, so no need to add its dependencies.\n                    return@forEach\n                }\n                val dependencies = requireNotNull(pluginObject[\"dependencies\"] as? List<*>)\n                dependencies.forEach innerForEach@{ pluginDependencyName ->\n                    check(pluginDependencyName is String)\n                    if (pluginDependencyName.isEmpty()) {\n                        return@innerForEach\n                    }\n\n                    val dependencyProject =\n                        project.rootProject.findProject(\":$pluginDependencyName\") ?: return@innerForEach\n                    pluginProject.afterEvaluate {\n                        // this.dependencies.add(\"implementation\", dependencyProject)\n                        pluginProject.dependencies.add(\"implementation\", dependencyProject)\n                    }\n                }\n            }\n        }\n".encode('utf-8')),
)

EXPECTED_CODE = {
    'repo-before': "        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n".encode('utf-8'),
    'repo-after': "        if (!esControlledModule(project)) {\n        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n        }\n".encode('utf-8'),
    'tasks-before': "            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n".encode('utf-8'),
    'tasks-after': "            return\n        }\n        if (esControlledModule(projectToAddTasksTo)) {\n            val android = projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)\n            check(android != null) { \"ES_LIBRARY\" }\n            android.libraryVariants.all esLibraryVariant@{\n                val variant = this\n                if (variant.name != \"debug\") {\n                    return@esLibraryVariant\n                }\n                check(variant.flavorName.isEmpty()) { \"ES_FLAVOR\" }\n                check(FlutterPluginUtils.buildModeFor(variant.buildType) == \"debug\") { \"ES_MODE\" }\n                val assembleTask = variant.assembleProvider.get()\n                check(FlutterPluginUtils.shouldConfigureFlutterTask(projectToAddTasksTo, assembleTask)) { \"ES_TASKS\" }\n                addFlutterDeps(variant, flutterPlugin, targetPlatforms)\n            }\n            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n                projectToAddTasksTo,\n                getPluginHandler(projectToAddTasksTo).getPluginList()\n            )\n            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n".encode('utf-8'),
    'init-all-before': "allprojects {\n".encode('utf-8'),
    'init-all-after': "allprojects {\n    if (esEnabled(project)) {\n        esCheckProject(project, false)\n    }\n".encode('utf-8'),
    'init-afterProject-before': "afterProject { project ->\n".encode('utf-8'),
    'init-afterProject-after': "afterProject { project ->\n    if (esEnabled(project)) {\n        esAfterProject(project)\n        return\n    }\n".encode('utf-8'),
    'init-projectsEvaluated-before': "projectsEvaluated {\n".encode('utf-8'),
    'init-projectsEvaluated-after': "projectsEvaluated {\n    if (esEnabled(rootProject)) {\n        esProjectsEvaluated(rootProject)\n        return\n    }\n".encode('utf-8'),
    'init-helpers': "boolean esEnabled(Project p) {\n    def key = 'elitesync.aar-entry'\n    def own = p.extensions.extraProperties\n    def root = p.rootProject\n    def rootOwn = root.extensions.extraProperties\n    boolean present = own.has(key) || p.hasProperty(key)\n    if (!present) {\n        if (rootOwn.has(key) || root.hasProperty(key)) {\n            throw new GradleException('ES_ROOT_MODE')\n        }\n        return false\n    }\n    if (!own.has(key)) {\n        throw new GradleException('ES_MODE_SCOPE')\n    }\n    def raw = own.get(key)\n    if (!(raw instanceof String) || raw != 'module-debug-v1') {\n        throw new GradleException('ES_MODE_SCOPE')\n    }\n    if (!rootOwn.has(key)) {\n        throw new GradleException('ES_ROOT_MODE')\n    }\n    def rootRaw = rootOwn.get(key)\n    if (!(rootRaw instanceof String) || rootRaw != raw) {\n        throw new GradleException('ES_ROOT_MODE')\n    }\n    return true\n}\n\nSet<String> esAllowed() {\n    return [':', ':flutter', ':sample_alpha', ':sample_beta'] as Set\n}\n\nvoid esCheckProject(Project p, boolean evaluated) {\n    if (!esAllowed().contains(p.path) || !esEnabled(p)) {\n        throw new GradleException('ES_PROJECT')\n    }\n    def own = p.extensions.extraProperties\n    def expected = [\n        'is-plugin': 'false',\n        'output-dir': new File(p.rootProject.projectDir, '../../publication').path,\n        'elitesync.sdk-identity': '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313',\n        'elitesync.aar-projects': ':,:flutter,:sample_alpha,:sample_beta'\n    ]\n    expected.each { key, value ->\n        if (!own.has(key) || !(own.get(key) instanceof String) || own.get(key) != value) {\n            throw new GradleException('ES_PROPERTY_SCOPE')\n        }\n    }\n    if (!own.has('buildNumber') || !(own.get('buildNumber') instanceof String) || !(own.get('buildNumber') ==~ /[0-9a-f]{64}/)) {\n        throw new GradleException('ES_ID')\n    }\n    if (!p.rootProject.extensions.extraProperties.has('buildNumber') || p.rootProject.extensions.extraProperties.get('buildNumber') != own.get('buildNumber')) {\n        throw new GradleException('ES_ID')\n    }\n    if (p.gradle.startParameter.taskNames != ['assembleAarDebug']) {\n        throw new GradleException('ES_TASKS')\n    }\n    if (['local-engine-repo', 'local-engine-out', 'local-engine-host-out', 'local-engine-build-mode', 'skipDependencyChecks'].any { p.hasProperty(it) }) {\n        throw new GradleException('ES_BYPASS')\n    }\n    if (evaluated && p.path != ':') {\n        if (!p.hasProperty('android') || !p.android.hasProperty('libraryVariants') || !p.android.productFlavors.isEmpty()) {\n            throw new GradleException('ES_LIBRARY')\n        }\n    }\n}\n\nvoid esAfterProject(Project p) {\n    esCheckProject(p, true)\n    if (p.path == ':') {\n        return\n    }\n    def singles = p.android.publishing.singleVariants\n    if (singles.isEmpty()) {\n        p.android.publishing.singleVariant('debug')\n    } else if (singles.size() != 1 || singles.first().variantName != 'debug') {\n        throw new GradleException('ES_PUBLICATION_VARIANT')\n    }\n}\n\nvoid esPublishDebug(Project p) {\n    esCheckProject(p, true)\n    def debugVariants = p.android.libraryVariants.findAll { it.name == 'debug' && it.flavorName.isEmpty() }\n    def component = p.components.findByName('debug')\n    if (debugVariants.size() != 1 || component == null || !p.publishing.publications.isEmpty() || !p.publishing.repositories.isEmpty()) {\n        throw new GradleException('ES_DEBUG_COMPONENT')\n    }\n    if (p.tasks.findByName('assembleAarDebug') != null) {\n        throw new GradleException('ES_DUPLICATE_TASK')\n    }\n    p.version = p.extensions.extraProperties.get('buildNumber')\n    p.publishing.publications.create('debug', MavenPublication) { pub ->\n        groupId = \"${pub.groupId}\"\n        artifactId = \"${pub.artifactId}_${pub.name}\"\n        version = \"${pub.version}\"\n        from component\n    }\n    p.publishing.repositories.maven {\n        name = 'controlledDebug'\n        url = p.uri(new File(p.extensions.extraProperties.get('output-dir'), 'outputs/repo'))\n    }\n    def publishDebug = p.tasks.named('publishDebugPublicationToControlledDebugRepository')\n    p.tasks.create('assembleAarDebug') {\n        dependsOn(debugVariants.first().assembleProvider)\n        finalizedBy(publishDebug)\n    }\n}\n\nvoid esProjectsEvaluated(Project root) {\n    def actual = ([root.path] + root.subprojects.collect { it.path }) as Set\n    if (actual != esAllowed()) {\n        throw new GradleException('ES_TOPOLOGY')\n    }\n    ([root] + root.subprojects.toList()).each { esCheckProject(it, true) }\n    Project module = root.findProject(':flutter')\n    if (module == null) {\n        throw new GradleException('ES_MODULE')\n    }\n    def participants = [module, root.findProject(':sample_alpha'), root.findProject(':sample_beta')]\n    if (participants.any { it == null }) {\n        throw new GradleException('ES_PLUGIN')\n    }\n    participants.each { esPublishDebug(it) }\n    def moduleDebug = module.tasks.named('assembleAarDebug').get()\n    participants.findAll { it.path != ':flutter' }.each { plugin ->\n        moduleDebug.dependsOn(plugin.tasks.named('assembleAarDebug'))\n    }\n}\n".encode('utf-8'),
    'apply-helper': "    private fun esControlledModule(p: Project): Boolean {\n        val key = \"elitesync.aar-entry\"\n        val own = p.extensions.extraProperties\n        val root = p.rootProject\n        val rootOwn = root.extensions.extraProperties\n        val present = own.has(key) || p.hasProperty(key)\n        if (!present) {\n            check(!rootOwn.has(key) && !root.hasProperty(key)) { \"ES_ROOT_MODE\" }\n            return false\n        }\n        check(own.has(key)) { \"ES_SCOPE\" }\n        val raw = own.get(key)\n        check(raw is String && raw == \"module-debug-v1\") { \"ES_MODE\" }\n        check(rootOwn.has(key)) { \"ES_ROOT_SCOPE\" }\n        val rootRaw = rootOwn.get(key)\n        check(rootRaw is String && rootRaw == raw) { \"ES_ROOT_MODE\" }\n        check(p.path == \":flutter\") { \"ES_PROJECT\" }\n        check(!FlutterPluginUtils.isFlutterAppProject(p)) { \"ES_APP\" }\n        val android = p.extensions.findByType(LibraryExtension::class.java)\n        check(android != null && android.productFlavors.isEmpty()) { \"ES_LIBRARY\" }\n        check(p.gradle.startParameter.taskNames == listOf(\"assembleAarDebug\")) { \"ES_TASKS\" }\n        val values = linkedMapOf(\n            \"is-plugin\" to \"false\",\n            \"output-dir\" to File(root.projectDir, \"../../publication\").path,\n            \"elitesync.sdk-identity\" to \"1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313\",\n            \"elitesync.aar-projects\" to \":,:flutter,:sample_alpha,:sample_beta\"\n        )\n        values.forEach { (name, value) ->\n            check(own.has(name)) { \"ES_SCOPE\" }\n            check(own.get(name) == value) { \"ES_PROPERTY\" }\n        }\n        check(own.has(\"buildNumber\")) { \"ES_SCOPE\" }\n        val id = own.get(\"buildNumber\")\n        check(id is String && Regex(\"[0-9a-f]{64}\").matches(id)) { \"ES_ID\" }\n        check(rootOwn.has(\"buildNumber\")) { \"ES_ROOT_SCOPE\" }\n        check(rootOwn.get(\"buildNumber\") == id) { \"ES_ID\" }\n        listOf(\"local-engine-repo\", \"local-engine-out\", \"local-engine-host-out\", \"local-engine-build-mode\").forEach {\n            check(!p.hasProperty(it)) { \"ES_LOCAL_ENGINE\" }\n        }\n        check(!p.hasProperty(\"skipDependencyChecks\")) { \"ES_SKIP\" }\n        return true\n    }\n".encode('utf-8'),
    'preflight-before': "        this.project = project\n".encode('utf-8'),
    'preflight-after': "        this.project = project\n        esControlledModule(project)\n".encode('utf-8'),
}

EXPECTED_DIGESTS = (
    ('tasks-full', 'B89C513B5803A734D6DC8F1574EED66F9BC173787D13A6D88F5604833F9CBEEE'),
    ('repo-block', '4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534'),
    ('init-full', '5252CD23EDFD3F02AB1E43875F2F0BAE286589A035475D092A87723E02524FCC'),
    ('plugin-deps', '5B7712D84D82BDCE1BB071419E6BAEFE134754C80B62E3C8BAE1005058E4C33F'),
)

EXPECTED_SCRATCH = {
    'repo-block': "        if (!esControlledModule(project)) {\n        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n        }\n".encode('utf-8'),
    'tasks-full': "    private fun addFlutterTasks(projectToAddTasksTo: Project) {\n        if (projectToAddTasksTo.state.failure != null) {\n            return\n        }\n\n        FlutterPluginUtils.addTaskForJavaVersion(projectToAddTasksTo)\n        FlutterPluginUtils.addTaskForKGPVersion(projectToAddTasksTo)\n        if (FlutterPluginUtils.isFlutterAppProject(projectToAddTasksTo)) {\n            FlutterPluginUtils.addTaskForPrintBuildVariants(projectToAddTasksTo)\n            FlutterPluginUtils.addTasksForOutputsAppLinkSettings(projectToAddTasksTo)\n        }\n\n        val targetPlatforms: List<String> =\n            FlutterPluginUtils.getTargetPlatforms(projectToAddTasksTo)\n\n        val flutterPlugin = this\n\n        if (FlutterPluginUtils.isFlutterAppProject(projectToAddTasksTo)) {\n            // TODO(gmackall): I think this can be BaseExtension, with findByType.\n            val android: AbstractAppExtension =\n                projectToAddTasksTo.extensions.findByName(\"android\") as AbstractAppExtension\n            android.applicationVariants.configureEach {\n                val variant = this\n                val assembleTask = variant.assembleProvider.get()\n                if (!FlutterPluginUtils.shouldConfigureFlutterTask(\n                        projectToAddTasksTo,\n                        assembleTask\n                    )\n                ) {\n                    return@configureEach\n                }\n                val copyFlutterAssetsTask: Task =\n                    addFlutterDeps(variant, flutterPlugin, targetPlatforms)\n\n                // TODO(gmackall): Migrate to AGPs variant api.\n                //    https://github.com/flutter/flutter/issues/166550\n                @Suppress(\"DEPRECATION\")\n                val variantOutput: com.android.build.gradle.api.BaseVariantOutput = variant.outputs.first()\n                val processResources: ProcessAndroidResources =\n                    try {\n                        variantOutput.processResourcesProvider.get()\n                    } catch (e: UnknownTaskException) {\n                        // TODO(gmackall): Migrate to AGPs variant api.\n                        //    https://github.com/flutter/flutter/issues/166550\n                        @Suppress(\"DEPRECATION\")\n                        variantOutput.processResources\n                    }\n                processResources.dependsOn(copyFlutterAssetsTask)\n\n                // Copy the output APKs into a known location, so `flutter run` or `flutter build apk`\n                // can discover them. By default, this is `<app-dir>/build/app/outputs/flutter-apk/<filename>.apk`.\n                //\n                // The filename consists of `app<-abi>?<-flavor-name>?-<build-mode>.apk`.\n                // Where:\n                //   * `abi` can be `armeabi-v7a|arm64-v8a|x86_64` only if the flag `split-per-abi` is set.\n                //   * `flavor-name` is the flavor used to build the app in lower case if the assemble task is called.\n                //   * `build-mode` can be `release|debug|profile`.\n                variant.outputs.forEach { output ->\n                    assembleTask.doLast {\n                        // TODO(gmackall): Migrate to AGPs variant api.\n                        //    https://github.com/flutter/flutter/issues/166550\n                        @Suppress(\"DEPRECATION\")\n                        output as com.android.build.gradle.api.ApkVariantOutput\n                        val packageApplicationProvider: PackageAndroidArtifact =\n                            variant.packageApplicationProvider.get()\n                        val outputDirectory: Directory =\n                            packageApplicationProvider.outputDirectory.get()\n                        val outputDirectoryStr: String = outputDirectory.toString()\n                        var filename = \"app\"\n\n                        // TODO(gmackall): Migrate to AGPs variant api.\n                        //    https://github.com/flutter/flutter/issues/166550\n                        @Suppress(\"DEPRECATION\")\n                        val abi = output.getFilter(com.android.build.VariantOutput.FilterType.ABI)\n                        if (abi != null && abi.isNotEmpty()) {\n                            filename += \"-$abi\"\n                        }\n                        if (variant.flavorName != null && variant.flavorName.isNotEmpty()) {\n                            filename += \"-${FlutterPluginUtils.lowercase(variant.flavorName)}\"\n                        }\n                        filename += \"-${FlutterPluginUtils.buildModeFor(variant.buildType)}\"\n                        projectToAddTasksTo.copy {\n                            from(File(\"$outputDirectoryStr/${output.outputFileName}\"))\n                            into(projectToAddTasksTo.layout.buildDirectory.dir(\"outputs/flutter-apk\"))\n                            rename { \"$filename.apk\" }\n                        }\n                    }\n                }\n            }\n            // Copy the native assets created by build.dart and placed here by flutter assemble.\n            // This path is not flavor specific and must only be added once.\n            // If support for flavors is added to native assets, then they must only be added\n            // once per flavor; see https://github.com/dart-lang/native/issues/1359.\n            val nativeAssetsDir =\n                \"${projectToAddTasksTo.layout.buildDirectory.get()}/../native_assets/android/jniLibs/lib/\"\n            android.sourceSets\n                .getByName(\"main\")\n                .jniLibs\n                .srcDir(nativeAssetsDir)\n            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n                projectToAddTasksTo,\n                getPluginHandler(projectToAddTasksTo).getPluginList()\n            )\n            return\n        }\n        if (esControlledModule(projectToAddTasksTo)) {\n            val android = projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)\n            check(android != null) { \"ES_LIBRARY\" }\n            android.libraryVariants.all esLibraryVariant@{\n                val variant = this\n                if (variant.name != \"debug\") {\n                    return@esLibraryVariant\n                }\n                check(variant.flavorName.isEmpty()) { \"ES_FLAVOR\" }\n                check(FlutterPluginUtils.buildModeFor(variant.buildType) == \"debug\") { \"ES_MODE\" }\n                val assembleTask = variant.assembleProvider.get()\n                check(FlutterPluginUtils.shouldConfigureFlutterTask(projectToAddTasksTo, assembleTask)) { \"ES_TASKS\" }\n                addFlutterDeps(variant, flutterPlugin, targetPlatforms)\n            }\n            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n                projectToAddTasksTo,\n                getPluginHandler(projectToAddTasksTo).getPluginList()\n            )\n            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n            if (projectToAddTasksTo.rootProject.hasProperty(\"flutter.hostAppProjectName\")) {\n                projectToAddTasksTo.rootProject.property(\n                    \"flutter.hostAppProjectName\"\n                ) as? String\n            } else {\n                \"app\"\n            }\n        val appProject: Project? =\n            projectToAddTasksTo.rootProject.findProject(\":$hostAppProjectName\")\n        check(appProject != null) {\n            \"Project :$hostAppProjectName doesn't exist. To customize the host app project name, set `flutter.hostAppProjectName=<project-name>` in gradle.properties.\"\n        }\n        // Wait for the host app project configuration.\n        appProject.afterEvaluate {\n            val androidLibraryExtension =\n                projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)\n            check(androidLibraryExtension != null)\n            androidLibraryExtension.libraryVariants.all libraryVariantAll@{\n                val libraryVariant = this\n                var copyFlutterAssetsTask: Task? = null\n                val androidAppExtension =\n                    appProject.extensions.findByName(\"android\") as? AbstractAppExtension\n                check(androidAppExtension != null)\n                androidAppExtension.applicationVariants.all applicationVariantAll@{\n                    val appProjectVariant = this\n                    val appAssembleTask: Task = appProjectVariant.assembleProvider.get()\n                    if (!FlutterPluginUtils.shouldConfigureFlutterTask(project, appAssembleTask)) {\n                        return@applicationVariantAll\n                    }\n\n                    // Find a compatible application variant in the host app.\n                    //\n                    // For example, consider a host app that defines the following variants:\n                    // | ----------------- | ----------------------------- |\n                    // |   Build Variant   |   Flutter Equivalent Variant  |\n                    // | ----------------- | ----------------------------- |\n                    // |   freeRelease     |   release                     |\n                    // |   freeDebug       |   debug                       |\n                    // |   freeDevelop     |   debug                       |\n                    // |   profile         |   profile                     |\n                    // | ----------------- | ----------------------------- |\n                    //\n                    // This mapping is based on the following rules:\n                    // 1. If the host app build variant name is `profile` then the equivalent\n                    //    Flutter variant is `profile`.\n                    // 2. If the host app build variant is debuggable\n                    //    (e.g. `buildType.debuggable = true`), then the equivalent Flutter\n                    //    variant is `debug`.\n                    // 3. Otherwise, the equivalent Flutter variant is `release`.\n                    val variantBuildMode: String =\n                        FlutterPluginUtils.buildModeFor(libraryVariant.buildType)\n                    if (FlutterPluginUtils.buildModeFor(appProjectVariant.buildType) != variantBuildMode) {\n                        return@applicationVariantAll\n                    }\n                    copyFlutterAssetsTask = copyFlutterAssetsTask ?: addFlutterDeps(\n                        libraryVariant,\n                        flutterPlugin,\n                        targetPlatforms\n                    )\n                    // TODO(gmackall): Migrate to AGPs variant api.\n                    //    https://github.com/flutter/flutter/issues/166550\n                    val mergeAssets =\n                        projectToAddTasksTo\n                            .tasks\n                            .findByPath(\":$hostAppProjectName:merge${FlutterPluginUtils.capitalize(appProjectVariant.name)}Assets\")\n                    check(mergeAssets != null)\n                    mergeAssets.dependsOn(copyFlutterAssetsTask)\n                }\n            }\n        }\n        getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n        FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n            projectToAddTasksTo,\n            getPluginHandler(projectToAddTasksTo).getPluginList()\n        )\n    }\n\n".encode('utf-8'),
    'init-full': "// This script is used to initialize the build in a module or plugin project.\n// During this phase, the script applies the Maven plugin and configures the\n// destination of the local repository.\n// The local repository will contain the AAR and POM files.\n\nimport java.nio.file.Paths\n\n\nvoid configureProject(Project project, String outputDir) {\n    if (!project.hasProperty(\"android\")) {\n        throw new GradleException(\"Android property not found.\")\n    }\n    if (!project.android.hasProperty(\"libraryVariants\")) {\n        throw new GradleException(\"Can't generate AAR on a non Android library project.\")\n    }\n\n    // Snapshot versions include the timestamp in the artifact name.\n    // Therefore, remove the snapshot part, so new runs of `flutter build aar` overrides existing artifacts.\n    // This version isn't relevant in Flutter since the pub version is used\n    // to resolve dependencies.\n    project.version = project.version.replace(\"-SNAPSHOT\", \"\")\n\n    if (project.hasProperty(\"buildNumber\")) {\n        project.version = project.property(\"buildNumber\")\n    }\n\n    project.components.forEach { component ->\n        if (component.name != \"all\") {\n            addAarTask(project, component)\n        }\n    }\n\n    project.publishing {\n        repositories {\n            maven {\n                url = uri(\"file://${outputDir}/outputs/repo\")\n            }\n        }\n    }\n\n    if (!project.property(\"is-plugin\").toBoolean()) {\n        return\n    }\n\n    String storageUrl = System.getenv('FLUTTER_STORAGE_BASE_URL') ?: \"https://storage.googleapis.com\"\n\n    String engineRealm = Paths.get(getFlutterRoot(project), \"bin\", \"cache\", \"engine.realm\")\n        .toFile().text.trim()\n    if (engineRealm) {\n        engineRealm += \"/\"\n    }\n\n    // This is a Flutter plugin project. Plugin projects don't apply the Flutter Gradle plugin,\n    // as a result, add the dependency on the embedding.\n    project.repositories {\n        maven {\n            url \"$storageUrl/${engineRealm}download.flutter.io\"\n        }\n    }\n    String engineVersion = Paths.get(getFlutterRoot(project), \"bin\", \"cache\", \"engine.stamp\")\n        .toFile().text.trim()\n    project.dependencies {\n        // Add the embedding dependency.\n        compileOnly (\"io.flutter:flutter_embedding_release:1.0.0-$engineVersion\") {\n            // We only need to expose io.flutter.plugin.*\n            // No need for the embedding transitive dependencies.\n            transitive = false\n        }\n    }\n}\n\nvoid configurePlugin(Project project, String outputDir) {\n    if (!project.hasProperty(\"android\")) {\n        // A plugin doesn't support the Android platform when this property isn't defined in the plugin.\n        return\n    }\n    configureProject(project, outputDir)\n}\n\nstatic String getFlutterRoot(Project project) {\n    if (!project.hasProperty(\"flutter-root\")) {\n        throw new GradleException(\"The `-Pflutter-root` flag must be specified.\")\n    }\n    return project.property(\"flutter-root\")\n}\n\nvoid addAarTask(Project project, component) {\n    String variantName = component.name.capitalize()\n    String taskName = \"assembleAar$variantName\"\n    project.tasks.create(name: taskName) {\n        // This check is required to be able to configure the archives before `publish` runs.\n        if (!project.gradle.startParameter.taskNames.contains(taskName)) {\n            return\n        }\n\n        // Create a default MavenPublication for the variant (except \"all\" since that is used to publish artifacts in the new way)\n        project.publishing.publications.create(component.name, MavenPublication) { pub ->\n            groupId = \"${pub.groupId}\"\n            artifactId = \"${pub.artifactId}_${pub.name}\"\n            version = \"${pub.version}\"\n            from component\n        }\n\n        // Generate the Maven artifacts.\n        finalizedBy \"publish\"\n    }\n}\n\n// maven-publish has to be applied _before_ the project gets evaluated, but some of the code in\n// `configureProject` requires the project to be evaluated. Apply the maven plugin to all projects, but\n// only configure it if it matches the conditions in `projectsEvaluated`\n\nboolean esEnabled(Project p) {\n    def key = 'elitesync.aar-entry'\n    def own = p.extensions.extraProperties\n    def root = p.rootProject\n    def rootOwn = root.extensions.extraProperties\n    boolean present = own.has(key) || p.hasProperty(key)\n    if (!present) {\n        if (rootOwn.has(key) || root.hasProperty(key)) {\n            throw new GradleException('ES_ROOT_MODE')\n        }\n        return false\n    }\n    if (!own.has(key)) {\n        throw new GradleException('ES_MODE_SCOPE')\n    }\n    def raw = own.get(key)\n    if (!(raw instanceof String) || raw != 'module-debug-v1') {\n        throw new GradleException('ES_MODE_SCOPE')\n    }\n    if (!rootOwn.has(key)) {\n        throw new GradleException('ES_ROOT_MODE')\n    }\n    def rootRaw = rootOwn.get(key)\n    if (!(rootRaw instanceof String) || rootRaw != raw) {\n        throw new GradleException('ES_ROOT_MODE')\n    }\n    return true\n}\n\nSet<String> esAllowed() {\n    return [':', ':flutter', ':sample_alpha', ':sample_beta'] as Set\n}\n\nvoid esCheckProject(Project p, boolean evaluated) {\n    if (!esAllowed().contains(p.path) || !esEnabled(p)) {\n        throw new GradleException('ES_PROJECT')\n    }\n    def own = p.extensions.extraProperties\n    def expected = [\n        'is-plugin': 'false',\n        'output-dir': new File(p.rootProject.projectDir, '../../publication').path,\n        'elitesync.sdk-identity': '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313',\n        'elitesync.aar-projects': ':,:flutter,:sample_alpha,:sample_beta'\n    ]\n    expected.each { key, value ->\n        if (!own.has(key) || !(own.get(key) instanceof String) || own.get(key) != value) {\n            throw new GradleException('ES_PROPERTY_SCOPE')\n        }\n    }\n    if (!own.has('buildNumber') || !(own.get('buildNumber') instanceof String) || !(own.get('buildNumber') ==~ /[0-9a-f]{64}/)) {\n        throw new GradleException('ES_ID')\n    }\n    if (!p.rootProject.extensions.extraProperties.has('buildNumber') || p.rootProject.extensions.extraProperties.get('buildNumber') != own.get('buildNumber')) {\n        throw new GradleException('ES_ID')\n    }\n    if (p.gradle.startParameter.taskNames != ['assembleAarDebug']) {\n        throw new GradleException('ES_TASKS')\n    }\n    if (['local-engine-repo', 'local-engine-out', 'local-engine-host-out', 'local-engine-build-mode', 'skipDependencyChecks'].any { p.hasProperty(it) }) {\n        throw new GradleException('ES_BYPASS')\n    }\n    if (evaluated && p.path != ':') {\n        if (!p.hasProperty('android') || !p.android.hasProperty('libraryVariants') || !p.android.productFlavors.isEmpty()) {\n            throw new GradleException('ES_LIBRARY')\n        }\n    }\n}\n\nvoid esAfterProject(Project p) {\n    esCheckProject(p, true)\n    if (p.path == ':') {\n        return\n    }\n    def singles = p.android.publishing.singleVariants\n    if (singles.isEmpty()) {\n        p.android.publishing.singleVariant('debug')\n    } else if (singles.size() != 1 || singles.first().variantName != 'debug') {\n        throw new GradleException('ES_PUBLICATION_VARIANT')\n    }\n}\n\nvoid esPublishDebug(Project p) {\n    esCheckProject(p, true)\n    def debugVariants = p.android.libraryVariants.findAll { it.name == 'debug' && it.flavorName.isEmpty() }\n    def component = p.components.findByName('debug')\n    if (debugVariants.size() != 1 || component == null || !p.publishing.publications.isEmpty() || !p.publishing.repositories.isEmpty()) {\n        throw new GradleException('ES_DEBUG_COMPONENT')\n    }\n    if (p.tasks.findByName('assembleAarDebug') != null) {\n        throw new GradleException('ES_DUPLICATE_TASK')\n    }\n    p.version = p.extensions.extraProperties.get('buildNumber')\n    p.publishing.publications.create('debug', MavenPublication) { pub ->\n        groupId = \"${pub.groupId}\"\n        artifactId = \"${pub.artifactId}_${pub.name}\"\n        version = \"${pub.version}\"\n        from component\n    }\n    p.publishing.repositories.maven {\n        name = 'controlledDebug'\n        url = p.uri(new File(p.extensions.extraProperties.get('output-dir'), 'outputs/repo'))\n    }\n    def publishDebug = p.tasks.named('publishDebugPublicationToControlledDebugRepository')\n    p.tasks.create('assembleAarDebug') {\n        dependsOn(debugVariants.first().assembleProvider)\n        finalizedBy(publishDebug)\n    }\n}\n\nvoid esProjectsEvaluated(Project root) {\n    def actual = ([root.path] + root.subprojects.collect { it.path }) as Set\n    if (actual != esAllowed()) {\n        throw new GradleException('ES_TOPOLOGY')\n    }\n    ([root] + root.subprojects.toList()).each { esCheckProject(it, true) }\n    Project module = root.findProject(':flutter')\n    if (module == null) {\n        throw new GradleException('ES_MODULE')\n    }\n    def participants = [module, root.findProject(':sample_alpha'), root.findProject(':sample_beta')]\n    if (participants.any { it == null }) {\n        throw new GradleException('ES_PLUGIN')\n    }\n    participants.each { esPublishDebug(it) }\n    def moduleDebug = module.tasks.named('assembleAarDebug').get()\n    participants.findAll { it.path != ':flutter' }.each { plugin ->\n        moduleDebug.dependsOn(plugin.tasks.named('assembleAarDebug'))\n    }\n}\nallprojects {\n    if (esEnabled(project)) {\n        esCheckProject(project, false)\n    }\n   apply plugin: \"maven-publish\"\n}\n\nafterProject { project ->\n    if (esEnabled(project)) {\n        esAfterProject(project)\n        return\n    }\n    // Exit early if either:\n    // 1. The project doesn't have the Android Gradle plugin applied.\n    // 2. The project has already defined which variants to publish (trying to re-define which\n    //    variants to publish will result in an error).\n    if (!project.hasProperty(\"android\")) {\n        return\n    }\n    if (project.android.publishing.singleVariants.size() != 0) {\n        return\n    }\n\n    Closure addSingleVariants = {buildType ->\n        if (!project.android.productFlavors.isEmpty()) {\n            project.android.productFlavors.all{productFlavor ->\n                project.android.publishing.singleVariant(\n                        productFlavor.name + buildType.name.capitalize()\n                ) {\n                    withSourcesJar()\n                    withJavadocJar()\n                }\n            }\n        } else {\n            project.android.publishing.singleVariant(buildType.name) {\n                withSourcesJar()\n                withJavadocJar()\n            }\n        }\n    }\n\n    project.android.buildTypes.all(addSingleVariants)\n}\n\nprojectsEvaluated {\n    if (esEnabled(rootProject)) {\n        esProjectsEvaluated(rootProject)\n        return\n    }\n    assert rootProject.hasProperty(\"is-plugin\")\n    if (rootProject.property(\"is-plugin\").toBoolean()) {\n        assert rootProject.hasProperty(\"output-dir\")\n        // In plugin projects, the root project is the plugin.\n        configureProject(rootProject, rootProject.property(\"output-dir\"))\n        return\n    }\n    if (rootProject.name == \"gradle\") {\n        // Skip the \"gradle\" project, we are looking only for the \"android_generated\" project.\n        return\n    }\n    // The module project is the `:flutter` subproject.\n    Project moduleProject = rootProject.subprojects.find { it.name == \"flutter\" }\n    assert moduleProject != null\n    assert moduleProject.hasProperty(\"output-dir\")\n    configureProject(moduleProject, moduleProject.property(\"output-dir\"))\n\n    // Gets the plugin subprojects.\n    Set<Project> modulePlugins = rootProject.subprojects.findAll {\n        it.name != \"flutter\" && it.name != \"app\"\n    }\n    // When a module is built as a Maven artifacts, plugins must also be built this way\n    // because the module POM's file will include a dependency on the plugin Maven artifact.\n    // This is due to the Android Gradle Plugin expecting all library subprojects to be published\n    // as Maven artifacts.\n    modulePlugins.each { pluginProject ->\n        configurePlugin(pluginProject, moduleProject.property(\"output-dir\"))\n        moduleProject.android.libraryVariants.all { variant ->\n            // Configure the `assembleAar<variantName>` task for each plugin's projects and make\n            // the module's equivalent task depend on the plugin's task.\n            String variantName = variant.name.capitalize()\n\n                Task moduleProjectTask = moduleProject.tasks.named(\"assembleAar$variantName\").get()\n                assert(moduleProjectTask != null)\n                Task pluginProjectTask = pluginProject.tasks.named(\"assembleAar$variantName\").get()\n                assert(pluginProjectTask != null)\n                moduleProjectTask.dependsOn(pluginProjectTask)\n        }\n    }\n}\n\n".encode('utf-8'),
}

# Fixture bytes above come from the accepted document and numbered original
# receipts; expected complete scratch bytes use explicit reviewed line partitions.
# No expected source bytes or values are obtained from production constants.
_spec = importlib.util.spec_from_file_location('aar_entry_materials', r'D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py')
_module = importlib.util.module_from_spec(_spec)
sys.modules['aar_entry_materials'] = _module
_spec.loader.exec_module(_module)
M = _module
F = '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'
I = 'B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2'
PHASE = 'BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS'
PROJECTS = (':', ':flutter', ':sample_alpha', ':sample_beta')


def fixture(input_id='a' * 64):
    values = (
        ('elitesync.aar-entry', 'module-debug-v1'), ('is-plugin', 'false'),
        ('output-dir', 'publication'), ('buildNumber', input_id),
        ('elitesync.sdk-identity', F), ('elitesync.aar-projects', ':,:flutter,:sample_alpha,:sample_beta'),
    )
    return dict(mode='module-debug-v1', flutter_identity=F, init_identity=I,
                input_id=input_id, projects=PROJECTS,
                properties=tuple((p, values) for p in PROJECTS),
                tasks=('assembleAarDebug',), sdk_root='materials/flutter_sdk',
                maven_root='materials/maven', publication_root='publication',
                repositories_mode='FAIL_ON_PROJECT_REPOS')


def expected(input_id):
    definitions = (
        ('repo-block', 'REPLACE_UNIQUE', 'repo-before', 'repo-after'),
        ('tasks-full', 'REPLACE_UNIQUE', 'tasks-before', 'tasks-after'),
        ('init-full', 'INSERT_BEFORE_UNIQUE', 'init-all-before', 'init-helpers'),
        ('init-full', 'REPLACE_UNIQUE', 'init-all-before', 'init-all-after'),
        ('init-full', 'REPLACE_UNIQUE', 'init-afterProject-before', 'init-afterProject-after'),
        ('init-full', 'REPLACE_UNIQUE', 'init-projectsEvaluated-before', 'init-projectsEvaluated-after'),
    )
    digest_table = dict(EXPECTED_DIGESTS)
    ops = tuple(M.PatchOperation(n, target, kind, digest_table[target], before,
                               EXPECTED_CODE[before], EXPECTED_CODE[after])
                for n, (target, kind, before, after) in enumerate(definitions))
    attachments = (
        M.Attachment('apply-helper', 'FLUTTER_PLUGIN_CLASS_MEMBER', F, b'', EXPECTED_CODE['apply-helper'], False),
        M.Attachment('apply-preflight-proposal', 'APPLY_AFTER_THIS_PROJECT_ASSIGNMENT', F, EXPECTED_CODE['preflight-before'], EXPECTED_CODE['preflight-after'], False),
    )
    # Independent field expectations, not fixture() or production helpers.
    logical_entries = (('elitesync.aar-entry', 'module-debug-v1'), ('is-plugin', 'false'),
                       ('output-dir', 'publication'), ('buildNumber', input_id),
                       ('elitesync.sdk-identity', F), ('elitesync.aar-projects', ':,:flutter,:sample_alpha,:sample_beta'))
    recipes = (M.LiteralString('elitesync.aar-entry', 'module-debug-v1'),
               M.LiteralString('is-plugin', 'false'),
               M.RootProjectDirFilePath('output-dir', 'ROOT_PROJECT_DIR', ('..', '..', 'publication'), 'FILE_PATH', 'BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS'),
               M.LiteralString('buildNumber', input_id), M.LiteralString('elitesync.sdk-identity', F),
               M.LiteralString('elitesync.aar-projects', ':,:flutter,:sample_alpha,:sample_beta'))
    invocation = M.InvocationContract(
        mode='module-debug-v1', requested_tasks=('assembleAarDebug',),
        projects=(':', ':flutter', ':sample_alpha', ':sample_beta'),
        logical_properties=((':', logical_entries), (':flutter', logical_entries), (':sample_alpha', logical_entries), (':sample_beta', logical_entries)),
        property_installation=(M.InstallationGroup(':', 'LOCAL_EXTRA', recipes), M.InstallationGroup(':flutter', 'LOCAL_EXTRA', recipes), M.InstallationGroup(':sample_alpha', 'LOCAL_EXTRA', recipes), M.InstallationGroup(':sample_beta', 'LOCAL_EXTRA', recipes)),
        property_install_phase='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS',
        sdk_root='materials/flutter_sdk', maven_root='materials/maven', publication_root='publication',
        publication_repository='publication/outputs/repo', repositories_mode='FAIL_ON_PROJECT_REPOS',
        module_project=':flutter', module_variant='debug', plugin_projects=(':sample_alpha', ':sample_beta'),
        plugin_variants=('debug', 'debug'),
        aar_task_edges=((':flutter:assembleAarDebug', ':sample_alpha:assembleAarDebug'), (':flutter:assembleAarDebug', ':sample_beta:assembleAarDebug')),
        publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository', ':sample_alpha:publishDebugPublicationToControlledDebugRepository', ':sample_beta:publishDebugPublicationToControlledDebugRepository'),
        sdk_identity=F, init_identity=I, input_id=input_id, runtime_ready=False,
    )
    return M.EntryMaterials(ops, attachments, invocation)


def scratch_apply(operations):
    scratch = dict(ORIGINALS)
    for op in operations:
        before = scratch[op.target]
        if before.count(op.before) != 1:
            raise AssertionError('scratch anchor is not unique')
        if op.kind == 'REPLACE_UNIQUE':
            scratch[op.target] = before.replace(op.before, op.after, 1)
        elif op.kind == 'INSERT_BEFORE_UNIQUE':
            scratch[op.target] = before.replace(op.before, op.after + op.before, 1)
        else:
            raise AssertionError('unknown operation')
    return scratch


class EntryMaterialsTests(unittest.TestCase):
    def reject(self, config=None, materials=ORIGINALS, error=ValueError):
        if config is None:
            config = fixture()
        with self.assertRaisesRegex(error, '^TYPE$' if error is TypeError else '^CONTRACT$'):
            M.adapt_module_debug_entry(materials=materials, config=config)

    def test_complete_p1_p2(self):
        a = M.adapt_module_debug_entry(materials=ORIGINALS, config=fixture('a' * 64))
        b = M.adapt_module_debug_entry(materials=ORIGINALS, config=fixture('b' * 64))
        self.assertEqual(a, expected('a' * 64))
        self.assertEqual(b, expected('b' * 64))
        self.assertEqual(a.operations, b.operations)
        self.assertEqual(a.attachments, b.attachments)
        self.assertNotEqual(a.invocation, b.invocation)

    def test_complete_scratch(self):
        for input_id in ('a' * 64, 'b' * 64):
            result = M.adapt_module_debug_entry(materials=ORIGINALS, config=fixture(input_id))
            actual = scratch_apply(result.operations)
            for target in ('repo-block', 'tasks-full', 'init-full'):
                self.assertEqual(actual[target], EXPECTED_SCRATCH[target])
            self.assertEqual(actual['plugin-deps'], dict(ORIGINALS)['plugin-deps'])
            adapted = tuple((key, actual[key]) for key, _ in ORIGINALS)
            self.reject(materials=adapted)

    def test_installation_logical_and_dynamic_id(self):
        for id_value in ('0' * 64, '0123456789abcdef' * 4):
            result = M.adapt_module_debug_entry(materials=ORIGINALS, config=fixture(id_value))
            self.assertEqual(result, expected(id_value))
            for group in result.invocation.property_installation:
                self.assertEqual(group.scope, 'LOCAL_EXTRA')
                self.assertEqual(group.recipes[2], M.RootProjectDirFilePath('output-dir', 'ROOT_PROJECT_DIR', ('..', '..', 'publication'), 'FILE_PATH', PHASE))
                self.assertEqual(group.recipes[3].value, id_value)
            self.assertEqual(dict(result.invocation.logical_properties[0][1])['output-dir'], 'publication')

    def test_frozen_detached_deterministic(self):
        config = fixture()
        result = M.adapt_module_debug_entry(materials=ORIGINALS, config=config)
        self.assertEqual(result, M.adapt_module_debug_entry(materials=ORIGINALS, config=config))
        config['input_id'] = 'b' * 64
        config['properties'] = ()
        self.assertEqual(result, expected('a' * 64))
        with self.assertRaises(FrozenInstanceError):
            result.invocation.input_id = 'b' * 64
        with self.assertRaises(FrozenInstanceError):
            result.operations[0].after = b'x'
        with self.assertRaises(FrozenInstanceError):
            result.invocation.property_installation[0].recipes[2].base = 'other'
        for attachment in result.attachments:
            self.assertIs(attachment.executable_patch, False)

    def test_top_and_nested_types(self):
        class TupleSubclass(tuple):
            pass
        class DictSubclass(dict):
            pass
        class StrSubclass(str):
            pass
        class BytesSubclass(bytes):
            pass
        class Bomb:
            def __str__(self):
                raise AssertionError('custom object touched')
            def __iter__(self):
                raise AssertionError('custom object touched')
        for materials in ([], None, True, TupleSubclass(ORIGINALS), Bomb()):
            self.reject(materials=materials, error=TypeError)
        for config in ([], True, DictSubclass(fixture()), Bomb()):
            self.reject(config=config, error=TypeError)
        for key, value in (('mode', None), ('mode', False), ('mode', StrSubclass('module-debug-v1')), ('input_id', Bomb()), ('projects', TupleSubclass(PROJECTS)), ('tasks', ['assembleAarDebug']), ('properties', [])):
            config = fixture()
            config[key] = value
            self.reject(config=config, error=TypeError)
        for pair in ([ORIGINALS[0][0], ORIGINALS[0][1]], (StrSubclass('tasks-full'), ORIGINALS[0][1]), ('tasks-full', BytesSubclass(ORIGINALS[0][1])), ('tasks-full', bytearray(ORIGINALS[0][1]))):
            self.reject(materials=(pair,) + ORIGINALS[1:], error=TypeError)
        config = fixture()
        config[False] = 'bad'
        self.reject(config=config, error=TypeError)

    def test_material_integrity_order_and_anchors(self):
        for materials in (ORIGINALS[:-1], ORIGINALS + ORIGINALS[:1], tuple(reversed(ORIGINALS)), (('bad', ORIGINALS[0][1]),) + ORIGINALS[1:], ((ORIGINALS[0][0],),) + ORIGINALS[1:]):
            self.reject(materials=materials)
        base = dict(ORIGINALS)
        for content in (base['tasks-full'] + b'x', base['tasks-full'].replace(EXPECTED_CODE['tasks-before'], b''), base['tasks-full'] + EXPECTED_CODE['tasks-before'], EXPECTED_CODE['tasks-after'], base['tasks-full'].replace(b'return', b'bad', 1), b'x' * 262145):
            self.reject(materials=(('tasks-full', content),) + ORIGINALS[1:])
        for key in ('repo-block', 'init-full', 'plugin-deps'):
            self.reject(materials=tuple((k, v + b'x' if k == key else v) for k, v in ORIGINALS))

    def test_config_keys_fixed_values_and_paths(self):
        for key in tuple(fixture()):
            config = fixture()
            del config[key]
            self.reject(config=config)
        for key in ('env', 'executable', 'recipe', 'fragments', 'flavor', 'local-engine-repo', 'skipDependencyChecks'):
            config = fixture()
            config[key] = 'bad'
            self.reject(config=config)
        for key, values in (('mode', ('', 'bad')), ('flutter_identity', ('0' * 64,)), ('init_identity', ('0' * 64,)), ('sdk_root', ('/tmp/sdk', '../sdk', 'C:/sdk', '\\\\host\\sdk')), ('maven_root', ('https://remote', 'other')), ('publication_root', ('../publication', 'publication/outputs/repo', '/publication')), ('repositories_mode', ('PREFER_SETTINGS', ''))):
            for value in values:
                config = fixture()
                config[key] = value
                self.reject(config=config)

    def test_ids_and_bindings(self):
        for id_value in ('', 'a' * 63, 'a' * 65, 'A' * 64, 'g' * 64, 'ａ' * 64, 'a' * 63 + '\n'):
            config = fixture(id_value)
            self.reject(config=config)
        config = fixture('b' * 64)
        config['properties'] = fixture('a' * 64)['properties']
        self.reject(config=config)
        for index in range(4):
            config = fixture('b' * 64)
            groups = list(config['properties'])
            path, values = groups[index]
            values = tuple((k, 'a' * 64 if k == 'buildNumber' else v) for k, v in values)
            groups[index] = (path, values)
            config['properties'] = tuple(groups)
            self.reject(config=config)

    def test_projects_and_tasks(self):
        for projects in ((':', ':app', ':sample_alpha', ':sample_beta'), PROJECTS + (':sample_alpha:child',), tuple(reversed(PROJECTS)), PROJECTS[:-1], (':', ':wrong', ':sample_alpha', ':sample_beta')):
            config = fixture()
            config['projects'] = projects
            self.reject(config=config)
        for tasks in ((), ('assembleAarRelease',), ('assembleAarProfile',), (':flutter:assembleAarDebug',), ('assembleAarDebug', 'publish')):
            config = fixture()
            config['tasks'] = tasks
            self.reject(config=config)

    def test_property_schema_scope_and_types(self):
        config = fixture()
        for groups in (config['properties'][:1], tuple(reversed(config['properties'])), config['properties'] + config['properties'][:1]):
            changed = fixture()
            changed['properties'] = groups
            self.reject(config=changed)
        path, original_entries = fixture()['properties'][1]
        variants = (original_entries[:-1], tuple(reversed(original_entries)), original_entries + original_entries[:1], (('extra', 'bad'),) + original_entries[1:])
        for entries in variants:
            changed = fixture()
            changed['properties'] = changed['properties'][:1] + ((path, entries),) + changed['properties'][2:]
            self.reject(config=changed)
        for position, values in ((0, ('bad', '', None, False)), (1, ('true', '', False)), (2, ('B/module/.android/../../publication', '/publication')), (4, ('0' * 64,)), (5, (':,:flutter,:app',))):
            for value in values:
                changed = fixture()
                entries = list(original_entries)
                entries[position] = (entries[position][0], value)
                changed['properties'] = changed['properties'][:1] + ((path, tuple(entries)),) + changed['properties'][2:]
                self.reject(config=changed, error=TypeError if type(value) is not str else ValueError)
        for group in ([path, original_entries], (None, original_entries), (path, list(original_entries)), (path, ((None, 'x'),) + original_entries[1:]), (path, ([original_entries[0][0], original_entries[0][1]],) + original_entries[1:])):
            changed = fixture()
            changed['properties'] = changed['properties'][:1] + (group,) + changed['properties'][2:]
            self.reject(config=changed, error=TypeError)

    def test_mode_matrix_is_source_only(self):
        result = M.adapt_module_debug_entry(materials=ORIGINALS, config=fixture())
        self.assertEqual(result.attachments[0].after, EXPECTED_CODE['apply-helper'])
        self.assertEqual(result.operations[2].after, EXPECTED_CODE['init-helpers'])
        for source in (EXPECTED_CODE['apply-helper'], EXPECTED_CODE['init-helpers']):
            self.assertLess(source.index(b'own.has(key)'), source.index(b'own.get(key)'))
            self.assertIn(b'p.hasProperty(key)', source)
            self.assertIn(b'rootOwn.has(key)', source)
            self.assertNotIn(b'?: return false', source)
            self.assertNotIn(b'if (raw == null)', source)

    def test_keyword_only(self):
        with self.assertRaises(TypeError):
            M.adapt_module_debug_entry(ORIGINALS, fixture())
        with self.assertRaises(TypeError):
            M.adapt_module_debug_entry(materials=ORIGINALS, config=fixture(), extra='bad')


if __name__ == '__main__':
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    outcome = unittest.TextTestRunner(verbosity=2).run(suite)
    sys.exit(0 if outcome.wasSuccessful() and outcome.testsRun > 0 else 1)

```

## 附录 B｜M5-29已接受合同完整文字（历史引用）
````text
# APP-M5-29｜AAR适配合同一致性修订候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL2 REVIEW PENDING。M5-28为REJECT AS IMPLEMENTABLE CONTRACT，旧hash及2/2预算保留。本合同替代其四项矛盾：返回typed操作包；Invocation及所有buildNumber绑定动态input_id；逻辑publication只通过File.path recipe安装；mode只有属性不存在才进入legacy，own null拒绝。本文不生成完整SDK文件、不执行转换或安装；编译与运行仍UNKNOWN，M5/隔离构建NOT_READY。

入口 `D:\EliteSync-v10`，main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，执行会话 `01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad`；CURRENT/TASK_CURRENT与明确派发一致。179条入口dirty/untracked保留；唯一新增本plan，不改M5-28、源码/SDK/renderer/authority/旧证据。沿用local-workflow，所有旧预算关闭。

## 证据与材料域

第一轮chunk `990808`：exit0、0.237411秒；四文件各普通非reparse、≤256KiB、总107911 bytes≤1MiB，各一次完整读取/hash，预期全部匹配。wrapper只解析唯一JSON output，不执行保存命令；目标SECTION唯一、重复源行一致且范围完整。主动打印前累计UTF8，末状态前14885 bytes，含末状态低于32KiB，无截断/失败/重试。第一轮1/1关闭；本次没有SDK读取。

| 本地EVIDENCE来源 | bytes | SHA256 |
| --- | ---: | --- |
| APP-M5-28-CONTROLLED-AAR-ENTRY-ADAPTATION-CONTRACT/plan.md | 33736 | 57A2A856780B687E4E582E1DFAC1C71FBE3069D80C51726BEDF66028F2D254FC |
| APP-M5-27-AAR-CONFIGURATION-ENTRY-CLOSURE/m526-original-receipt.txt | 24935 | FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062 |
| 同M5-27目录round-2-original-receipt.txt | 31659 | 8B4657648F3BE8CA1A36E4DFCCED2CFAEA0FAFE18C6BB2B4DCEBD5EFB6B1FE44 |
| 同M5-27目录round-1-original-receipt.txt | 17581 | 9FD10B2C9B46D2578F7BFD32E266248A4C45CEC74140A39A1ED734E5DC1EA8E6 |

归一规则固定：output按LF拆行（只把行分隔CRLF归一LF）；指定SECTION exact唯一；编号行格式为decimal+`: `+正文，仅剥该前缀，不strip缩进或正文尾空格。重复源行须一致，按准确范围逐行升序join LF，最后加一个LF，包括原末尾空行贡献。缺行/多SECTION/不一致直接拒绝。apply摘录已省注释/空行，只是该材料域，不填造完整源码。

冻结输入bytes可直接引用以下唯一来源id/范围与hash；这不是查任意文件的授权。后继纯函数接收这些bytes，不读取来源文件。

| id / SECTION与源行 | 归一片段SHA256 |
| --- | --- |
| tasks-full / m526：SECTION FlutterPlugin.kt METHOD addFlutterTasks 349-533，349–533 | B89C513B5803A734D6DC8F1574EED66F9BC173787D13A6D88F5604833F9CBEEE |
| repo-block / round2：SECTION FlutterPlugin apply 46-307 ALL_NONCOMMENT_NONBLANK_LINES，88–101 | 4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534 |
| init-full / round2：SECTION aar_init_script FULL，1–191 | 5252CD23EDFD3F02AB1E43875F2F0BAE286589A035475D092A87723E02524FCC |
| plugin-deps / round1：SECTION PluginHandler FULL 1-261，226–258 | 5B7712D84D82BDCE1BB071419E6BAEFE134754C80B62E3C8BAE1005058E4C33F |

历史整SDK锚FlutterPlugin=`1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313`，init=`B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2`。整文件hash与归一片段hash分开，不能凭这些摘录获得整SDKpatch或版本认证。M5-28未接受，引用它只固定候选字节来源，不继承其错误输出域。

## 最终输入与返回schema

拟议 `adapt_module_debug_entry(*, materials: tuple[tuple[str,bytes],...], config: dict) -> EntryMaterials`，纯内存。exact tuple/str/bytes/dict，类型子类/custom object/list/bytearray拒绝；TypeError固定TYPE，语义错误ValueError固定CONTRACT，不回显输入。materials准确顺序tasks-full、repo-block、init-full、plugin-deps，四hash如上，每份≤256KiB总≤1MiB。

config必须且仅有mode、flutter_identity、init_identity、input_id、projects、properties、tasks、sdk_root、maven_root、publication_root、repositories_mode；mode固定module-debug-v1，两identity固定历史锚；input_id任意64个ASCII小写hex。projects固定 `(':', ':flutter', ':sample_alpha', ':sample_beta')`；tasks固定 `('assembleAarDebug',)`；三root固定materials/flutter_sdk、materials/maven、publication；repositories_mode固定FAIL_ON_PROJECT_REPOS。properties为按projects同序的tuple `(path, tuple[(key, logical_value),...])`；六键与顺序见P1/P2。value是exact str，buildNumber必须与config.input_id相等；publication是logical token，不是runtime安装值。无extra/重复键/继承标记/路径覆盖/env/executable。

所有返回类型frozen dataclass，所有容器tuple、值str/bytes/enum/frozen对象。固定schema如下：

```text id=output-schema
EntryMaterials(
  operations: tuple[PatchOperation, ...],
  attachments: tuple[Attachment, ...],
  invocation: InvocationContract
)
PatchOperation(
  order: exact int,
  target: Literal['repo-block','tasks-full','init-full'],
  kind: Literal['REPLACE_UNIQUE','INSERT_BEFORE_UNIQUE'],
  input_fragment_sha256: exact str,
  anchor_id: exact str,
  before: exact bytes,
  after: exact bytes
)
Attachment(
  id: Literal['apply-helper','apply-preflight-proposal'],
  placement: Literal['FLUTTER_PLUGIN_CLASS_MEMBER','APPLY_AFTER_THIS_PROJECT_ASSIGNMENT'],
  historical_sdk_identity: exact str,
  before: exact bytes,
  after: exact bytes,
  executable_patch: Literal[False]
)
InvocationContract(
  mode: exact str,
  requested_tasks: tuple[str,...],
  projects: tuple[str,...],
  logical_properties: tuple[tuple[str,tuple[tuple[str,str],...]],...],
  property_installation: tuple[InstallationGroup,...],
  property_install_phase: exact str,
  sdk_root: exact str,
  maven_root: exact str,
  publication_root: exact str,
  publication_repository: exact str,
  repositories_mode: exact str,
  module_project: exact str,
  module_variant: exact str,
  plugin_projects: tuple[str,...],
  plugin_variants: tuple[str,...],
  aar_task_edges: tuple[tuple[str,str],...],
  publish_finalizers: tuple[str,...],
  sdk_identity: exact str,
  init_identity: exact str,
  input_id: exact str,
  runtime_ready: Literal[False]
)
InstallationGroup(project: exact str, scope: Literal['LOCAL_EXTRA'], recipes: tuple[PropertyRecipe,...])
PropertyRecipe = LiteralString(key: exact str, value: exact str) | RootProjectDirFilePath(key: Literal['output-dir'], base: Literal['ROOT_PROJECT_DIR'], child_components: tuple[str,str,str], result: Literal['FILE_PATH'], install_phase: exact str)
```

返回不是已适配整片段，亦无fragment拼接结果/invocation固定文本字段。operations是完整typed修订描述，不立即应用。后继在新任务可将tasks-full/init-full局部scratch按该序产生完整适配片段，但本轮没有执行转换。完整apply未持有：helper和preflight只作为Attachment落地提案，class插入位置/import/API仍须独立来源门，executable_patch=false。

全输入/版本/hash/锚唯一性/无适配标记验证后，才能返回一个完整操作包；失败无部分返回、无宿主写入。后继执行时先在scratch完成所有操作与检查再发布一个结果，不提供事务已执行证明。相同原输入重复调用结果等值；将已适配/部分适配材料再次作为输入拒绝，不静默二次适配。输出顺序恒定，UTF8无BOM/LF；每个下方block含末尾LF，保留所有缩进，空before bytes明示，不引入省略正文。

## 完整operations与保留规则

以下六项是唯一operations；所有before/after全文在本文block，输入digest取上表对应target。before bytes是锚/替换范围，不是假称完整target。INsert语义after为插入bytes（不包含锚），REPLACE语义after替换before。每操作在当时scratch exact count=1才允许；共享init-all锚先插helpers后替换guard，helpers没有同样独立首锚。原target中不在精确替换范围的每个byte保留，不根据fun正则重建函数。

| order | target | kind | anchor_id / before | after |
| ---: | --- | --- | --- | --- |
| 0 | repo-block | REPLACE_UNIQUE | repo-before（覆盖整个该输入片段） | repo-after |
| 1 | tasks-full | REPLACE_UNIQUE | tasks-before（原453–456边界） | tasks-after |
| 2 | init-full | INSERT_BEFORE_UNIQUE | init-all-before（原113） | init-helpers（全文，含一个最终LF） |
| 3 | init-full | REPLACE_UNIQUE | init-all-before | init-all-after |
| 4 | init-full | REPLACE_UNIQUE | init-afterProject-before（原117） | init-afterProject-after |
| 5 | init-full | REPLACE_UNIQUE | init-projectsEvaluated-before（原150） | init-projectsEvaluated-after |

tasks原349–454的targetPlatforms361–362、flutterPlugin=this364及app分支保留，原456–533 host分支保留；新增分支在app返回之后/host之前，不复制app host assets代码。init原三个callback全部body及原其它函数保持，仅插guard；受控路径不调用原遍历全组件/publish，未启用时继续原路径。repo-after内原repo-before逐字保留（包括原缩进），不是只说语义等价。plugin-deps仅输入校验/来源，不产生修改。

```kotlin id=repo-before
        val hostedRepository: String =
            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)
                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST
        val repository: String? =
            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {
                project.property(PROP_LOCAL_ENGINE_REPO) as String?
            } else {
                "$hostedRepository/${engineRealm}download.flutter.io"
            }
        rootProject.allprojects {
            repositories.maven {
                url = uri(repository!!)
            }
        }
```

```kotlin id=repo-after
        if (!esControlledModule(project)) {
        val hostedRepository: String =
            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)
                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST
        val repository: String? =
            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {
                project.property(PROP_LOCAL_ENGINE_REPO) as String?
            } else {
                "$hostedRepository/${engineRealm}download.flutter.io"
            }
        rootProject.allprojects {
            repositories.maven {
                url = uri(repository!!)
            }
        }
        }
```

```kotlin id=tasks-before
            return
        }
        // Flutter host module project (Add-to-app).
        val hostAppProjectName: String? =
```

```kotlin id=tasks-after
            return
        }
        if (esControlledModule(projectToAddTasksTo)) {
            val android = projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)
            check(android != null) { "ES_LIBRARY" }
            android.libraryVariants.all esLibraryVariant@{
                val variant = this
                if (variant.name != "debug") {
                    return@esLibraryVariant
                }
                check(variant.flavorName.isEmpty()) { "ES_FLAVOR" }
                check(FlutterPluginUtils.buildModeFor(variant.buildType) == "debug") { "ES_MODE" }
                val assembleTask = variant.assembleProvider.get()
                check(FlutterPluginUtils.shouldConfigureFlutterTask(projectToAddTasksTo, assembleTask)) { "ES_TASKS" }
                addFlutterDeps(variant, flutterPlugin, targetPlatforms)
            }
            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)
            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(
                projectToAddTasksTo,
                getPluginHandler(projectToAddTasksTo).getPluginList()
            )
            return
        }
        // Flutter host module project (Add-to-app).
        val hostAppProjectName: String? =
```

```groovy id=init-all-before
allprojects {
```

```groovy id=init-all-after
allprojects {
    if (esEnabled(project)) {
        esCheckProject(project, false)
    }
```

```groovy id=init-afterProject-before
afterProject { project ->
```

```groovy id=init-afterProject-after
afterProject { project ->
    if (esEnabled(project)) {
        esAfterProject(project)
        return
    }
```

```groovy id=init-projectsEvaluated-before
projectsEvaluated {
```

```groovy id=init-projectsEvaluated-after
projectsEvaluated {
    if (esEnabled(rootProject)) {
        esProjectsEvaluated(rootProject)
        return
    }
```

## 完整修正helpers与attachments

Kotlin先判own存在或project.hasProperty存在；不存在还检查root是否单独存在，拒绝不一致。只在两者均无mode时legacy=false。存在则必须own，own值必须非null String且准确值；root同样必须own非null正确String。不用findProperty(null)判断不存在。

Attachment apply-helper：placement=FLUTTER_PLUGIN_CLASS_MEMBER，before=空bytes，after为完整block；Attachment apply-preflight-proposal：placement=APPLY_AFTER_THIS_PROJECT_ASSIGNMENT，before/after为下列完整block（历史apply:47锚），仅待审落地提案，不声称可对完整SDK应用。SDK identity均为历史Flutter锚。

```kotlin id=apply-helper
    private fun esControlledModule(p: Project): Boolean {
        val key = "elitesync.aar-entry"
        val own = p.extensions.extraProperties
        val root = p.rootProject
        val rootOwn = root.extensions.extraProperties
        val present = own.has(key) || p.hasProperty(key)
        if (!present) {
            check(!rootOwn.has(key) && !root.hasProperty(key)) { "ES_ROOT_MODE" }
            return false
        }
        check(own.has(key)) { "ES_SCOPE" }
        val raw = own.get(key)
        check(raw is String && raw == "module-debug-v1") { "ES_MODE" }
        check(rootOwn.has(key)) { "ES_ROOT_SCOPE" }
        val rootRaw = rootOwn.get(key)
        check(rootRaw is String && rootRaw == raw) { "ES_ROOT_MODE" }
        check(p.path == ":flutter") { "ES_PROJECT" }
        check(!FlutterPluginUtils.isFlutterAppProject(p)) { "ES_APP" }
        val android = p.extensions.findByType(LibraryExtension::class.java)
        check(android != null && android.productFlavors.isEmpty()) { "ES_LIBRARY" }
        check(p.gradle.startParameter.taskNames == listOf("assembleAarDebug")) { "ES_TASKS" }
        val values = linkedMapOf(
            "is-plugin" to "false",
            "output-dir" to File(root.projectDir, "../../publication").path,
            "elitesync.sdk-identity" to "1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313",
            "elitesync.aar-projects" to ":,:flutter,:sample_alpha,:sample_beta"
        )
        values.forEach { (name, value) ->
            check(own.has(name)) { "ES_SCOPE" }
            check(own.get(name) == value) { "ES_PROPERTY" }
        }
        check(own.has("buildNumber")) { "ES_SCOPE" }
        val id = own.get("buildNumber")
        check(id is String && Regex("[0-9a-f]{64}").matches(id)) { "ES_ID" }
        check(rootOwn.has("buildNumber")) { "ES_ROOT_SCOPE" }
        check(rootOwn.get("buildNumber") == id) { "ES_ID" }
        listOf("local-engine-repo", "local-engine-out", "local-engine-host-out", "local-engine-build-mode").forEach {
            check(!p.hasProperty(it)) { "ES_LOCAL_ENGINE" }
        }
        check(!p.hasProperty("skipDependencyChecks")) { "ES_SKIP" }
        return true
    }
```

```kotlin id=preflight-before
        this.project = project
```

```kotlin id=preflight-after
        this.project = project
        esControlledModule(project)
```

Groovy完整helpers如下，其余发布设计维持M5-28；mode函数修正，root.subprojects仍含全部后代，debug组件/参与项目缺失拒绝，未知AGP API不宣称已编译。

```groovy id=init-helpers
boolean esEnabled(Project p) {
    def key = 'elitesync.aar-entry'
    def own = p.extensions.extraProperties
    def root = p.rootProject
    def rootOwn = root.extensions.extraProperties
    boolean present = own.has(key) || p.hasProperty(key)
    if (!present) {
        if (rootOwn.has(key) || root.hasProperty(key)) {
            throw new GradleException('ES_ROOT_MODE')
        }
        return false
    }
    if (!own.has(key)) {
        throw new GradleException('ES_MODE_SCOPE')
    }
    def raw = own.get(key)
    if (!(raw instanceof String) || raw != 'module-debug-v1') {
        throw new GradleException('ES_MODE_SCOPE')
    }
    if (!rootOwn.has(key)) {
        throw new GradleException('ES_ROOT_MODE')
    }
    def rootRaw = rootOwn.get(key)
    if (!(rootRaw instanceof String) || rootRaw != raw) {
        throw new GradleException('ES_ROOT_MODE')
    }
    return true
}

Set<String> esAllowed() {
    return [':', ':flutter', ':sample_alpha', ':sample_beta'] as Set
}

void esCheckProject(Project p, boolean evaluated) {
    if (!esAllowed().contains(p.path) || !esEnabled(p)) {
        throw new GradleException('ES_PROJECT')
    }
    def own = p.extensions.extraProperties
    def expected = [
        'is-plugin': 'false',
        'output-dir': new File(p.rootProject.projectDir, '../../publication').path,
        'elitesync.sdk-identity': '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313',
        'elitesync.aar-projects': ':,:flutter,:sample_alpha,:sample_beta'
    ]
    expected.each { key, value ->
        if (!own.has(key) || !(own.get(key) instanceof String) || own.get(key) != value) {
            throw new GradleException('ES_PROPERTY_SCOPE')
        }
    }
    if (!own.has('buildNumber') || !(own.get('buildNumber') instanceof String) || !(own.get('buildNumber') ==~ /[0-9a-f]{64}/)) {
        throw new GradleException('ES_ID')
    }
    if (!p.rootProject.extensions.extraProperties.has('buildNumber') || p.rootProject.extensions.extraProperties.get('buildNumber') != own.get('buildNumber')) {
        throw new GradleException('ES_ID')
    }
    if (p.gradle.startParameter.taskNames != ['assembleAarDebug']) {
        throw new GradleException('ES_TASKS')
    }
    if (['local-engine-repo', 'local-engine-out', 'local-engine-host-out', 'local-engine-build-mode', 'skipDependencyChecks'].any { p.hasProperty(it) }) {
        throw new GradleException('ES_BYPASS')
    }
    if (evaluated && p.path != ':') {
        if (!p.hasProperty('android') || !p.android.hasProperty('libraryVariants') || !p.android.productFlavors.isEmpty()) {
            throw new GradleException('ES_LIBRARY')
        }
    }
}

void esAfterProject(Project p) {
    esCheckProject(p, true)
    if (p.path == ':') {
        return
    }
    def singles = p.android.publishing.singleVariants
    if (singles.isEmpty()) {
        p.android.publishing.singleVariant('debug')
    } else if (singles.size() != 1 || singles.first().variantName != 'debug') {
        throw new GradleException('ES_PUBLICATION_VARIANT')
    }
}

void esPublishDebug(Project p) {
    esCheckProject(p, true)
    def debugVariants = p.android.libraryVariants.findAll { it.name == 'debug' && it.flavorName.isEmpty() }
    def component = p.components.findByName('debug')
    if (debugVariants.size() != 1 || component == null || !p.publishing.publications.isEmpty() || !p.publishing.repositories.isEmpty()) {
        throw new GradleException('ES_DEBUG_COMPONENT')
    }
    if (p.tasks.findByName('assembleAarDebug') != null) {
        throw new GradleException('ES_DUPLICATE_TASK')
    }
    p.version = p.extensions.extraProperties.get('buildNumber')
    p.publishing.publications.create('debug', MavenPublication) { pub ->
        groupId = "${pub.groupId}"
        artifactId = "${pub.artifactId}_${pub.name}"
        version = "${pub.version}"
        from component
    }
    p.publishing.repositories.maven {
        name = 'controlledDebug'
        url = p.uri(new File(p.extensions.extraProperties.get('output-dir'), 'outputs/repo'))
    }
    def publishDebug = p.tasks.named('publishDebugPublicationToControlledDebugRepository')
    p.tasks.create('assembleAarDebug') {
        dependsOn(debugVariants.first().assembleProvider)
        finalizedBy(publishDebug)
    }
}

void esProjectsEvaluated(Project root) {
    def actual = ([root.path] + root.subprojects.collect { it.path }) as Set
    if (actual != esAllowed()) {
        throw new GradleException('ES_TOPOLOGY')
    }
    ([root] + root.subprojects.toList()).each { esCheckProject(it, true) }
    Project module = root.findProject(':flutter')
    if (module == null) {
        throw new GradleException('ES_MODULE')
    }
    def participants = [module, root.findProject(':sample_alpha'), root.findProject(':sample_beta')]
    if (participants.any { it == null }) {
        throw new GradleException('ES_PLUGIN')
    }
    participants.each { esPublishDebug(it) }
    def moduleDebug = module.tasks.named('assembleAarDebug').get()
    participants.findAll { it.path != ':flutter' }.each { plugin ->
        moduleDebug.dependsOn(plugin.tasks.named('assembleAarDebug'))
    }
}
```

## logical properties到安装recipe

所有project显式LOCAL_EXTRA，phase固定 `BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS`。不依赖root ext继承；受审bootstrap是以后执行前置条件，本纯函数仅返回recipe，不执行bootstrap。

recipe字段无默认/override。唯一File.path recipe为：

```text id=output-dir-recipe
RootProjectDirFilePath(
  key='output-dir',
  base='ROOT_PROJECT_DIR',
  child_components=('..','..','publication'),
  result='FILE_PATH',
  install_phase='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS'
)
```

child_components不是调用者自由路径：准确固定这三个组件，joins成`../../publication`。未来installer执行 `File(rootProject.projectDir, "../../publication").path`，结果string写到每project自己的extra；不把logical token publication直接写入。Kotlin helper比较同一File(root.projectDir,..).path；Groovy比较同一new File(p.rootProject.projectDir,..).path。无normalize/canonical/resolve/读取存在性/symlink检查，必须同一root基准。

其它recipe为LiteralString，key和值直接从validated logical_properties取用；buildNumber由config.input_id绑定后转LiteralString。整个recipe tuple键序为mode、is-plugin、output-dir、buildNumber、SDK identity、project集合。每project的logical表都是完整六键，不省缺值或只设root。安装组按projects四项顺序。

人工逻辑模型，未访问任何目录：令root projectDir token为`B/module/.android`、模型分隔符为`/`，同一File.path词法模型的结果为`B/module/.android/../../publication`，不是字符串`publication`。P1/P2都得到相同这个表达式值，并同时与两helper的比较表达式相等。实际Windows/JVM native separators/真实绝对位置必须由未来installer一致处理；此人工模型不证明真实路径解析、ACL、symlink或OS隔离。不得把模型结果当实际电脑路径。

## P1/P2全部输入与完整Invocation预期

以下定义共享常量F/I/P/T与各完整table，不执行生成器。引用这些已全文定义的不可变常量是完整对象描述，不是省略字段；不存在任意默认或需后继猜的槽。操作六项和attachment两项bytes完全同于本文固定blocks，两例均不含调用文本返回值。通用Invocation必须从config.input_id构造，不接受冻结64a字节作为输出。

F=`1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313`；I=`B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2`；P=`(':',':flutter',':sample_alpha',':sample_beta')`；T=`('assembleAarDebug',)`；ID_A=`aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`；ID_B=`bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb`。

```text id=P1-properties
(
(':',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':flutter',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_alpha',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_beta',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')))
)
```

```text id=P2-properties
(
(':',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':flutter',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_alpha',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_beta',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')))
)
```

R_A/R_B分别为以下完整recipes tuple，FILE_RECIPE准确等于output-dir-recipe block定义；它是typed字段值，不是代码运行结果。

```text id=P1-recipes
R_A = (
LiteralString('elitesync.aar-entry','module-debug-v1'),
LiteralString('is-plugin','false'),
FILE_RECIPE,
LiteralString('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
LiteralString('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),
LiteralString('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
```

```text id=P2-recipes
R_B = (
LiteralString('elitesync.aar-entry','module-debug-v1'),
LiteralString('is-plugin','false'),
FILE_RECIPE,
LiteralString('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),
LiteralString('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),
LiteralString('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
```

完整输入P1：materials为上表准确四原bytes，config为下列11字段；P2同样全文列出，不通过适配器回算任何预期。properties blocks的literal tuple分别记L_A/L_B。

```text id=P1-input
config = dict(
mode='module-debug-v1', flutter_identity=F, init_identity=I,
input_id='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
projects=P, properties=L_A, tasks=T,
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', repositories_mode='FAIL_ON_PROJECT_REPOS'
)
materials = (('tasks-full',TASKS_ORIGINAL_BYTES),('repo-block',REPO_ORIGINAL_BYTES),('init-full',INIT_ORIGINAL_BYTES),('plugin-deps',DEPS_ORIGINAL_BYTES))
```

```text id=P2-input
config = dict(
mode='module-debug-v1', flutter_identity=F, init_identity=I,
input_id='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
projects=P, properties=L_B, tasks=T,
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', repositories_mode='FAIL_ON_PROJECT_REPOS'
)
materials = (('tasks-full',TASKS_ORIGINAL_BYTES),('repo-block',REPO_ORIGINAL_BYTES),('init-full',INIT_ORIGINAL_BYTES),('plugin-deps',DEPS_ORIGINAL_BYTES))
```

四ORIGINAL_BYTES唯一由冻结id/范围/hash定义，不能换其它版本。P1/P2 operations准确六项表，before/after逐block字节，inputdigest准确上表；attachments准确两项描述。所有源操作/attachment bytes两例恒定，不包含64a/64b。动态变化只在Invocation.input_id、logical表四个buildNumber及installation四个LiteralString buildNumber；FILE_RECIPE同值，不生成调用文本。

```text id=P1-invocation
InvocationContract(
mode='module-debug-v1', requested_tasks=('assembleAarDebug',),
projects=(':',':flutter',':sample_alpha',':sample_beta'),
logical_properties=L_A,
property_installation=(InstallationGroup(':','LOCAL_EXTRA',R_A),InstallationGroup(':flutter','LOCAL_EXTRA',R_A),InstallationGroup(':sample_alpha','LOCAL_EXTRA',R_A),InstallationGroup(':sample_beta','LOCAL_EXTRA',R_A)),
property_install_phase='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS',
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', publication_repository='publication/outputs/repo',
repositories_mode='FAIL_ON_PROJECT_REPOS', module_project=':flutter', module_variant='debug',
plugin_projects=(':sample_alpha',':sample_beta'), plugin_variants=('debug','debug'),
aar_task_edges=((':flutter:assembleAarDebug',':sample_alpha:assembleAarDebug'),(':flutter:assembleAarDebug',':sample_beta:assembleAarDebug')),
publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository',':sample_alpha:publishDebugPublicationToControlledDebugRepository',':sample_beta:publishDebugPublicationToControlledDebugRepository'),
sdk_identity=F, init_identity=I,
input_id='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', runtime_ready=False
)
```

```text id=P2-invocation
InvocationContract(
mode='module-debug-v1', requested_tasks=('assembleAarDebug',),
projects=(':',':flutter',':sample_alpha',':sample_beta'),
logical_properties=L_B,
property_installation=(InstallationGroup(':','LOCAL_EXTRA',R_B),InstallationGroup(':flutter','LOCAL_EXTRA',R_B),InstallationGroup(':sample_alpha','LOCAL_EXTRA',R_B),InstallationGroup(':sample_beta','LOCAL_EXTRA',R_B)),
property_install_phase='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS',
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', publication_repository='publication/outputs/repo',
repositories_mode='FAIL_ON_PROJECT_REPOS', module_project=':flutter', module_variant='debug',
plugin_projects=(':sample_alpha',':sample_beta'), plugin_variants=('debug','debug'),
aar_task_edges=((':flutter:assembleAarDebug',':sample_alpha:assembleAarDebug'),(':flutter:assembleAarDebug',':sample_beta:assembleAarDebug')),
publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository',':sample_alpha:publishDebugPublicationToControlledDebugRepository',':sample_beta:publishDebugPublicationToControlledDebugRepository'),
sdk_identity=F, init_identity=I,
input_id='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', runtime_ready=False
)
```

## mode矩阵与四问题负例（人工预期，未执行）

纯接口只接受受控mode，不提供legacy config；legacy分支保留的是运行源材料行为。runtime fixtures与pure输入失败分开，不拿pure转换假装检查真实AGP对象。

| runtime mode状态 | 完整预期 |
| --- | --- |
| project/root均不存在mode（own.has和hasProperty均false） | 两helper返回false，原legacy分支文本继续 |
| own存在且null，即使findProperty返回null | Kotlin ES_MODE；Groovy ES_MODE_SCOPE，拒绝，不legacy |
| own存在且Boolean false | ES_MODE / ES_MODE_SCOPE，拒绝 |
| own存在但错误string/空string/其它type | ES_MODE / ES_MODE_SCOPE，拒绝 |
| project有继承mode但own缺失 | ES_SCOPE / ES_MODE_SCOPE，拒绝 |
| project不存在mode而root存在（包括null） | ES_ROOT_MODE，拒绝 |
| project正确own mode，root own缺失/继承/root null或错误值 | ES_ROOT_SCOPE或ES_ROOT_MODE；Groovy ES_ROOT_MODE，拒绝 |
| project/root正确own String值一致，library/属性/task等其余条件正确 | true并进入受控路径 |
| project/root值冲突 | ES_ROOT_MODE，拒绝 |

纯负例每项独立从P1/P2改一处；失败固定TYPE或CONTRACT，无EntryMaterials/部分操作包，无宿主写入：

| 输入改变 | 完整预期 |
| --- | --- |
| materials/id顺序错、缺输入、版本/hash/bytes错、缺/重复锚、不一致源行、已适配输入 | CONTRACT，拒绝整个包 |
| 要求fragments/完整SDK输出或任意patch target/自由覆盖字段 | CONTRACT，拒绝；只有固定六operations和两attachments |
| P2.input_id=64b但properties任一buildNumber仍64a或少一个project | CONTRACT，拒绝；不输出固定64a调用文本 |
| input_id非64个ASCII小写hex、bool/bytes/object | CONTRACT或TYPE，拒绝 |
| publication token改绝对/UNC/drive/../，properties直接给模型runtime路径 | CONTRACT，拒绝；only publication逻辑token |
| config增加recipe override，FILE_RECIPE组件/基准/结果/phase/作用域自由字段 | CONTRACT，拒绝；recipes由固定schema生成，不接受任意override |
| properties仅root、继承、缺false、false为bool、项目值冲突/重复key | CONTRACT或TYPE，拒绝 |
| pure mode missing/null/false/wrong，root-child conflict encoded inlogical表 | CONTRACT或TYPE，拒绝 |
| 增app/未知project/意外后代，非:flutter，任务release/profile/带前缀/多任务 | CONTRACT，拒绝 |
| 远端repo/PREFER_SETTINGS/删gate/local-engine/skip检查字段 | CONTRACT，拒绝 |

runtime fixture仍需：非library/flavor→ES_APP/ES_LIBRARY/ES_FLAVOR；debug组件/variant缺失、重复或既有pub/repo→ES_DEBUG_COMPONENT；重复任务→ES_DUPLICATE_TASK；额外后代→ES_TOPOLOGY/ES_PROJECT；非法任务→ES_TASKS；local-engine/skip→ES_LOCAL_ENGINE/ES_SKIP/ES_BYPASS。缺失时停止，不回落host、release或publish。可能先注册某项目再失败另一项目；不能声称runtime事务回滚。

## 四Required替代与未解门

原M5-28“七fragments输出/拼callback首锚”等条款被本六typed operations和两Attachment替代，不返回完整转换结果；原固定invocation-expectation bytes不作为通用输出，P1/P2仅独立预期；原properties安装说法被logical表与typed recipe两层替代；原findProperty null早退被完整presence检查helpers替代。M5-28仍REJECT，不因本新合同追认。

剩余域保持：无host library debug接线、configurePlugins/低SDK/NDK检查、仅受控模式省项目Maven、debug publication/task与原路径保留；FAIL_ON_PROJECT_REPOS不删，不用PREFER_SETTINGS/远端/local-engine/跳检查。TaskAction/registrant、Api与renderer implementation最终配置/POM、NDK/.cxx/source/build/native_assets/mergeAssets、真实SDK/engine/config/metadata/plugin输入、AGP/Groovy/Kotlin编译及回调/命名发布task时序、绝对路径/symlink/ACL/OS隔离/manifest/真实材料均UNKNOWN。属性bootstrap前置时点、included-build和plugin额外repo不因recipe变安全；preflight前AGP/included-build可能已有外部动作，不能称sandbox或release ready。

后继仅可由Work另立SOURCE-ONLY纯材料实现路径/预算；本轮不实现、不执行转换，不对完整SDKapply补丁自授权。第二轮仅读本plan一次、≤256KiB/输出≤16KiB做固定文本/hash一致性，不跑任何正负例；结果只附同次回执/停点，不修改被检查合同。

唯一plan停Work独立LEVEL2 ACCEPT/REJECT，不自接受/派后继。无SDK/配置/cache/env/home/真实properties/metadata/engine/plugin材料读取、目录搜索索引/日志再回收、下载复制/算法测试/编译/Gradle/Flutter/JVM/ADB/构建安装启动/UAC/落地bundle、源码/renderer/authority/旧证据写、旧D:\EliteSync/真实数据/备份密钥/生产DB/API/SSH或Git提交/pull/push。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与所有保护门保持。

## 第二轮同次作者静态回执

一次读本plan，普通非reparse、≤256KiB；检查前字节37018，SHA256 897CB695323E52EC82DFBC5A340DD779A453243A3B87276241C455A71B6760E6。六operations顺序/typed返回域与attachment提案、before hash/原repo保留、未变tasks-after、P1/P2完整fixture仅ID及L/R引用差异、恒定源bytes不含动态ID、安装recipe字段、presence先于取值及null无legacy、模式矩阵/原文保留/剩余门固定文本检查PASS。只做标准库文本/hash，不执行转换算法、正负例、Kotlin/Groovy/Gradle；不证明语义正确或运行安全。打印前主动累计UTF8≤16KiB；第二轮1/1关闭，总2/2，旧预算保持。

| block id | SHA256（UTF8/LF） |
| --- | --- |
| output-schema | 9BD69C6B9BB00F7049F4DAF3CF7C3DB15DFC3C9B45F9EA17F964E4413045C744 |
| repo-before | 4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534 |
| repo-after | 6CD532EDDD8D104E299B6384AD3B81B2738CE700330FF00B2221A824162CEC17 |
| tasks-before | B9AC68E2DC9DCCE8C2F2EB1F642FF674ED0AC23501D33499C1145A04E793D236 |
| tasks-after | 1CB68D8BB90ABD8A67CD6ACCB8CDB728DEDB5D8D7E1B7D8F124B592C6DF33BAE |
| init-all-before | 027A4434FFF6F23894D41BDFF3F3483268F9DFF7DF08F7D071E7D1EECDC60D56 |
| init-all-after | 2AABBDC10A6B4E1A7ED84A49BAAD75AB2CFE50346178A43DA63E6F3265E8ACC4 |
| init-afterProject-before | 4B80E184109EF9F5CDAA0858FBB90F65A199B99A912C11C769613200AE2778E7 |
| init-afterProject-after | BA75137EFFEE607DA26DD746BD10B337FD6A844009768599DEAA370811BB20EF |
| init-projectsEvaluated-before | 6C44D5256325F80C7A45180733525AB18DA7C3965AC60D7B8596781AD9806851 |
| init-projectsEvaluated-after | 0B01A220A0980091ED7D4B6E94969306EFE2C53FA215E2DBD149FCEC869CC05E |
| apply-helper | 44503DD02B3F0B12E4713670BFB799D08A15A59195D0EF5C9FC45172D98719DE |
| preflight-before | 7A69ABFDFACB460AFFC96ED2443A9F77E5D60C4FC280AA6FDEB44298032B3965 |
| preflight-after | 3C085E0AF7BA0EB36970E3D7122522EB621103311A919C922B4AF693EA99E111 |
| init-helpers | 0256AE1A42DDD3AA7D592D053A97103D6B5BCAF67A0F7854285F7FDCDF183112 |
| output-dir-recipe | 4B7205BCE2677F1AEA0D9971760987708EA893CBDD91608155E94D20C58B7E65 |
| P1-properties | 4C04F37EA7CDECE1E3800BD2363683734F34A075B5084A46C68E60537BBC26E4 |
| P2-properties | 372D30B7617042C5A2388BD8BEDB558B99BFF7B41DA521D481A2A16232E22A2B |
| P1-recipes | 885E35DDD4C01D1DCB3C7F41DF6C865CE2C0D21C7D6A402D795C63CF39432E67 |
| P2-recipes | 1269FAB7F59FEF823A04E63F00AEE8163030FD58B2AC6F0A32403EE523965235 |
| P1-input | 65FD6F7D83B7AAF462ABBA5BD455F44BA97AA3240C4556304E98761DE88A6024 |
| P2-input | 076F83722457138369F94EB5971BC0707A067E0C5A981DB882446A5E41AB1181 |
| P1-invocation | 939D41AF1D637B405104923ABADCC5148CA8B0DA07B3EDD79275D1F2B7A4068B |
| P2-invocation | BCA7A86BFD4854FB06078A746A28BA33D46137A4F5626C67BD893281CD7925D3 |

检查后仅附本同次回执与停点，被检查schema/代码/fixture未改。作者候选停Work独立LEVEL2复核，不自接受/后继；M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及全部保护门保持。

````


## 同次A/B关闭回执与最终停点

A chunk 166fc1，exit 0，wall_time_seconds 0.2076706；三准确来源身份回执已在正文之后保存，A 1/1成功关闭。B只对本plan一次ReadAllBytes；普通非reparse/≤256KiB/严格UTF8、固定文本槽一致性通过，未Python/AST/算法运行。

B检查前 bytes=135515，SHA256=3EE96A6D3405555972E697F907863D80CB1F5BDE824EA208FB5BA477FF437FA6；具名文本门：PUBLIC_SCHEMA_MODEL_ERROR_AND_FUTURE_PATH_SLOTS; P1_P2_11_KEYS_SIX_PROPERTIES_FOUR_INSTALL_PROJECTS; SIX_ORDERED_SCRATCH_DERIVATION_SLOTS; COMPLETE_LITERAL_DEFINITIONS_AND_ACCEPTED_CONTRACT_APPENDIX，全部PASS。这只是文本槽/字面定义存在性与固定键序/项目数/六操作描述核对，不证明新算法或全部负例正确。B 1/1关闭。

被检查正文和完整常量不变，仅追加本同次回执。最终hash由同次工具FINAL_PLAN_SHA256给出，按原bytes+本追加文本的准确最终UTF8 bytes计算并写入；它区别于检查前hash，不在文档自嵌自身hash。Work可独立核文件最终身份。工具chunk与原stdout可从本次执行回执核对，不补读源或重新运行检查。

只读Git成员核对：188条既有status缺0，当前189条，唯一新M5-38证据目录；非全部文件逐字节完整性证明。A/B均1/1关闭，所有旧预算关闭；原source/harness/authority/旧candidate不改。所有Python/AST/算法/测试/SDK/构建安装启动执行0；M5/隔离构建NOT_READY与全部保护门保持。唯一plan停Work独立LEVEL2，不自接受/后继。
