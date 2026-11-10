# DOT M112 launcher 基线适配｜SOURCEONLY候选

Status: CANDIDATE_PENDING_INDEPENDENT_SOURCE_REVIEW。父dot批准此次两处基线适配；非运行许可，作者不自接受。父会话随后安排独立源码审查，再正式为M112固定新命令/预算。
当前HEAD仍4f5bea7e558bc15d24ce45d3e4704ac658906a38；无commit/push。M112维持PREPARED_NOT_ISSUED；JVM/外部189读取/候选parser/installer执行0。

## 唯一改动与精确身份

原件：EVIDENCE/APP-M5-117-SYNTHETIC-HARNESS-LAUNCHER-SOURCE/Invoke-SyntheticInstallerTest.ps1，M118接受原件21223bytes / 23A839B86195B28E3C86940BAF8B38A1610B8C2E007F18748EC7C32978FEC5FC，绝不改写。
候选：本目录Invoke-SyntheticInstallerTest-Baseline.ps1。
121行当前git HEAD比较、122行snapshot.HEAD比较：各一次cf8bfaa4a03b8c9a682105617b185141904413be→4f5bea7e558bc15d24ce45d3e4704ac658906a38。两边均严格固定同一实际基线；没有任意HEAD/跳过identity/忽略差异。
理由：治理提交与准备文档合法进入现工作区，原源码旧HEAD门必然拒绝。仅替换这两处同长度40字符字面；总bytes不变，完整inverse恢复原全文，除两行之外每行原字节不变。
原源码没有自引用launcher路径/hash，不存在其他必要源码引用修改；候选身份仅本说明提供。M112 authority仅14键且不含launcher字段，保持原准备值不动；task原冻结命令仍禁止执行，父接受新源后再正式更新准确引用。

## 静态其他绑定与保留门

- Repo D:\EliteSync-v10/main与当前prepare snapshot.HEAD均固定4f5bea7。prepare snapshot.Count=9/Paths9，原Paths当前缺0；新候选目录只是新成员，原WORKSPACE_MEMBERS门是旧成员包含核对，原样保持，不改为忽略缺失。未发现因此次合法准备变化而必然拒绝的其他snapshot绑定。
- OutputRoot仍准确M112根；stdout.bin/stderr.bin/probe-wrapper.json/cwd/tmp/user-home/appdata/localappdata/gradle-home槽均未存在；准备task/authority/snapshot/result文件不在原输出禁止重用表内。未新增输出路径适配。
- authority.Status=PREPARED_NOT_ISSUED、OwnerAuthorization=PENDING_PARENT_DOT_RUNTIME_RELEASE，当前必然拒绝ISSUED/marker门是正确安全封闭，不是待修缺陷。父正式运行放行后才可改变；本任务不改。
- M84/M85/TSV/Java/InputRoot固定来源及14键guard、189fresh/单JVM/14case/streams/timeout/cleanup/输出/firstfail全部原文保持。真实binding/SDK/OS硬截止/文件网络隔离/implicitloads限制不变。
- 本候选仍固定4f5bea7；若运行前HEAD再次前进，该门会正确拒绝，不能自动补适配或重置预算。新task/命令不得在准确基线不符时发布运行。
- 行政格式/结果处理纠错2/2（已耗尽）：第二次为收尾检查误把git --no-index --check的exit1当失败；原调用无诊断输出，本次核exit1/diagnostics0，表示有差异且无whitespace报告，不称exit0。仅修正治理核验判读与本说明，候选不重写。第一次：首次生成治理命令在PowerShell解析阶段因说明Markdown围栏转义失败，工具ParserError/exit1；宿主主体未执行、文件读写0。本次修正仅围栏表达，不计任何候选运行；候选parser/JVM/外部读取仍0。无新技术路线、不重新审查全部历史、不重开任何旧拒绝预算。M118 SOURCEONLY原接受保持；候选自身待非作者源码审查，NOT_READY/PAUSED及Owner门不变。

## 原始完整文本diff（git --no-index --no-ext-diff --no-textconv，exit1表示有差异）

```diff
diff --git a/EVIDENCE/APP-M5-117-SYNTHETIC-HARNESS-LAUNCHER-SOURCE/Invoke-SyntheticInstallerTest.ps1 b/EVIDENCE/DOT-M112-LAUNCHER-BASELINE-ADAPTATION-20261002/Invoke-SyntheticInstallerTest-Baseline.ps1
index 11c7ca4..e666b6a 100644
--- a/EVIDENCE/APP-M5-117-SYNTHETIC-HARNESS-LAUNCHER-SOURCE/Invoke-SyntheticInstallerTest.ps1
+++ b/EVIDENCE/DOT-M112-LAUNCHER-BASELINE-ADAPTATION-20261002/Invoke-SyntheticInstallerTest-Baseline.ps1
@@ -118,8 +118,8 @@ try{
     $phase='WORKSPACE'
     $snap=ReadText ($base+'\workspace-before.json') 262144|ConvertFrom-Json -AsHashtable
     if((Get-Location).Path-ne'D:\EliteSync-v10'-or(git branch --show-current)-ne'main'-or
-       (git rev-parse HEAD)-ne'cf8bfaa4a03b8c9a682105617b185141904413be'-or
-       $snap.Branch-ne'main'-or$snap.HEAD-ne'cf8bfaa4a03b8c9a682105617b185141904413be'){throw 'WORKSPACE_IDENTITY'}
+       (git rev-parse HEAD)-ne'4f5bea7e558bc15d24ce45d3e4704ac658906a38'-or
+       $snap.Branch-ne'main'-or$snap.HEAD-ne'4f5bea7e558bc15d24ce45d3e4704ac658906a38'){throw 'WORKSPACE_IDENTITY'}
     $now=@(git -c core.quotepath=false status --porcelain=v1|ForEach-Object{$_.Substring(3)})
     if($snap.Count-ne$snap.Paths.Count-or@($snap.Paths|Where-Object{$_ -notin $now}).Count-ne0){throw 'WORKSPACE_MEMBERS'}
     $authorityVerified=$true
```

## 候选SHA-256

21223bytes / 1BD80E130718971FFF7FCA259CDE107A6439575D4C7D5F6D62D6F27EAFB9C7D2

检查：字面原2/新2；变化仅121、122两行；全文inverse=true；新成员不删除原snapshot路径；只新增候选与本说明两文件。无运行回执，语法与行为未重新实测。
