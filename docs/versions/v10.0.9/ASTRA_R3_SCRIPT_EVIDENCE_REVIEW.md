# EliteSync-v10｜v10.0.9 R3 四规则网络脚本审查：文档一致、源证待核

2026-10-16。**R3_DOCUMENT_REVIEW_PASS / R3_SOURCE_VERIFICATION_PENDING / OWNER_REAL_NETWORK_AUTHORIZATION_NOT_ISSUED_IN_THIS_REVIEW / AC-09-03 NOT_PROVEN / V10.0.9 NOT_ACCEPTED / NO_K08 / NO_NEXT_VERSION**。

## 本次Astra确实读取和核验的范围

Owner将三份R3材料实际上传到本会话，Astra直接读取它们的字节：

- `SCRIPT_SAFETY_REPORT.md`：8063 bytes，SHA256 `f479d9ec8e0697db8b5aec4073b6db726c75e28388f8857666f74c963c962eca`；
- `SHA256.json`：1955 bytes，SHA256 `74d82c7a81889c10727e8367e4a6d081be624746070e16efb4e31fb9f2d138e2`；
- `NEXT_OWNER_AUTHORIZATION_DRAFT.md`：4697 bytes，SHA256 `2f5186cbab114a75e83d78d22c918a02bb9dcdc785817a0e13eb60d65b0207a7`。

文件级哈希字段完整为64位小写十六进制；12份文件清单包含准确7份运行文件，且运行文件哈希在`files`与`live_bundle`两处完全一致；`live_bundle_sha256`在三份文本中一致，均为`abff4948f8cb18e11b3b8c3c5efd3e776d48946a36ae3f55637f022b9f1b1425`。报告内具名适配器测试场景逐行计数37，与37/37汇总一致。

报告与草案的四条规则名称/动作/端口完全一致，分别是`7881/TCP` Block/Allow与`7882/UDP` Block/Allow；范围仅原指定WLAN/宿主地址、63项Block互补地址和3项Allow精确来源。两者都保留run ID/一次性授权/STOP隔离/最大1200秒及提前240秒清理；失败收口和残留/UNKNOWN的非零结果有明确合同，不改变冻结AC。

Codex报告原核心回归48/48、真实适配器离线矩阵37/37、启动器WinAPI替身5/5、静态解析Python9/PowerShell3，顶层exit0；非作者审查无阻断；系统真实只读四名查询0，exit0；无提权、真实NetFirewallRule写入、服务/APP启动、音频或设备操作。**这些运行结论属于CODEX_REPORTED**，不是Astra重跑或现场Windows验证。

## 独立验收仍未闭合的源证

本轮仅上传了三份汇总文件，**没有**实际运行的7个源码文件、模拟/启动器测试脚本、逐场景原始stdout/stderr/exit、`audit/INDEPENDENT_REVIEW.md`或完整差异文本。哈希清单中的条目不是这些文件本身，故Astra尚不能从原始字节重算脚本哈希、直接审查危险系统命令实现或独立验证48/37/5的运行路径。不能仅因报告自称独立审查就把源证验收为已完成。

**结论：R3文档/合同一致性PASS；真实四规则脚本的安全源码终验PENDING。** 本结论不是脚本被证明不安全，也不是拒绝已完成的工作，只是公开可见证据不足。尚不签发本轮真实UAC/网络/麦克风操作授权。原产品R1-1、R1-2继续关闭，不重做；AC-09-03真实同一call双向人工可辨仍NOT_PROVEN。

## 下一步：按Owner已授权的短期审阅协议补最小资料

参照[临时审阅材料协议](../../workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md)，Codex将**经逐字脱敏且可以在公开仓库展示**的7个实际脚本、5个辅助测试脚本、必要退出证据、独立审查及差异文本放入新建的独立`review/temporary-evidence-v1009-r3-<id>`分支`docs/_temporary_review/v1009-r3-<id>/`，不入main或开发分支，固定分支HEAD/Commit/Tree及文件blob/SHA。纯本地原证目录仍为untracked/LOCAL_ONLY，**GitHub远端材料必须短期Git跟踪，否则Astra无法读取**。若代码无法脱敏到适合公开，就停止上传，改走Owner上传或经批准的私密传递路径。

Astra取得源证后作一次集中源码安全核验。最终决定完成后，先保存必要非敏感结论，再在可用工具权限内删除临时文件并请求Codex精确删除该远端审阅分支、读取确认。此操作不能保证从Git历史/缓存完全擦除，因此任何敏感原证从一开始就不能上传。**独立源码核验通过≠Owner已批准系统提权；真实20分钟音频窗口仍须下一次明确授权。**

当次开始核验GitHub开发候选为`70612d36652660e8bdd9d12017c1254ada686298`，此前Astra独立审查main为`631a62015c1645e17b492391dc4281efbf4f362d`；本次工作流文档提交为纯文档，不代表0.9产品已集成或K08。

无论如何，不自动合main、改`acceptance.md`、执行K08或启动后继版本。
