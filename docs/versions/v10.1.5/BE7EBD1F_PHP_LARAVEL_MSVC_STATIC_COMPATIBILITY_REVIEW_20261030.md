# EliteSync v10.1.5｜PHP 8.5.3 / Laravel 11 / MSVC 运行库独立兼容性审查｜2026-10-30

**审查分类：`SOURCE_AND_OFFICIAL_POLICY_COMPATIBILITY_REVIEW / TWO_CONFIRMED_SUPPORT_BOUNDARY_CONFLICTS / ONE_REQUIRED_EXTENSION_GAP / DYNAMIC_RUNTIME_NOT_RUN / OWNER_DECISION_REQUIRED`。**

本次为Astra基于GitHub固定源码和PHP/Laravel/Microsoft官方文档所做**只读静态研究**。未操作Owner Windows、下载或复制DLL、运行PHP、调用Laravel、访问MariaDB、启动Flutter、改动产品main或授权任何新的测试。结果不能标记E2E通过、原生DLL真实加载失败或产品功能接受。

## 一、源码与权威基线

- 研究候选`be7ebd1faa0fd3cb45bd88bd24af15ea9e805631`；sole Parent `3bed366233a39472f8a9e905021788b8d29e12b3`；Root `db2725ee513816f430002265e19c0f96ec21325f`；apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`；services Tree `dd552af956733514977cdd4bc82207c062792a96`。
- `services/backend-laravel/composer.json` Git Blob `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`，实际`php: ^8.2`、`laravel/framework: ^11.31`。
- `services/backend-laravel/composer.lock` Git Blob `66327f584d3961c2b53391bb012047dda9cc9d23`，Laravel锁定`v11.48.0`、锁定platform PHP为`^8.2`。
- `tools/v1015/mainline_e2e/php_requirements.json` Git Blob `d367cdf79f8c8d3507fec2c097d8906b6758dd3e`，测试闭包锁定`PHP 8.5.3 NTS Windows x64`，必须shared: `fileinfo,mbstring,openssl,pdo_mysql`；`required_modules`未列`curl`且描述为optional；`php_runtime.py`仍围绕原Hash/PHP版本构建守卫。更换PHP版本/DLL不允许只换文件而不重核源/工具/运行预算。
- Codex候选正式报告Git Blob `02c2d6e82715915735e33f2b2316a684eaad9a4d`：被评估的第三方随附`vcruntime140.dll`版本`14.38.33126.1`、AMD64、SHA256 `4d292623516f65c80482081e62d5dadb759dc16e851de5db24c3cbb57b87db83`；8个已核PHP PE文件显示linker版本`14.44`且17个直接导入的对应符号都在该DLL导出中。该数据为`CODEX_REPORTED_LOCAL_TEST`而非本轮对原始DLL的亲自读取。

## 二、兼容性矩阵（独立审查结论）

| 发现 | 证据、严格分类 | 对策 |
| --- | --- | --- |
| C-01：`vcruntime140.dll 14.38`与PHP参考PE linker `14.44` | **高风险、不能资格化**。Microsoft要求目标VC Redistributable版本≥构建工具版本；PE linker=14.44是强烈线索，但不能单凭linker字段完全证明具体编译器版本。没有真实加载失败，不说已复现故障。 | 不再对14.38候选发放动态运行资格；下一阶段首先查PHP官方发行包的工具集/版本及合规、受支持的v14 x64来源 |
| C-02：Laravel11.48.0与PHP8.5.3 | **确定不在Laravel官方支持矩阵内**，Laravel11官方PHP支持8.2–8.4；Laravel12/13官方支持8.5。Composer `^8.2`语义允许安装8.5，但不能替代上游官方支持承诺或实测。 | Owner选择“临时Laravel11＋PHP8.4受控测试”或“独立批准Laravel12/13＋PHP8.5兼容迁移”；不在本审查里自动替换生产框架或PHP |
| C-03：Laravel11 cURL要求 | **测试运行资格清单与官方部署要求不一致**。Laravel11 Deployment列cURL Extension必需，现`php_requirements.json`却标为optional。即使本E2E HTTP驱动是Python，也不能证明真实Laravel部署无需该扩展；不说所有路径必定失败。 | 动态Laravel/API验证前，对官方扩展清单补cURL及其依赖闭包的审查与资格负例，或提交明确可核的非标准运行豁免，不可静默忽略 |
| C-04：MariaDB10.11.19＋Laravel11 | **数据库大版本在官方支持范围内**：Laravel11支持MariaDB10.3+，10.11满足版本门槛。 | 保留实例身份、driver、schema/权限/真实SQL闭环门，不能推论全部产品事务通过 |
| C-05：PHP8.5.3 NTS x64 VS17 | **PHP Windows构建类型本身有官方对应产品**：PHP8.5使用VS17 x64 NTS，可用于CLI/FastCGI。当前PHP Windows官方更新线已到8.5.12-1（2026-10-26），但旧8.5.3是否触发具体Bug/CVE未在本轮证明。 | 如Owner选择长期PHP8.5，另行决定官方较新补丁版本并重新冻结所有Hash/闭包，不得隐式升级 |
| C-06：Microsoft合法再分发 | **未证明**。候选的Microsoft签名、x64、17个导出符号≠合法再分发来源或完整兼容；官方规则对Redist及单DLL再分发受许可约束，且正式运行时应不低于编译器工具链版本。 | 拒绝从第三方Python工具目录直接复制。优先核官方发布资产、实际许可、架构、版本、Hash、签名/来源；需新Owner授权才能执行取得/安装/受控复制 |
| C-07：Laravel11生命周期 | **已结束安全维护**：Laravel11官方截至2026-03-12安全修复截止；当前日期2026-10-30。 | 即便选择PHP8.4作短期复现，也不建议把Laravel11作为未来商用生产底座；框架迁移须独立决策与回归 |

## 三、官方来源

1. PHP官方Windows构建与NTS/VS17：https://www.php.net/downloads.php?os=windows&version=8.5
2. PHP官方Windows构建工具对照（PHP8.5→VS2022/VS17）：https://www.php.net/build-setup.php
3. Laravel官方版本支持表与生命周期：https://laravel.com/docs/releases
4. Laravel11 Deployment PHP扩展要求：https://laravel.com/docs/11.x/deployment
5. Laravel11 MariaDB支持：https://laravel.com/docs/11.x/database
6. Microsoft最新v14运行库、工具集最低版本与架构：https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist/
7. Microsoft Visual C++运行库再分发与许可：https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files
8. Microsoft Visual C++运行库版本生命周期：https://learn.microsoft.com/en-us/lifecycle/faq/visual-c-faq

## 四、必要后续验证（本报告不授予执行权限）

**需要先做的Owner兼容性选择：**

- 方向A（短期故障复现/尽量小改）：PHP8.4 NTS x64＋Laravel11锁定源码；需要新官方PHP8.4私有闭包/版本和Hash授权，注意Laravel11已EOL。适合仅限独立测试验证，不代表可以上线。
- 方向B（长期产品与PHP8.5）：采用Laravel12的支持PHP8.5版本（或Laravel13，需独立评估迁移成本），选定官方维护中的PHP8.5补丁和许可/版本合格的v14 x64 Redist/应用私有闭包；另行审核现有Laravel11业务代码/迁移兼容风险，不在v10.1.5静默升级。
- 不管哪个方向，都要让`php_requirements.json`、Compose lock、PHP exe/扩展/DLL来源Manifest、实际API/CLI来源绑定一致，动态探针与MariaDB验证只有在Owner新预算且独立资格成功后才可进行。原`be7ebd1f`的96/96纯检查不能覆盖此官方支持矩阵缺口。

**STOP。** 当前仍`PHP_RUNTIME_COMPATIBILITY_NOT_PROVEN / REDISTRIBUTABLE_NOT_QUALIFIED / PHP_PROBE_NOT_RUN / API_DB_E2E_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。历史Flutter6/6与3bed3/3、MariaDB2/2、ACL事故及旧证据、记录/预算不复用不重置。此报告仅写入独立Astra审查分支，不修改main或创建新正式实施任务。
