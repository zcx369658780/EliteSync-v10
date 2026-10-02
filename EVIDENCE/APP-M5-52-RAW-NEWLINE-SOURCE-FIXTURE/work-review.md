# M5-52 Work 独立 LEVEL2 审查

2026-10-01 ACCEPT/CLOSED EXACT RAW INPUT FIXTURE。独立GPT-6.1 Sol/high NO_FINDINGS；主Work保留裁决。

fixture42405 bytes/SHA256 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313；summary5007/SHA256 FB206DF9FD8AB57D661444D0BEC51363B13231F63FAB055715A65381ADEB53D5。与原B及新源当前A一致。turn01a0f493-c564-77d0-9a3a-33ab341f5a47 completed/error=null。原A exec-61e98433-2ca2-4f0a-9dc4-2b60524239e2 exit0/chunkbe6955/wall0.2584336；原B exec-e221d5e5-3396-4295-b08e-cab497bb4c80 exit0/chunkc408f8/wall0.3298361；两完整JSON检索未截断且≤4KiB，原A899chars，与summary保存A.output逐字一致。

Work核原A命令准确SDK源ReadAllBytes调用仅1，身份/strictUTF8及输出前门通过后同byte[]直接CreateNew写证据，无Replace/normalize或解码字符串转写；B只本仓候选且未修改。A/B各1/1关闭，SDK来源读取1/同原始证据复制1、SDK修改/其它读取复制及Python/AST/import/函数/变换算法/tests/构建安装启动0。

Work及独立审查从本仓完整fixture核821CRLF/0bareLF/0bareCR/无BOM，末字节10为最后CRLF末尾；strictUTF8及普通non-reparse含祖先通过。旧六冻结身份/main指定HEAD保持，Work核206基线成员缺0。成员保留不是全dirty byte证明。

只接受完整原始输入，不接受算法/语法/完整正例或真实兼容。M5-50历史SOURCE-ONLY及完整输入适用性阻塞仍保持；后继仅本仓fixture+M5-49材料实质核四raw锚/三声明、唯一/scope/非重叠及八字面LF→CRLF映射，独立新尺寸/delta合同，不沿用45840；该合同接受后再另授最窄source-only修订，不normalize整个源、不生成变换结果。

M5-51旧失败/预算关闭、M5-48历史transport限制、M5-43PTY全传输NOT_PROVEN、旧REJECT/证据/预算、M5-44静态145PASS/M5-45人工13/13保持。早期preflight PROPOSED/属性与LibraryExtension时序NOT_PROVEN，M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及真实性/恢复/生产/UAC门保持。
