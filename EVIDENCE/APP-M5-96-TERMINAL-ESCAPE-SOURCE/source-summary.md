# M5-96 SOURCE-ONLY 可逆终止前缀
仅StopFirst中编码表达式与固定message说明变化。每字段按原UTF16长度截最多128 code units，再每unit固定反斜线u+四位大写hex（ASCII/中文/控制/代理项一视同仁）；不使用?或替换fallback。固定Encoding=UTF16_CODE_UNITS_HEX，原Phase/Tag/Class/SecondaryPrefix顺序、Cut与SecondaryCount保持。编码本身不覆盖first，不增加JSON/Console/file操作。
结构上界：4×128×6=3072编码字符；固定文本、三个分隔符、Cut最大5字符、SecondaryCount最大10字符共101，终止message≤3173<4096。该结构计算不是候选运行；被截前缀可逆，Cut依原长度真实标注。

A=84fc51 exit0；宿主cmd2245字符，来源19818/hashBB91FD7667F4A38FDDFDEB7D2244A5DA55A7D67EE83634B8B29AB41C1E6C6CFA，GetItem/ReadAllBytes各1，普通自身/全祖先/strictUTF8通过；仅函数完整回显，aggregate787bytes/chars≤4096。宿主沿同会话保留准确原全文，以当前A完整hash绑定并核原函数回显一致；没有来源补读。仅该函数逆替换后与准确原全文逐字一致，其余所有字节保持ASCII/LF。
main/cf8bfaa4a03b8c9a682105617b185141904413be，252旧缺0/status252，两目标原无。
新源码19873bytes/chars≤24576/19950，SHA256 D1BE2EC4F621C1F4370731B4278C814CBAD13AEFA07B3DB4851F06AC799377AD。summary预写≤3072，文件工具各新增1，保存时B0/1；B只两候选各Read1，后不改。

当前SOURCEONLY，编码/所有失败路径NOT_EXERCISED，未ForEach-Object候选编码/Parser/脚本/Process/Groovy/JVM/外部读取hash枚举/GradleSDK构建/HTTP。旧M94/M92整体拒绝及旧预算保持；旧探针未读未重新接受，M93未授未建未派、M95未建未派。不将source存在当运行授权。
dirty18冻结/rawfixture/M5-50/NOT_READY/settings拒绝/loader-runtime false/真实binding-ID-path-hook及LibraryExtension时序外部门/父stderrUNKNOWN/OS硬截止与文件网络隔离NOT_PROVEN及真实性恢复生产UAC门保持。无Git写操作，自动化PAUSED。停独立Sol/high与WorkLEVEL2，不自接受、交接或派后继；会话阈值由Work办理。
