# APP-M5-11｜独立 synthetic host SOURCE-ONLY候选回执

状态：CANDIDATE / WORK LEVEL 2 REVIEW PENDING。仅九文件源码准备，RUNTIME_NOT_READY；无产物或运行授权。

仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。新增根apps/android_synthetic_demo不存在才开始；根/父apps未观察到链接或reparse属性，九路径无冲突。只创建九文件必要目录及本摘要，无已有文件修改、wrapper/properties/README/测试文件/缓存交付。

## 实现事实

JSON v1固定独立ID/namespace、debug、严格boolean true、lib/main.dart与唯一synthetic define；工具常量/九个staging目录固定，artifact NOT_READY、八个输入/隔离gate及receipt准备UNRESOLVED。只有receipt所需字段列表，没有假AAR hash/GAV/已验证receipt。

settings的pluginManagement最前无条件throw SOURCE_SCAFFOLD_NOT_READY，位于任何插件解析前。root/app仅静态声明AGP8.11.1/Kotlin2.2.20与SDK36/min26/target35/Java17，debug-only变体模板、host synthetic=true和固定loopback；没有仓库/Exec/Flutter构建、用户配置读取、共享AAR消费。当前依赖NOT_READY，不能编译；非debug变体API与真实任务图未运行验证，settings全拒绝为当前阻断。

BootstrapEndpointPolicy直接取原源码，仅package com.elitesync→com.elitesync.syntheticdemo，余字节完全保留。MainActivity在super.onCreate前require DEBUG与synthetic，实际调用policy；首次/新Intent均固定安全门，不读取Intent值/JSON/文件。channel只支持getBootstrap，固定API/WS、/home、版本/debug，其它notImplemented，不提供clearBootstrap。

manifest最小Flutter embedding/唯一exported launcher、allowBackup=false、无普通Application/Baidu/deep link/provider/shared UID；显式移除INTERNET/NETWORK/WIFI/位置/相机/录音权限；styles新写平台主题。合并manifest/插件初始化/整host编译未证，未宣称无网络或数据隔离已建立。

Work同任务补充路由门后，在同两允许文件增加override getInitialRoute(): String = "/home"与application meta-data flutter_deeplinking_enabled=false，以覆盖FlutterActivity可能消费外部路由的路径。未读SDK或运行Android。补充发生在一次静态检查之后，未重复该预算；最终这两行的Android接口/生命周期与合并manifest仍NOT_CHECKED，留独立审查。纯Python测试只验证合同，不涵盖Android接线。

validator为标准库纯函数；JSON拒绝嵌套/顶层重复键和NaN/Infinity，递归固定schema精确类型与allowlist，不接受1作为true或1.0作为int；严格固定staging/tool字符串，不解析/resolve/stat未知路径。validate_contract合法只能返回CONTRACT_VALID_RUNTIME_NOT_READY；admit_runtime始终拒绝v1，即使合法模板。CLI仅读取显式契约文件，--admit-runtime退出2；不启动进程/写文件/读缓存，异常只捕获明确JSON语法/合同/文件读取错误，无宽泛吞错。

## 来源身份

- apps/android/build.gradle.kts：F4DB52252E3F16CDB2EE6B783AB3330366534D236024CE69AD6924C136133461。
- apps/android/app/build.gradle.kts：0B667C458BC45E213F36F9C0C7D25960EA9A900FD309B983890AE2A7668FBA5B。
- 原BootstrapEndpointPolicy.kt：E25174137CC6ECEA990B3EFF09752C545A8E724AF052582C7CE0665A881E9FBB，匹配task固定输入。
- 原MainActivity.kt：96500063E7728CFB50AD196744AFFA0B6FDE0080045AA69BA0DF8EBD340CAD27。
- lib/main.dart：F0F4A6C112774AE0EE78D47B4FFAFD6CF20250B1CA5B6EE112AC4A4EB2BF2B54。
- lib/main_demo.dart：F542C28670BB3D9C28B4D5DF43E93FBCBD144FCB266FDFB91B9B94789B422D02。
- lib/app/router/app_route_names.dart：FCABD90DE3634E1D72C9783C86A29104D428858F046C95C2D413F99F6F0395C5，仅Home第14行='/home'核对。

九新文件输入均MISSING（未覆盖既有文件）；输出SHA-256（相对新根）：

- build-contract.json：A4BD59F21748DE0527B9A22DBABDFAB2A537827C162DF834A03BDE253BB88FE8。
- settings.gradle.kts：4D0AD64BD883DE38E646E167A47A716FBB461155FFB741F6949AB161ECD025F2。
- build.gradle.kts：F1E0BD9637D072E973C7C2038E512CFEEDF51AA80995AC343C97E675E132E73E。
- app/build.gradle.kts：61B5B9F77F53C0FB00138DA9B11D01FC2B34A62545725AD09EB9F2C3F0816AAF。
- app/src/main/AndroidManifest.xml：CAE490260B4CD9AE8740F810BD6EA0C553F9F5D2DEF5E7567C233035FEA9F69A。
- app/src/main/java/com/elitesync/syntheticdemo/MainActivity.kt：7C84B23C554FAD528126151E00AB1B63B9E179A2DFCDDD5A13AA4AC9A203176F。
- app/src/main/java/com/elitesync/syntheticdemo/BootstrapEndpointPolicy.kt：7E7FC5EB6AF61B2C1FECE2F0222EE8F59CD88CBA2BA3DD39089F72D8C4B0528B。
- app/src/main/res/values/styles.xml：E7F378283A4A04933C834DA60702B22BBD5255CCB3C7ED300AE734778D4E709F。
- tools/validate_contract.py：A4F93BD498DC835D556A4F52FC0A457FECEDB7203304B8A1E59EF6FD03244924。

## 验证回执与预算

A 静态清单/禁止引用1/1 PASS：限定新根，准确九文件；无真实properties/env/home读取、远端repo/mavenLocal/Exec/includeBuild/shared AAR。policy衍生字节、host门/调用、channel限制核对。空白1/1 PASS；XML/JSON/validator Python语法解析PASS。路由补充后不复跑，最终两文件hash如上。

B 唯一隔离测试进程：C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe -I -B -c <inline test>。Get-Command python仅一次准确入口解析，无替代搜索。内联测试直接import生产validator，用显式新契约路径；不落测试文件，不写pycache。
UTC开始 2026-09-30T01:56:58.437140+00:00，结束 2026-09-30T01:56:58.510891+00:00；耗时0.063秒，退出0；timeout=false，stdout 1084字节，stderr 0字节，双路均未截断。60秒硬时限、每路32768字节并行排空。
39/39不同意义case PASS，含合法NOT_READY、v1运行拒绝、缺/false/string/1标记，release/profile/混合，冲突/重复/额外/缺define，顶层/嵌套重复JSON，NaN/正负Infinity、非法语法，.. /absolute/drive/UNC/drive-relative逃逸，错ID/namespace/target、未知字段/嵌套字段、boolean/float schema，fake READY gate/artifact/receipt/hash，工具路径变化与CLI合法/运行拒绝。
预算1/1耗尽，无测试失败或重跑。测试启动前编排代码一次因临时runner状态缺失报TypeError，发生在exec_command调用前，未启动测试进程、不消耗Python执行预算；随后构建显式包装器执行唯一测试。

原始测试输出：
```
PASS valid source contract only NOT_READY
PASS v1 runtime admission always rejects valid contract
PASS synthetic marker false
PASS synthetic marker string
PASS synthetic marker integer
PASS missing marker
PASS mode release
PASS mode profile
PASS mode ['debug', 'release']
PASS conflicting define
PASS duplicate define
PASS additional define
PASS missing define
PASS top JSON duplicate key
PASS nested JSON duplicate key
PASS nonfinite NaN
PASS nonfinite Infinity
PASS nonfinite -Infinity
PASS JSON malformed syntax
PASS staging dotdot
PASS staging absolute
PASS staging drive
PASS staging UNC
PASS staging drive-relative
PASS wrong application ID
PASS wrong namespace
PASS wrong target
PASS unknown top field
PASS unknown nested field
PASS schema boolean not integer
PASS schema float not integer
PASS fake READY artifact
PASS fake READY gate
PASS fake receipt body
PASS fake artifact hash
PASS tool path altered without accessing it
PASS receipt READY
PASS CLI explicit template only returns NOT_READY
PASS CLI runtime denied
TOTAL 39/39 PASS
```

## 保留与停点

获授权Git branch/HEAD/porcelain前后各一次；本地main/HEAD不变，前159、摘要写前后检查160条非忽略状态，仅新增?? apps/android_synthetic_demo/，既有状态条目保留。本摘要目录已因task存在于旧untracked条目，不把聚合状态当文件内容完整性校验。未读其它diff/index、处理dirty文件或修改authority。

无Gradle/Flutter/Kotlin/JVM/ADB/安装/运行/截图/logcat、UAC、真实properties/缓存/凭据/备份/密钥/DB/SSH/生产API/旧仓库、材料下载/网络或Git提交/pull/push。构建/产物/签名/应用数据隔离/merged manifest/生命周期仍NOT_CHECKED或UNRESOLVED；M5 NOT_READY，真实账号/Conversation/G08/G11/恢复门与旧预算保留。

只交付候选，停Work独立LEVEL2 ACCEPT/REJECT，不自接受、不派发后继。
