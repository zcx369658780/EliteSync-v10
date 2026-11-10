# v10.1.5 前台观察器主机修正、接续范围已准备｜2026-11-10

Owner要求继续，并观察手机已在APP登录界面。本观察作为Owner事后报告保存；它不改写旧010焦点输出UNKNOWN，也不是已STOP范围的重新运行批准。已核产品分支、origin、HEAD与空index，起点168beeb5e01b697d6e0a5fe42ba42d6b1acdcdaf；无关`%SystemDrive%/`不动。本轮仅新私有HOST_ONLY副本普通工程，无设备、模拟器、构建、安装或后端命令。

## 修正与证据

旧代码发出`dumpsys window windows`却要求`mCurrentFocus`。核对[AOSP Android 12 WindowManagerService](https://android.googlesource.com/platform/frameworks/base/+/refs/tags/android-12.0.0_r1/services/core/java/com/android/server/wm/WindowManagerService.java#6548)后确认，`displays`与`windows`走不同dump分支；[DisplayContent](https://android.googlesource.com/platform/frameworks/base/+/refs/tags/android-12.0.0_r1/services/core/java/com/android/server/wm/DisplayContent.java#3195)在显示状态中打印该字段。新查询改为`window displays`，不再把字段缺失直接当作非目标APP并尝试启动。

这是已证实的源码命令/字段契约问题，尚不是原Redmi本次精确根因证明：未重新查询设备版本或厂商实现，旧008/010 raw window未存，可能的实际返回无法补造。新设备资格仍须fresh验证；字段缺失、null、歧义或格式不符一律拒绝，不用Owner报告或其他字段代替本APP焦点。

新焦点记录仅保存TARGET、NON_TARGET、MISSING、NULL、AMBIGUOUS、MALFORMED分类、记录数与目标布尔值，不保存foreign package、窗口标题或raw输出；严格限定user0和完整目标package。只有明确NON_TARGET才允许一次已批准的组件启动；TARGET不重启，其他不确定情况停止。Activity wait状态另保存脱敏语义，不将wait ok/timeout视为APP ready。

清理所有权推迟至UI dump派发前，实际main还使用Commands中的真实派发标记。首次focus失败或dump派发前STOP不做删除；已经派发的dump即使超时仍清理可能生成的自有文件。清理异常以独立cleanup_errors附于主异常，不再覆盖首发失败；成功流程清理失败仍不得返回资格通过。旧冻结源码/STOP/失败原证不改。

## 检查与范围

新副本先RED复现旧清理/焦点契约缺陷，再GREEN通过28项唯一主机测试；含真实main下的首次focus拒绝、dump前STOP、dump超时加清理失败、失败与真实耗额保存，以及旧59/181预算锚、完整manifest与批准目录绑定。两处原缺陷分别在临时副本变异，回归均按预期失败。中间41次运行日志含15项重复导入，已修测试发现方式并保存日志；最终唯一测试数是28，不声称41项。未重跑旧产品、native或Android验收。

非作者Codex完成最终源码、真实入口测试及候选配置只读复核，未发现剩余P1/P2；未代跑测试、不属于外部验收或真机验证。旧未识别缺陷的审查原件和本次修正记录分别保存。

最终接续候选冻结在新包唯一`execution-01`，无grant/claim；实际main因缺授权拒绝，准备根HOST_ONLY保持。拟原固定Redmi/user0/同已装b621，120秒工作＋15秒清理、最多24条ADB（普通22、预留2），从59/240接续，最多累计83、至少余157。先核同机/包/亮屏解锁/scope路径不存在，再以新查询fresh核目标APP及空登录表单，必要仅一次观察到的空手机号tap；只有明确非目标前台才最多启动一次固定APP组件。

不截图、输入账号、提交登录、操作媒体、安全解锁、force-stop、安装或更改权限；模拟器/后端/构建与额度转交均0。成功失败均STOP。Owner已有一般APP/UI控制权，不重复申请；这个新的设备具体范围仍待准确批准，不能凭“继续”、Owner事后观察或余181复跑旧STOP。原唯一未耗后端1仍封case05/backend，不消费/转交，也不重复申请该次数。激活只新增绑定此proposal hash的单次grant，不改入ledger原证。

## 保存与状态

修正和新候选均保存在私有`v1015-foreground-observer-host-repair-20261110-case01`，读取其HANDOFF_PROMPT.txt、IMPLEMENTATION_REPORT.md与final-local-github-receipt-private.json；它们属于新prepared状态，不覆盖上次execution-01/runtime-closeout终态。本轮ledger从27001仅追加新增原证，不重扫旧SDK/AVD/Sources或重哈希运行镜像；GitHub仅本节点与三个当前摘要，不上传脚本、配置、原始日志、AOSP源/许可证、设备身份、APK、截图、凭据或SQL。

产品源码1f936d253dbccceb2c719ea16de4f25be2789b4d及已装b621不动，手机仍59/240余181。仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING，双端/媒体NOT_RUN、缓存真机UNKNOWN。功能优先/UI最后保持；原main根255项/index、无关目录、历史ledger/STOP/数据库/备份/worktrees不动，不合main、发布或启动v10.1.6。
