# EliteSync V2｜完整会话 ZIP GitHub 二进制补传说明（2026-11-18）

状态：`FULL_ZIP_GITHUB_UPLOAD_PENDING / HANDOFF_DOCUMENT_UPDATED / NO_CODE_AUTHORITY`。

## 需要补传的完整文件

- 文件名：`EliteSync_V2_20261118_SESSION_HANDOFF_FULL.zip`
- 文件长度：`48346194` 字节（约46.1 MiB）
- SHA-256：`98b6c40c64468fa3482559d26c310c6c6929f74dd8cf22cb0d99a63e00221a2c`
- ZIP 本地校验：通过，可无错误解压，包含68项压缩包条目。
- 目标治理分支：`governance/home-matching-product-freeze-20261117`
- 建议仓库路径：`docs/workflow/handoff-assets/EliteSync_V2_20261118_SESSION_HANDOFF_FULL.zip`

## 当前状态不得误报

GitHub文字连接可操作文本与指定Base64 blob，但不具备直接从当前隔离容器路径上传48MB ZIP的文件上传接口；容器也不具备可用的GitHub外网连接/凭据。**尚未生成可核验的 GitHub ZIP 下载URL**。禁止在交接Prompt里粘贴猜测链接或宣称原件已远端归档。

已将这一情况写入 [正式会话交接 §9](../SESSION_HANDOFF_20261118_A66_REVIEW_PENDING.md)。

## 推荐使用具备权限的本地 Git 客户端完成（手动，保留本地未提交内容）

1. 把原始完整 ZIP 文件放入本地仓库下 `docs/workflow/handoff-assets/`。若只能取得小分卷，则先合并后验证 SHA-256，不能直接把分卷混当ZIP。
2. 在受控的本地仓库确认 `git status`、当前工作分支与实际 remote，确保没有覆盖未提交工作。切换或基于 `origin/governance/home-matching-product-freeze-20261117` 建立独立工作树，只对该治理分支写入。
3. Windows PowerShell：
   ```powershell
   $zip='docs/workflow/handoff-assets/EliteSync_V2_20261118_SESSION_HANDOFF_FULL.zip'
   (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
   ```
   结果必须完全等于上面的 SHA-256。
4. 执行受控 Git 文件添加/提交/推送，仅加入该 ZIP，不合 main，不更改 APP/API/DB。
5. 从 GitHub 该 ZIP 的 **实际固定提交文件**打开下载并再次核对字节与 SHA-256。只有核验 PASS，才将其实际 GitHub URL 补入交接文件、新会话 Prompt 末尾，并关闭 `FULL_ZIP_GITHUB_UPLOAD_PENDING`。

若由网页端直接上传，注意 GitHub 网页文件上传通常具有小于此ZIP的大小限制；推荐标准Git客户端，不要把ASCII Base64文本文件冒充ZIP原件。

## 其他边界

此项仅用于补齐顾问交接二进制资产；Owner并未借此授权Codex开发、运行设备、构建APK、修改APP/API/DB或合main。A6.6仍待Owner审阅；43份 PNG 原件的独立GitHub备份缺口另见[资产覆盖报告](../../../product/ELITESYNC_V2_DESIGN_ASSET_COVERAGE_20261118.md)。
