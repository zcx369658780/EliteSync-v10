# AUTH-162 作者交付｜2026-09-27

**候选修复已交，待 Work 独立 LEVEL 2 ACCEPT/REJECT。** 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；仅改 AUTH-161 保留的两份未跟踪 PHP 候选并新增本摘要，原有 dirty 工作区保持原状。AUTH-161 的旧 Unit 首跑预算不重置，本结果使用 AUTH-162 新预算。

| 文件 | AUTH-162 修改前 SHA-256 | 修复后 SHA-256 |
| --- | --- | --- |
| `services/backend-laravel/app/Domain/PrivateAccount/PrivateAccountTargetCandidate.php` | `00C2811313836861166627D58E2492129EBA116F8F73776BED5C003BE87A04C2` | `E6225EF406AB206C7DA06FF73CC39DB03E30FA2C9F04FB0BB7F71896C7847493` |
| `services/backend-laravel/tests/Unit/PrivateAccountTargetCandidateTest.php` | `CB9A6C863E4BC28FFC7C43B63E7C473A0228159F93A6EA06FBE9CBEAE120DA3F` | `564AAE896D96C54B922DB6148163F5F779B400EED0C3AB1B68C0086208BF2CBC` |

## 精确修复

`legacy_name` 必须是 `source='users.name'`、`account_id` 等于顶层人工账号、且含 `value` 的来源候选；`explicit_nickname` 必须使用 `source='explicit_nickname'` 和同一账号身份。两者缺失、裸值、错误标签或跨账号时都抛出 `InvalidArgumentException`，包括值为 null/空白的情形；没有旧裸值兼容分支或部分结果。归一化仍只从显式昵称取昵称，旧姓名只参与冲突标记；出生地点的当前两处来源顺序、冲突保留、未知顺序拒绝、字符串 `'0'` 保留等 AUTH-161 行为保持。

Unit 夹具改为四个来源候选都带精确标签和同一人工账号身份。新增负例分别覆盖旧姓名跨账号、显式昵称跨账号、两种姓名标签各自错误、旧姓名空白仍跨账号、昵称 null 仍跨账号及裸昵称拒绝；原有出生地点负例保留。接口仅凭调用方 `synthetic_only=true` 标签限定虚构调用，该标签并不证明真实来源；结果不是登录、权限、最终 v10 schema 或跨库映射结论。没有容器、User/DB、环境、时钟、文件或网络 I/O。

## 新预算验证与停点

两份修改 PHP 各执行一次 `php -l`，均退出 0。指定 Unit 文件新预算首跑一次，退出 0，**18 tests / 22 assertions**，无失败、错误、deprecations 或复跑；完整套件 `NOT_RUN`。`git diff --check` 按两文件路径退出 0，但文件仍未跟踪，故另逐行只读核对，两文件均无尾随空白。

回退只撤销两文件的 AUTH-162 差异和本摘要，保留 AUTH-161 原候选。真实账号行、DB、备份/密钥/解密/恢复、SSH/云/生产 API、Docker/WSL、UAC 均 `NOT_RUN`；未改模型、controller、迁移或旧文件，未提交、拉取或推送。作者停 Work LEVEL 2 独立审查，不自接受或启动后继。
