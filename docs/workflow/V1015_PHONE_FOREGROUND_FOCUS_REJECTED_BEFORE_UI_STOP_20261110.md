# v10.1.5 手机前台焦点门在UI前拒绝、一次范围停止｜2026-11-10

Owner准确批准已冻结的手机前台资格范围，并报告手机已亮屏解锁。执行绑定唯一execution-01根、proposal hash与单次grant，仅新增授权和运行记录；准备根HOST_ONLY、已入ledger源码与配置以及全部旧STOP均未改。

## 实际结果

原固定Redmi、user0、已装同b621包hash、亮屏及未锁检查通过。唯一scope XML路径在第007条证不存在；第008条前台解析未通过，按批准发出一次明确EliteSync组件Activity（第009条、exit0，wait状态通过ok/timeout语法门）。第010条fresh焦点解析仍未通过，立即进入停止清理，没有发出UI dump/read、截图、tap、输入、登录或媒体动作。

本次第010条的确切前台package、是否缺失/歧义focus记录以及为何APP焦点未获认可均UNKNOWN。window和Activity原始输出未保存，不能区分真实非目标前台、过渡态与解析适配问题；不能将exit0或wait语法门当APP ready，也不能将本次拒绝判为产品功能故障。

本次11条ADB，phone旧48＋本11＝59/240，余181；同域monotonic从scope起点至含清理终态7.219秒。runner实际exit1（外层保存脚本exit0不代表runner成功），scope成功/失败均停规则已落实，本次为STOPPED_FAILURE，不重试。

## 清理异常及局限

第011条唯一自有UI路径清理命令exit1，因此清理未核实成功。源码在调用observe前就将owned_ui置true，实际在observe内第一个focus门便失败，根本没有发出UI dump。尽管此前已证明路径不存在，仍进行了不必要的删除尝试。清理异常在finally中覆盖了首个焦点异常；完整私有stderr保留两段因果，不能只按最终错误忽略第010条。

没有发出创建该UI文件的命令，也没有任何UI原文被读取或保存；但不把第011条exit1改写成清理成功，具体stderr未保存，不能断言其确切系统错误。未追加任何设备核查或清理命令，不以余量复活当前STOP。

非作者终态复核确认上述因果，并新发现原候选P2：清理所有权置位过早、清理异常覆盖主失败，缺少“启动后首次focus拒绝”的回归路径。上一次准备期审查没有识别此问题；旧无剩余P1/P2审查记录原样保留，本节点追加纠正，不将其冒充已修复或外部验收。

## 权限与后续

模拟器启动/安装、手机安装、构建、后端claim/启动/额度转交均0；原模拟器已耗额度、唯一未耗后端1及case05/backend STOP不变，不重复申请同一未耗后端次数。准备根、clock-integration HOST_ONLY与全部历史原证保持。本次没有新动态候选。

下一普通工程应先在新HOST_ONLY副本修正清理所有权时机和主异常保留，并用纯主机回归覆盖“focus失败发生在首次dump之前”的路径。前台观察应提供不保存raw window/foreign UI的分类证据，核实当前window命令与解析契约；没有证据时不猜手机前台package或盲改产品。任何后续设备接续仍需新准确范围，不能重跑本次入口；本轮保存后停止，不自动开展下一候选。

产品源码仍1f936d253dbccceb2c719ea16de4f25be2789b4d、同b621已装包不变；10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING。真实APP前台/空表单/手机号焦点未证，登录/双端/媒体NOT_RUN、缓存真机效果UNKNOWN。功能优先，UI最后顺序不变。

最新私有终态在手机前台工程包execution-01/runtime-closeout-20261110，读取其HANDOFF_PROMPT.txt、IMPLEMENTATION_REPORT.md与final-local-github-receipt-private.json；准备根同名文件仍为运行前prepared保存，不覆盖、不当本次终态。ledger仅追加本次新记录，旧SDK/AVD/Sources和运行镜像不重扫/重哈希。公开仅本节点和三个入口/进度摘要，不上传私有源码/配置/日志、APK、截图、凭据、许可证或SQL。不合main、发布或启动v10.1.6。
