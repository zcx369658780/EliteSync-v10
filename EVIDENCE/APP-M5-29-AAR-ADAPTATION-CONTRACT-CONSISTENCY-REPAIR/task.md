# APP-M5-29｜AAR适配合同四项一致性修复

ISSUED；LEVEL2 DOCS-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，派发前19次启动沿用。
M5-28 REJECT AS IMPLEMENTABLE CONTRACT，见其work-review.md，候选hash57A2A856780B687E4E582E1DFAC1C71FBE3069D80C51726BEDF66028F2D254FC保留，两轮2/2关闭；所有旧预算不重置。Work独立验收权及Owner保护门保持。
唯一允许写本目录plan.md，不改M5-28/旧证据、SDK、renderer、其它源码或authority。结果为修复后的自包含合同，不能只加说明而留旧矛盾。

## 唯一目标：精确修四项Required

1. 统一输出域为结构化修订材料包（此轮固定选择，不输出假称已适配的整SDK文件）。frozen EntryMaterials输出完整typed patch operation tuple、附加helper/preflight材料及结构化InvocationContract；给各operation的target id、准确before bytes/锚、after bytes、insert/replace种类、顺序/唯一性、输入版本/片段hash、原文保留规则，明确哪些只是未持有完整apply的落地提案。tasks-full/init-full可在纯内存后继按该显式操作生成适配后的整片段；本轮不执行转换，不把tasks-after边界或init首锚直接拼接当完整转换结果。完整SDK应用仍未授权。固定输出schema、operation顺序、失败原子性、幂等/重复适配拒绝及字节规范；全段原文保留需以准确操作表达，不能由后继猜。
2. 泛化input_id绑定：允许任意64个ASCII小写hex的域保持；InvocationContract.input_id、所有项目buildNumber、任何调用文本如输出必须从同一config.input_id绑定。最好移除固定invocation-expectation字节作为通用返回值，保留它只为P1独立预期；文本展示若保留则给准确动态序列化规范。提供P1=64a和P2=64b的全部输入差异、完整Invocation/properties预期，说明两例其它源修订operation哪些字节恒定。不得用生成器回算期望。
3. 明确逻辑token→安装值：pure config中publication固定逻辑根不得直接当runtime extra property值；InvocationContract分开logical property tokens与typed property_installation recipes。固定output-dir recipe为从root projectDir（声明bundle/module/.android）按组件../../publication构造File.path，与Kotlin/Groovy检查同一表达式；安装前每project显式local作用域、bootstrap阶段一致。source-only材料只记录recipe，不读文件/解析真实路径/执行安装。给recipe准确字段、类型/顺序/缺省禁止/非法路径及作用域拒绝；真实绝对位置、symlink/ACL/OS隔离及launcher仍新门。其它is-plugin/buildNumber/SDK identity/mode仍准确映射，不依赖root ext隐式继承。以人工逻辑根证明P1/P2映射值与两个helper比较表达式一致，不把原'publication'直接安装。
4. mode存在性与值分离：Kotlin及Groovy完整helper修为只有“属性不存在”才走旧模式；own null、错误类型/值、继承而缺own、root/child冲突均拒绝。先用明确存在检查，再核local extra properties和非null准确String；给完整修正helper以及missing/null/false/wrong/inherited/conflicting矩阵，区分纯输入拒绝与runtime fixture预期。不执行代码；不以findProperty null代替不存在。未启用的legacy原分支保留，不新增silent fallback。

维持M5-28剩余设计域：受控module-debug-v1、固定人工项目(:,:flutter,:sample_alpha,:sample_beta)、单任务assembleAarDebug、无host library debug接线及插件/低SDK/NDK检查、受控模式仅省项目repo注入、debug publication/task、FAIL_ON_PROJECT_REPOS、完整原路径保留。SDK/AGP/Groovy/Kotlin编译与时序、metadata/registrant/TaskAction/helper最终配置、POM/材料/系统隔离仍UNKNOWN；不新增app、不删gate/用PREFER_SETTINGS或远端repo/local-engine/跳版本NDK检查。不顺带重设计其它发布逻辑。

plan须自包含全部最终输入/输出schema、来源hash/片段提取规则、完整before/after/operations/helpers、逐project logical properties与installation recipes、P1/P2独立完整预期和四问题负例；可按冻结来源id准确引用未变的完整原bytes，但所有新增/修改的after bytes和recipe必须全文。表明M5-28无效条款被哪些明确规则替代；不能声称旧合同已接受或新方案已编译。

## 两轮全新预算，各0/1，失败即停

第一轮一次准确读取以下四个已保存文件，各普通非reparse、≤256KiB、总≤1MiB/hash门，读一次入内存；stdout UTF8主动累计≤32KiB，状态/hash先输出，聚焦修复需要的完整最小片段：
- EVIDENCE/APP-M5-28-CONTROLLED-AAR-ENTRY-ADAPTATION-CONTRACT/plan.md，预期hash如上。
- EVIDENCE/APP-M5-27-AAR-CONFIGURATION-ENTRY-CLOSURE/m526-original-receipt.txt，预期FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062。
- 同M5-27目录round-2-original-receipt.txt，预期8B4657648F3BE8CA1A36E4DFCCED2CFAEA0FAFE18C6BB2B4DCEBD5EFB6B1FE44。
- 同M5-27目录round-1-original-receipt.txt，预期9FD10B2C9B46D2578F7BFD32E266248A4C45CEC74140A39A1ED734E5DC1EA8E6。
来源wrapper只解析唯一JSON的output，不执行保存的命令。材料域与整SDK历史hash区别保持；重复源行必须一致。authority/current task/M5-28 work-review/local-workflow入口读不算专业预算。任何hash/链接/缺失/解析/大小/输出门失败即停，不修复摘录器或补读/扩源。
第二轮：完成plan后一次静态合同一致性核对（只读plan一次、≤256KiB、输出≤16KiB，标准库文本/hash检查）。核typed operation与实际返回域、P1/P2动态ID/安装recipe/模式矩阵及全输入输出规范；不执行转换算法/测试/Kotlin/Groovy/Gradle。失败即停不修复重跑；允许仅附同次回执与停点，不修改被检查合同。预算总2/2、SDK读取/目录搜索索引/算法测试/运行预算0。

所有既有dirty/untracked保留；不commit/pull/push、旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH，不下载/复制SDK/源码/renderer写、配置/cache/env/home/真实properties/metadata/engine/plugin材料读取、落地bundle/编译构建/安装启动/UAC。完成后仅交本plan和准确hash/同次预算回执，停Work独立LEVEL2审查，不自接受/派后继。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false、真实账号/Conversation/恢复与全部保护门保持。