# APP-M5-22｜人工内存插件材料校验

ISSUED；LEVEL2 SOURCE-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，当前10 turns。
核根authority/local-workflow、M5-21 plan/work-review及M5-20 summary；所有旧预算关闭。保持dirty/untracked。

精确写范围：apps/android_synthetic_demo/tools/aar_material_functions.py；apps/android_synthetic_demo/tools/test_aar_material_functions.py；EVIDENCE/APP-M5-22-PURE-SYNTHETIC-PLUGIN-MATERIALS/summary.md（主要交付）。
两源码基线7DEA9ABAA81E7B423B3312C8FE8B531C24EEE6F35A40981302786034406CA732 / E37E24484435C6A79D42A9791F80F43BACCED46029146E514FBF5861D03F1C82，不一致先停。禁止其它源码/旧证据/authority/settings/v1/host修改，不SDK/cache/env/真实metadata读取。

新增keyword-only synthetic_plugin_materials(*, metadata: dict, approved_plugin_paths: tuple[tuple[str,str],...], module_relative_root: str) -> tuple[frozen/slots PluginMaterial,...]。
仅人工内存对象，没有JSON文本/文件路径输入或JSON解析。
收窄准备合同（明确不是SDK原算法）：
- exact dict顶层仅且必须{"plugins"}，exact dict plugins仅且必须{"android"}；android exact list，最多128项。空android合法，返回空tuple。
- 每项exact dict，仅且必须name/path/dependencies/dev_dependency/native_build五键。严格str name/path，严格bool两标记，exact list[str] dependencies最多128。类型错误TypeError，非法值/结构/冲突ValueError；错误消息不含原始metadata/map/path值。
- name域[a-z][a-z0-9_]*，拒绝app/flutter/android_generated、重复name。不trim/排序/规范化。
- approved exact tuple最多128，元素exact两项tuple[str,str]；name同域/保留名禁用，path同既有canonical POSIX相对词法域。拒绝重复name/path及路径祖先/后代重叠（按段，不误判a与ab），并拒绝任何approved path与module_relative_root相等或互为祖先（按段）。这是材料隔离收窄，不证明真实目录/链接安全。
- 每个metadata条目name必须在approved中，path与对应approved path精确相同，native=false条目也需校验。approved可含未用项；不自动补metadata。只测试固定虚构清单：
  sample_alpha→materials/sample_alpha
  sample_beta→materials/sample_beta
  sample_gamma→materials/sample_gamma
  module_root用work/frozen_module等独立根；禁真实插件清单。
- 全部条目先校验才筛选native；依赖名同严格str/name域，拒绝重复、自指、未在metadata声明中的引用。全声明图拒绝循环；native=true条目只可依赖native=true声明（不能依赖被过滤false项）。false项可依赖任意已声明项，但仍遵守全图无环。明确该依赖规则是新合同，SDK未实现该校验。
- 按metadata android原顺序返回仅native=true条目，dev_dependency=true保留。输出不依赖外部对象：name、project_name=":"+name、project_relative_dir=approvedPath+"/android"、build_output_relative_dir=moduleRoot+"/.android/plugins_build_output/"+name、dependencies tuple、dev_dependency bool、loader_binding_verified=False、runtime_ready=False。frozen/slots，字段无可变引用；调用后修改输入不改变结果。
- 复用现有词法helper，图检查保持有界/清楚（128项，无第三方）。没有settings/Groovy/POM/完整argv/工程/执行器，生产函数纯内存标准库，无宿主访问。
注释引用M5-21 loader:16–33、native:33–68并列出自有严格差异，保留原编码/recipe/BuildInfo/topology行为。

必要测试（固定人工fixture）：
两native插件依赖边、true dev保留、false gamma结构有效但过滤、顺序非拓扑排序保留、空android；完整固定路径/output/false标记、frozen/输入修改不影响。
缺平台/键、未知键、容器/标记/依赖元素错类型、native缺失/错类型；重复/保留/unknown名，approved tuple结构/重复/路径重叠与module交叉/合法相邻前缀；path不匹配/逃逸；悬空/自指/重复/循环（包括false条目）、native依赖false、false条目错误仍拒绝；128项边界/129拒绝、位置/缺/未知参数拒绝。原22方法同次回归，subTest不夸大计数。

新一次性预算：
1 实现后准确两文件静态1次（内容/import/hash/空白/禁止宿主调用），失败即停不测试。
2 一次固定Python进程 C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe
-I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_material_functions.py
cwd D:\EliteSync-v10；硬60秒、异步stdout/stderr各32KiB；超时/超限/非零即停，不修复重跑。仅准确module加载，无其它项目文件/env/子进程，不pycache。验证前可静态编辑；首次验证后不修源码。
summary记录差异/hash/真实次数/退出/测试数/流量/超时截断/剩余门，失败也交事实停Work独立LEVEL2审查。不自接受/后继/commit/pull/push。

禁SDK/Flutter/Gradle/JVM/ADB/构建安装/复制下载/生成目标/UAC、旧D:\EliteSync、真实properties/json/plugin源码或目录/用户配置/cache/env、真实数据/备份/密钥/DB/SSH/API。M5/隔离构建NOT_READY，所有真实性/恢复门保持；人工fixture不是插件审核或依赖闭包证明。