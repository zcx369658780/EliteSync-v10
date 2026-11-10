# AUTH-165｜一次性隔离恢复目标路径与 ACL 预期合同

状态：`ISSUED`；风险 LEVEL 3；**本轮 docs-only**。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一主要交付同目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 固定入口与来源

先核对 `D:\EliteSync-v10` 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区和当前任务。只读根治理文件、本地 workflow 技能、AUTH-153 `plan.md` 尾部接受、AUTH-154/155 的 `plan.md`/`work-review.md`、AUTH-164 `plan.md`/`work-review.md`。只使用 AUTH-155 已命名的**字面候选路径** `D:\EliteSync-v10-Restore-Isolation-20260927`；本轮不调用 `Test-Path`/`Get-Item`/`Get-Acl`/`whoami`，不观察该目录或其父目录当次状态。不得搜索其他路径、访问备份/密钥或旧 `D:\EliteSync`。

## 唯一交付 `plan.md`

1. 将一次性目标的精确字面路径、预期用途、与仓库/备份目录分离、无同步/重解析/共享、目标不存在时才可后继创建、空态和清理责任写成**候选预期**；不声称路径当前存在/不存在、父卷格式、空间或 ACL。任何路径冲突、重解析或未知同步即停，不改名绕过。
2. 给出 ACL **预期比较合同**，而非实测 ACL：主体应按稳定 SID/身份类别表达（Owner 登录身份、SYSTEM、受控管理员等是否允许须列为 Work/Owner 待审选项），拒绝 `Everyone`/普通用户/继承的宽授权，明确继承、所有者、审计/备份主体、管理员特权不能简单由 DACL 排除的限制。不要臆造本机 SID、Owner 账号名、精确 DACL 字符串或声称本机有效 ACL PASS；必要的主体选择留给 Work/Owner。
3. 写出后继**单独派发的只读预检**所需的有限结果：目标/父路径普通文件或目录身份、重解析、规范绝对路径、卷类型/空间/同步边界、预期 SID 与实际有效 ACL 的安全比较、是否触发 UAC、输出仅布尔/类别且无原始 ACL/路径展开。固定失败状态 `MISMATCH/UNKNOWN/ERROR` 及停止条件。AUTH-163 的监督器已被 REJECT，故不提供可直接运行的命令或复用 AUTH-155 候选表达式。
4. 将候选 ACL/路径合同与真实恢复隔离其他硬门分开：它不能证明 Docker 无自动启动、镜像摘要、资源限额、防 pagefile/WER 落盘、CMS 认证 0/0 或明文可恢复。若仅凭固定来源无法确定 Owner/SYSTEM/管理员的必要性或有效边界，明确 `NOT_FIXED`，不要自行升级为执行许可。

最多两轮固定来源静态核对；仅新增 `EVIDENCE/AUTH-165-RESTORE-TARGET-ACL-EXPECTED-CONTRACT/plan.md`。记录实际来源、预算、`NOT_RUN` 与回退仅撤销本文件。不运行测试/构建、PowerShell 现场命令、ACL/文件元数据观察、Docker/WSL/VM、UAC、备份/密钥/CMS、SSH/云/DB；不创建或删除目标，不提交、拉取或推送。保留原有工作区内容。作者停 Work LEVEL 3 ACCEPT/REJECT，不自接受或启动后继。
