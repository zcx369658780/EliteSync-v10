# v10.1.5 连续范围在模拟器创建前主机绑定拒绝，已完成主机修正｜2026-11-10

Owner准确批准case01完整连续范围后，主入口只运行一次。手机前置实际APP/可见空登录资格通过；模拟器控制器在创建模拟器进程前，因仍绑定旧case05工作目录及自身路径而退出。这是本次整合遗漏，原99项Python与6项时钟纯检查没有覆盖真实构造器，不是APP或手机故障。旧准备期无剩余P1/P2审查保留原文，本节点追加纠正。

## 实际终态

手机预检10条、清理1条，共11条；旧76＋本11＝87/240，余153。无手机号tap、Activity、输入、截图、登录或媒体。模拟器控制3条：私有ADB启动、只读boot查询、私有ADB关闭；没有模拟器进程、同包安装或APP Activity。

native controller exit32，输出明确`root_create_attempted=false`、`sdk_start_observed=false`，原因是旧case05自身路径绑定。controller退出后，root立即进入并发收尾；runner1，整段含清理11.656秒。启动claim已写且记已耗1、余0，保留不退款；安装未claim，原额度余1；后端已按批准从case05独占转交case01，但未claim/启动，原额度仍余1，case01/backend现STOP。

手机自有XML删除exit0、私有ADB关闭exit0、E自身cleanup_errors为空；主机核私有5076/5596/5597关闭，共享5037未kill或额外探测。root原`cleanup_errors`数组另含controller/driver失败标记，原样保留；这些是执行失败标记，不改写为实际删除命令失败或把本次说成成功。所有旧STOP和证据保持，没有重跑旧入口。

## 已自主完成的修正

按Owner整段连续推进决定，普通主机修复没有再次派小步骤请示。新case02只做HOST_ONLY工程：保留严格绑定，将控制器自身路径、工作目录和cwd更新至唯一case02位置，并重新编译本地主机控制器；APP未重编，手机未重装，旧case01源码/二进制不改。

生产控制器新增只读构造器自检模式：仅构造对象、验证身份/命令/cwd/nonce/env，不调用PrepareWorkspace、CreateJob、ProducerBoundary.Start或创建SDK根。使用实际生产binary、实际路径复现旧绑定RED（exit31），修正后5项真实构造器检查GREEN，RootCreateAttempted=false；同源6项原QPC时钟检查通过。该自检已接在手机操作与启动claim之前，同类主机拒绝今后不会先消耗启动次数；原case01已耗不追溯退款。

case02的102项Python主机检查通过，另含构造器前置拒绝不claim/不手机、原安装已claim或已转交时拒绝继承；普通等待、导航、亮屏与完整链自动衔接保持。新二进制、contract binary hash、内部payload、proposed grant和后端配置已全部刷新，72项输入精确闭合，非作者只读最终复核无剩余P1/P2；不是设备运行或外部验收。

## 整段接续候选

唯一新根`v1015-continuous-dual-chat-20261110-case02`已准备，尚无actual reply/request/grant/claim或两项父transfer。

- 仅需要新增模拟器**启动尝试1次**；安装**新增0、继承case01未耗1**，后端**新增0、继承case01原未耗1**，不重复申请已持有的未耗次数。两项继承都需精确父grant/request与单次独占transfer，旧STOP不复活。
- 手机从87/240余153续计，同一ledger；普通最多137、清理预留16。整段仍900秒及一次共享45秒清理，E控制120＋UI160≤280，原资源/数据保护保持。
- 准确批准后自动连续：主机绑定自检→手机fresh前台→模拟器OS/同包APP→两端fresh完整空表单/IME→两个虚构账号真实登录、双向文字及APP-family/MariaDB证据→退出和统一清理。中间成功不STOP、不逐动作询问。
- 不重编APP、不重装手机、不改权限/安全解锁，不做设备媒体/RTC、真实账号、外部服务或生产发布。普通亮屏与明确非目标时打开APP仍包含在完整范围内。

启动尝试已耗属于保留的一次预算边界，不能把“不要每操作停下”解释为自动新增次数。因此本次工程准备全部完成后，仅合并提出新的整段启动额度确认；未耗安装与后端不新增、不退款、不重复申请。

## 保存与状态

case01真实终态三件位于其runtime-closeout-20261110；case02根三件属于修正后prepared候选，两者分开，不覆盖旧准备原件。最终Git/ledger精确身份见各自final-local-github-receipt-private.json。ledger从27171仅追加case01新增运行原证、原case05实际transfer和新case02文件，不重扫旧SDK/AVD/Sources，不重哈希运行镜像；case01根创建为false，case02只生成AVD配置，均无运行镜像复制。

产品源码1f936d253dbccceb2c719ea16de4f25be2789b4d、已装b621、原main根255项/index及产品无关目录保持。10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING；双端登录/互发/媒体NOT_RUN，缓存真机UNKNOWN。功能优先/UI最后，不合main、发布或启动v10.1.6。GitHub仅脱敏节点/当前摘要；私有源、配置、日志、设备身份、APK、截图、凭据、许可证与SQL不上GitHub。
