# v10.1.2 临时脱敏审阅副本

固定产品源码：ebade52179b6ac7b76ba2f2992d31981fa995a00。

本目录仅供 Astra 独立验收，禁止合并 main 或产品分支。所有本机运行均 CODEX_REPORTED；副本可在 GitHub 直接读取，不表示 Astra 已独立重跑。原始 SQL、APK、私密配置、账户/凭据、完整响应、设备日志、截图及 XML 保持 LOCAL_ONLY。

`runs.json`保留实际退出码，`streams`保留最少原stdout/stderr并替换机器路径；`matching-failure-observed` exit0 但 stdout FAIL，是故意生成的持久失败及 retry 场景，不能算成功。`expiry-terminal-cn-before-fix` exit0：标签不构成复现失败。

`results`保留 RR 实际锁等待及提交屏障、并发结果、到期和重启摘要。授权数据响应正文不上传。`http`仅为原回执的操作/状态派生索引；`app`仅为实际设备 UI accessibility 描述派生副本，不上传输入值或截图。脚本读取的 private 输入从未纳入此目录。

`manifest.json`分别登记原件与副本 SHA256、字节数和变换方式。派生摘要不是未改字节的原始响应。清理需独立具名任务，本次不清理。
