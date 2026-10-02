**2026-09-30 Work续作修订：RESUME ISSUED。** 当前Assignee改为最新Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad（local，D:\EliteSync-v10，Sol/medium），只读交接已通过。旧会话停用，原任务ID/保护边界不变。第一轮SDK1/2已消耗，不再读SDK第一轮或重哈希；只可复用本目录work-first-round-source-receipt.txt（完整同次原始回执SHA256 6BB9EAA5DC94BFFAA9D93E5F00C95C81CFB80B65F1C2D655D167365A65BD412C）和根authority/历史review。剩余第二轮最多6个第一轮直接引用的官方源文件，预算仅1轮；随后交唯一plan.md，停Work独立审查。本修订覆盖下方旧Assignee与两轮启动文字，不重置预算或新增工具执行权限。

# APP-M5-13｜Flutter AAR生成与Gradle调用的受控入口合同

ISSUED；LEVEL2，DOCS-ONLY。Codex 01a0ef77-af94-75e2-8726-87c04e082018，GPT-6.1 Sol/medium。唯一仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be，全部dirty/untracked保留。先读根五authority/local-workflow、M5-10 plan与review、M5-11/12 review；接受的九文件仍SOURCE-ONLY，settings与v1合同均拒绝运行。唯一新增本目录plan.md，无源代码/配置/SDK修改，不建staging。

目的：核定M5-10未解的Flutter可能生成.android后立即启动Gradle边界，给一个可以事前控制生成文件/Gradle分发/环境的准确后继源码切片；不要重复泛化隔离设计，也不写未知的GO命令。

新只读SDK预算两轮：
第一轮只读/文件内rg/哈希以下准确官方源：
D:\flutter\packages\flutter_tools\lib\src\commands\build_aar.dart
D:\flutter\packages\flutter_tools\lib\src\android\gradle.dart
D:\flutter\packages\flutter_tools\lib\src\android\gradle_utils.dart
D:\flutter\packages\flutter_tools\lib\src\project.dart
固定SDK来源，禁止索引用户目录或SDK/缓存、全SDK搜索。图谱若没有该SDK的已授权索引，直接按已给官方文件读取，不新索引工具链。
第二轮仅可读第一轮确实直接引用的最多6个官方源/Gradle模板文件，必须先从引用确定准确路径再读，记录来源引用/文件路径/行/hash；不猜或枚举模板目录，不读.properties、SDK/cache工件、凭据、用户home/全局Gradle配置。可包含第一轮明确引用的aar_init_script.gradle、Gradle可执行入口选择、模板生成器等；存在不明路径或额外链就UNRESOLVED，不能扩预算。只读取实际代码/模板，不运行任何SDK工具。

合同要回答并标注准确调用链：
1 build aar debug/no-profile/no-release/no-pub/define/output/build-number具体选项是否成立，实际target、生成/覆写.android时点、是否在同命令立即配置/启动Gradle。
2 生成步骤能否与构建分离；不执行原工程的条件下，准确可控的工程生成/模板构造入口是什么。引用具体函数/文件，不把私有工具函数当已开放CLI。若无受支持分步入口，给基于已核源码的独立受控生成器/直接Gradle参数合同建议，不能假称Flutter CLI支持。不得修改全局SDK/原模块。
3 Flutter如何选wrapper/分发/Gradle init script、Java和env/用户home，嵌套运行命令实际参数有哪些；是否能强制已固定分发直接运行、避免wrapper下载；明确哪些控制源码尚未实现。
4 debug AAR真实输出目录/GAV/POM关系；现有--output如何影响最终repo及中间目录，独立staging必须封闭哪些准确生成文件。必要Dart define编码与入口绑定来源，不能凭拟议GAV或文件目录推断身份。
5 sdk cache/engine/artifact/plugin/依赖准备及自动配置访问门，未授权读其内容，只从官方代码列出调用/存在检查/下载或重试的触发点；缺材料应如何在子进程前拒绝，--no-pub/--offline不能概括为全面封闭。

最终给唯一建议下一软件切片（准确新增/可改文件、纯校验或生成器接口与负向用例、新预算建议），以及后续必须先补齐的完整Dart/assets/plugins输入清单和依赖材料门。实际操作系统/网络/配置隔离仍未验证；如果入口不能在Gradle前控制，精确记NOT_READY与缺哪段来源。计划只决定准备动作，不让已接受host settings解除全拒绝，也不改v1的NOT_READY。

可只读九文件内contract/settings作对照，不扩读原模块/配置/缓存。本task无Flutter/Gradle/ADB/JVM/编译/测试、文件复制/材料下载/安装/运行或UAC预算；禁止任何旧D:\EliteSync/真实备份密钥/DB/SSH/生产API/Git动作。写唯一plan，记录两轮预算、引用/hash/事实vs建议与NOT_CHECKED，停独立Work LEVEL2审查，不自接受或创建后继。M5仍NOT_READY；真实账号/Conversation/G08/G11/恢复门与全部旧预算保持。
