# M5-58 Work独立LEVEL2裁决

2026-10-01 REJECT/CLOSED SOURCE-ONLY CANDIDATE。原候选保留，不编辑，不执行或追认。

主Work取回同次native turn01a0f4c9-a2ef-7e93-91c5-0410b4022d83：
- A exec-3a5d5cfd-4127-44d3-9531-3c13e0b0fb34 exit0，完整857字符含CRLF，truncated=false；三来源读取3，输出身份/count/Phase-Result-Budget，Execution0。
- B exec-6c822686-50ad-44de-a4d2-638ca7f24151 exit0，完整895字符含CRLF，truncated=false；两候选读取2/来源材料读取0，Status213/旧212缺0/ParserScriptExecution0。
- native显示转义包装命令长度A2930/B2831字符，均≤8KiB；作者summary报告未包装A2756字符。不能混用两长度口径。
- 原A JSON与summary所存逐字相同；候选Check-CrlfContract.ps1 13604bytes/A5FF5D6859E2B9F4EC308D72FD6326E341BDA96EA8A5CCDD9EDFA53CD3824366；summary3493bytes/55362B3F9AD17A681DDDAC9B499236E2AADED83D6EEA4F886A177B3A1B01A338，主Work独立hash一致。
A/B1/1成功关闭仅证明此次source-only交付回执，不证明代码正确。完整同次回执检索无截断；初次主Work展示联合输出有工具预算截断，随后分别取回A/B，不追认初次展示完整。

独立GPT-6.1 Sol/high只读审查Required，与Work源码/固定来源核定一致：
1. Check-CrlfContract.ps1:140：map.Source实际为路径string，Bytes/SHA256/CRLF在map根；脚本RequireFields把路径字符串当对象，固定数据不适用。
2. :184/:196：M5-54 Spans没有ScopeReference，脚本要求并比较该字段。ScopeReference在M5-55 Anchors为四固定字符串；实际scope依据M5-54完整class/apply/addFlutterTasks声明、Lines/Start/End上下文。不得补造地图字段。
未运行，不能报告实际FailureTag/exit或脚本已失败。以上是源码可证明的错误，不是A/B编排失败。继续沿用合资格01a0f4b7；旧三执行停用。

主Work核main/cf8bfaa4a03b8c9a682105617b185141904413be/213status/213入口成员缺0；六冻结及rawfixture、三文档身份均匹配。保留所有dirty/untracked，成员核定不证明所有dirty字节完整。SDK/fixture内容/M5-50内容/parser/AST/脚本/函数/测试/构建运行0（hash读取不作内容授权）。

后继另立新准确SOURCE-ONLY字段与scope修订，不复用M5-58预算，不授运行。旧M5-55/56/57失败、M5-50历史SOURCE-ONLY/输入适用性阻塞、历史transport限制与早期preflight PROPOSED/属性及LibraryExtension时序NOT_PROVEN/M5及隔离构建NOT_READY/settings-v1拒绝/loader-runtime false/真实性恢复生产/UAC门保持。

