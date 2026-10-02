# M5-83 SOURCE-ONLY candidate
新增 LocalExtraRecipeInstaller.groovy，一个类/显式 install(Project,String,Map) 入口；全部新增行为 PROPOSED。无 hook/调用现场/Android或LibraryExtension操作。

caller负责授权绑定 target/path、六已解析 String 值及真实 input_id/SDK身份/路径/调用时序；primitive不计算这些值。入口按四路径、六键、严格 String/非空、三个固定值核输入；拷贝caller Map，不改它。读取 target-own getProperties detached map，六项冲突全核后只set缺项；同值不覆、空own可填、unrelated项保留，不读继承属性。一次post-map核六值。
失败固定wrapper tag/phase/completedSets/attemptedSets并保留首cause；set抛错可能已有副作用，completed仅正常返回次数，不伪称原子/回滚。无重试。typed String 参数只能检查入口收到的值，动态Groovy caller调用前可能发生参数转换；未经运行，不能声称原始调用表达式类型已证。

材料出处：单来源aar_entry_materials.py 33四project、34六keys、213–220 recipes、225 LOCAL_EXTRA、35/226声明phase、232 runtime_ready=False。input_id算法/F常量未覆盖，不臆补。官方API依据仅本次已读M5-82 Work裁决所核历史原文字事实，非本轮HTTP或旧错误报告整体接受。

A=e5be60 exit0，宿主cmd2195字符；source20338/hashB324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7，ReadAllBytes1/补读0，固定33–110与193–末，原输出尺寸宿主另核≤12288/14000。普通自身/完整祖先/strictUTF8通过；main/cf8bfaa4a03b8c9a682105617b185141904413be，240旧缺0/status241，两目标原不存在。
两文本预写尺寸/hash宿主另核；文件工具各新建一次，保存时B0/1；B只两候选各Read1，不source补读，B后不改。

当前所有Groovy/Java/Kotlin/Gradle/Parser/Python/AST/compile/import/exec/transform/StaticTest/SDK/Flutter/JVM/ADB/依赖解析/工程复制/构建安装启动0，HTTP0；治理/raw读另记。语法/行为/异常分支NOT_CHECKED。四项目整体事务、真实hook/root解析、Extension时序及SDK兼容不由此primitive证明。
dirty/untracked/十五冻结/rawfixture/M5-50输入阻塞/旧闭budget保持；未Git写操作。M5/隔离NOT_READY、settings拒绝、loader-runtime false、earlypreflight PROPOSED、真实属性/LibraryExtension时序NOT_PROVEN、父stderrUNKNOWN/硬截止NOT_PROVEN及真实性恢复生产UAC门保持。
停独立Sol/high与WorkLEVEL2，不自接受；任何验证/运行另task另budget。
