# APP-M5-14｜准确AAR参数、define编码与发布脚本来源

ISSUED；LEVEL2，DOCS-ONLY。Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad（最新已交接，local/D:\EliteSync-v10，Sol/medium）。main HEAD cf8bfaa4a03b8c9a682105617b185141904413be，保留dirty/untracked。先读根authority/local-workflow、M5-13 plan/work-review；其2/2预算已关闭，不复用。此新任务仅针对之前缺行/未读的准确来源事实，明确新预算，不重新执行M5-13两轮发现。

唯一新增本目录plan.md。新只读预算一次批量，固定如下3官方源文件；每文件一次读入内存、一次hash，不搜索/索引/重读，不跑SDK：
1 D:\flutter\packages\flutter_tools\lib\src\android\gradle.dart，仅输出第770–870行（涵盖完整AAR参数追加及run参数）及准确hash。
2 D:\flutter\packages\flutter_tools\lib\src\build_info.dart，仅输出1080–1110行（define编码完整定义/上下文），若编码器定义未在该范围内则UNRESOLVED，不扩读。
3 D:\flutter\packages\flutter_tools\gradle\aar_init_script.gradle，此路径由Work此次明确授权，不以旧缺失根构造段作为定位证明。仅输出准确发布/输出/POM/GAV/插件发布相关完整语义段及hash，最多160行；脚本不存在或超过可覆盖范围记MISSING/UNRESOLVED，不枚举替代路径。

输出预算控制：三个hash与存在/读取状态先完整回显，完整批量stdout文本最多12KiB；excerpt总量超限时选定点语义范围并明确哪些未回显，不打印整SDK或大文件。工具回显max_output_tokens至少覆盖该小输出。没有source执行/编译/测试预算。读取或证据失败停，不重跑。可复用M5-13已保存回执定点上下文（不是SDK重读），不访问其它SDK文件/模板/配置/cache/properties。

plan要求：
- 准确静态构造一次debug AAR实际argv清单与cwd/env项，区分SDK源码会添加的参数、默认值和拟议受控覆盖；串接BuildInfo.toGradleConfig的事实须来源支持，没出现的不能补。标出wrapper、Java/父env与重试行为未闭合门。不是GO命令，不实际运行。
- define编码算法的具体输入字节/编码/分隔规则及边界，单一synthetic=true怎样编码，给无需宿主访问的未来纯函数接口；本任务不执行算法测试。
- aar_init_script发布group/artifact/version/buildNumber、输出repo和POM/依赖发布规则的实际代码关系，区分root buildDir vs最终output；不把它与尚未读的module模板行为混同，不假称已存在AAR。
- 三sourcehash与行定位、覆盖到的/未覆盖到的精确事实，拟议GAV如何基于真实输出合法重发布或是否可以直接采用唯一输入ID版本；坐标只作设计，不证明字节身份。
- 唯一建议下一软件切片：在已有SOURCE-ONLY根增加具体纯函数/静态生成器接口与准确文件清单、负向case及必要新预算。应产生可审查配置/参数材料，有可独立核验的新规则；不要只增一份始终拒绝器。完整模板/输入/依赖/自动配置/系统隔离未闭合时仍不得复制/启动工具或解除现有settings/v1拒绝。

此新预算仅一次三文件定点读取，旧2/2不重置；不会取得构建授权。禁止文件复制/模板生成落盘、Gradle/Flutter/Python算法验证/ADB/构建安装/材料下载、SDK或现有源码修改、未知SDK/cache/config/用户home/真实properties/备份/密钥/DB/SSH/API/UAC/旧D:\EliteSync/Git动作。唯一plan交付停独立Work审查，不自接受/创建后继。M5与隔离构建仍NOT_READY，真实账号/Conversation/G08/G11/恢复门与各旧预算保持。
