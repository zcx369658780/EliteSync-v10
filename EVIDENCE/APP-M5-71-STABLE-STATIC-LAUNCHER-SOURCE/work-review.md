# M5-71 Work独立LEVEL2裁决

2026-10-01 REJECT/CLOSED SOURCE-ONLY DELIVERED。独立GPT-6.1 Sol/high m560_receipt_review人工源码审查两项Required，经Work核源码确认：Hash-Bytes在finally记Dispose首失败但正常return，使stdout哈希失败后继续stderr哈希，直到随后Require才停；最终序列化/Console输出位于受保护try/catch之外，输出异常可能绕过首失败报告/显式exit1并泄出异常正文。不得运行或修复原候选，语法行为NOT_CHECKED。

原执行01a0f590第6turn01a0f5be-d193-7a30-9801-9ae84d5396b1 completed/error=null/idle。native-receipts.json原A exec-f71aa4dd exit0/truncated=false/8215UTF8bytes/5417字符，原B exec-cc486e62 exit0/truncated=false/647bytes；原包装命令1282/1858字符均≤4096。A两材料全文与本地准确文字加原单LF分隔逐字相等，不做行末规范化；native新增两候选全文与磁盘逐字相等，fileChange truncated=false。原A/B各1/1关闭，B后候选未改。

Work workspace-review.json独立核两最终身份与原B一致：launcher14705/hashE0AB9AC006425B77F721D7C36213F698F34F6B606CB472D80509A56092C93FA3，summary2120/hashFDE24DF15ED0DCDE7BD8D6FE2B44B2369801C578A1643CEB664D637B2C33EE48；普通自身与完整祖先-size/hash一致。main/cf8bfaa4a03b8c9a682105617b185141904413be/229status/228旧成员缺0/十二冻结祖先-size一致，十非bin fresh hash一致，两个bin哈希仅沿原已接受回执、未补读正文。成员保留不证明无关dirty字节不变。

SOURCE-ONLY交付事实核通过，功能源码验收拒绝，不能以传输成功替代源码接受。所有parser/script/helper/Process/Python/AST/compile/import/exec/候选/Static-Test/fixture-expected正文/SDK构建0。独立stderr UNKNOWN/硬超时NOT_PROVEN，未运行未来launcher/双流路径/候选，不生成expected。原M5-70未提交4178计数仍仅自报/预算闭/Static0，不追认或重跑。

旧两候选与预算关闭保留。现有执行会话正常completed沿用，不因普通失败新建。下一张只新路径SOURCE-ONLY最窄Hash首失败停与最终emit保护，未来输出路径改新M5-73；原文字一次读取，纯字符串固定块替换，独立源码审查和Work终裁后运行仍须另授。全部dirty/十二冻结/M5-50原输入阻塞/NOT_READY及保护门保持。
