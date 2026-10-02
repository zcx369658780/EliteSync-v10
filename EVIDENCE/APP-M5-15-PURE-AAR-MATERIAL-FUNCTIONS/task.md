# APP-M5-15｜纯 AAR 编码与发布材料函数

ISSUED；LEVEL 2；SOURCE-ONLY。Assignee：Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，GPT-6.1 Sol / medium。
先核根authority、Git和local-workflow；M5-14已DOCS-ONLY ACCEPT，旧预算不重置。保留全部既存dirty/untracked，不提交/拉取/推送。

## 精确写入范围

仅新增：
- apps/android_synthetic_demo/tools/aar_material_functions.py
- apps/android_synthetic_demo/tools/test_aar_material_functions.py
- EVIDENCE/APP-M5-15-PURE-AAR-MATERIAL-FUNCTIONS/summary.md（主要交付，附测试回执/源码hash）

任一目标预先存在则停，不覆盖。可读根authority、上述目标与M5-14 task/plan/work-review；无需读取SDK或其它源码。源码保持薄切片，生产函数只使用标准库、纯内存字符串，不访问文件/环境/SDK/cache/网络、不启动进程。

## 准确行为

1. encode_dart_defines(values: tuple[str, ...]) -> str：严格tuple和每项str；逐项UTF-8、标准Base64、ASCII逗号连接，保序、保留重复/padding，不trim/排序/去重/规范化；空tuple返回空字符串。孤立surrogate拒绝（ValueError），类型错误TypeError。不声称覆盖全部Dart异常字符串行为。
2. synthetic_define_argument(defines=("ELITESYNC_SYNTHETIC_DEMO=true",)) -> str：仅接受准确单项tuple，返回唯一-Pdart-defines=<编码>。空、额外、重复、false、冲突、非tuple拒绝；通用编码器仍允许重复。
3. publication_recipe以keyword-only参数接收base_group、base_artifact、publication_name、component_name、base_version、build_number、output_root，返回frozen immutable record。所有字符串严格str；build_number仅None或合法非空str。
   - component_name仅准确debug，task_name为assembleAarDebug。
   - artifact_id准确为base_artifact + "_" + publication_name，publication_name独立输入，不默认等于component_name。group_id沿用显式base_group。不推断模板默认坐标。
   - project_version_proposal先base_version.replace("-SNAPSHOT","")，build_number非None时再覆盖；覆盖值中的-SNAPSHOT不再次去除。校验转换后版本非空。字段明确只是project版本提案，不证明实际pub.version/POM绑定。
   - repository_relative_path为output_root + "/outputs/repo"，只表达词法材料，非实际URI/绝对宿主路径。
   - 字符域收窄：group每段ASCII字母或数字开头，其余ASCII字母数字下划线连字符；点分段、无空段。artifact/publication每项ASCII字母数字开头，其余ASCII字母数字下划线点连字符。version同域允许加号。output_root为非空canonical POSIX相对路径，每段ASCII字母数字开头，其余ASCII字母数字下划线点连字符；拒绝空段、"."/".."、反斜线、冒号、绝对/drive/UNC、尾分隔符。不做resolve/stat。
   - record明确runtime_ready=False、publication_binding_verified=False；来源注释引用M5-14/准确SDK行，不新增执行准入器或完整argv接口。不生成POM/依赖映射、shell命令或运行器。
4. 不改既有v1 validator/build-contract/settings/host，现有全拒绝保留。

## 必要测试与新预算

固定独立向量："a"→YQ==；"bc"→YmM=；("a","bc")→YQ==,YmM=；"é"→w6k=；"😀"→8J+YgA==；"a,b"→YSxi；"a="→YT0=。
覆盖空、顺序/重复/padding、surrogate/type、synthetic空/额外/重复/false/冲突，publication_name与debug组件不同，SNAPSHOT替换和覆盖顺序，None/空/非法类型、组件/字符/路径边界、record不可变。预期非仅roundtrip。

新验证预算：
- 实现后一次准确两文件静态检查（内容/hash/空白与禁止宿主访问检查），无外部工具/SDK。
- 一次纯标准库测试进程：
  C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe
  参数 -I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_material_functions.py
  cwd D:\EliteSync-v10；硬60秒，两路各32KiB上限；超限/超时/非零立即停，不能修复重跑或额外测试。测试前可静态编辑；第一次测试后禁止修复。
测试准确加载同目录module（-I不会自动加入脚本目录），必要importlib/sys.modules仅为加载准确两文件。测试禁止读其它文件/环境或启动子进程，-B不写pycache。进程及监控由Codex控制；不要打印长代码。

summary记录源码hash、静态与测试实际结果/退出码/次数/截断超时、剩余门；预算失败也交付事实并停独立Work LEVEL 2审查。不自接受、不创建后继。
不访问旧D:\EliteSync、用户配置/真实properties/cache、备份/密钥/DB/SSH/API/UAC，不复制/下载/构建/安装/ADB/运行应用。M5与隔离构建仍NOT_READY，所有真实性和恢复门不变。