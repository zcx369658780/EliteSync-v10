# M5-34 Work独立LEVEL2审查
2026-09-30：REJECT AS EXECUTABLE VALIDATION HARNESS / CLOSED SOURCE-ONLY。A/B各1/1成功并关闭，任何Python/launcher/算法0。完整两script和原回执已核；PowerShell解析零错误不代替运行。
最终checker 18304 bytes / 6427B8EA143C8DD39BEA248A040E3C2FAEE48D745990FA4E7F9C117D2E4B15B4；launcher 8091 bytes / DCE5752BED51E3C710338024DD852306921CEB47D26C3DFFB52355D62AC7F574，Work只读核hash匹配，无新执行。
Sol/high独立完整harness只读审查与Work复核两Required：
1. checker67–77的ast.dump保留ctx；259行将赋值sys.modules目标Store对表达式Load，登记集合必为空，277/280 suite/outcome目标同样误拒。须按目标AST结构+Store显式检查或仅对比较归一ctx，不降掉绑定和顺序门。
2. checker149/252固定加载路径进入expression进行第二次字符串解析，外层Python字符串求值后只剩单个反斜杠，内层非raw路径把apps/tools的反斜杠a/t变控制字符，必误拒原测试raw路径。改内层raw路径或直接比较AST Constant.value；保持准确路径，不自由允许其它路径。
未发现其它确定性Required；launcher原生API耗时/OS硬截止等未测限制保持，不宣称隔离或运行ready。当前候选不执行，旧候选/预算保留。main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；185 status、183接管基线无缺项。
M5-35仅保存新目录最小修复checker与launcher新checker路径，A/B新各0/1，所有运行0，仍先独立审查再另授执行预算。最新Codex已3次启动completed/idle/error=null沿用。M5/隔离构建NOT_READY与全部保护门保持。