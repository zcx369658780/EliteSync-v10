# EliteSync v10｜M3 隔离执行与证据结果 v0.8-R2

Status: `PROPOSED RESULT — AWAITING INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — GUEST_STARTUP_NOT_ESTABLISHED — NO M2 AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。本报告记录Owner直接批准的v0.8-R2一次性续行。执行者不自我接受，不更新main，不执行M2或产品实现。

## 1. 权威入口与复用边界

实时GitHub main精确为`f7939bff46326eef2d41cc27b302f48d60b8568b`；FIRST交接blob为`18485c95262051e43892436fb52413132c5ee626`。任务`3dcb69c9fe9cb15cd9c021687b8807c314205231`的唯一父为该main，任务blob为`96c55bc2f08248dbd9ce5c7779aefc7bcacee64f`，相对父提交只新增任务单。

本轮继续使用`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`，新增证据只写`evidence/resume-r2`。旧host ordinary native 4/4与batch 6/6证据只读复用，未重跑；ordinary `override_present=false`、batch `override_present=true`及exit37传播仍由旧证据支持。dispatch SHA-256精确为`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。

旧四份host证据结束哈希与接受记录一致：`result.json`=`2F7EC60B608B821F1EB1271D6E17D6FE5CFFF99D26B77C23EB65E4D5304ABA0E`、`host-dispatch-selftest-1.json`=`CA0657AD2FB8F9135D09744BB35622BD0C7668B055B3094A22A99E90B26E4DC4`、`script-preflight.json`=`E0DF3472FDA26F726CBDDFED1B41CAAFE463370454512A58A2B2FAA770A079B8`、`host.log`=`E2B5871BFBB5750A915806344364D5BC1EDB83F5E711BBB59283F1AFDA062655`。本轮没有修改旧`resume-r1`、旧runner或原仓库。

## 2. 启动记录器修复与无害实测

记录器版本为`M3-R2-LAUNCH-RECORDER-1`，最终SHA-256为：

`103EE48EA240BD15735E601C5657653A25F0586275093FF988024B7CF5D12AB5`

修复后的关键顺序为：`Start-Process -PassThru`取得Process对象后，立即提取PID、可取得的StartTime、调用时间、目标、参数、WSB路径、nonce及记录器hash；同步写入最小JSON；立即回读并核对PID、nonce、WSB和hash；只在进程真实结束后另写exit记录。布尔字段使用合法`$true/$false`。首次执行前进行了两次限定纠正：修正自有序列化语句的普通语法错误；按冻结guest脚本的既有`FINALIZE`结果形状完善终态识别。没有触碰dispatch host测试。

无害系统进程实测使用`C:/Windows/System32/cmd.exe /d /c exit 0`：

| 项目 | 结果 |
| --- | --- |
| Process对象 | PASS；PID `19024` |
| 原子身份先落盘 | PASS；creation UTC `2026-09-09T04:46:12.6892308Z` |
| 写后回读 | PASS；PID为正整数，nonce/WSB/hash均匹配 |
| 真实结束后补录 | PASS；exit=`0` |

因此记录器边界在启动Sandbox前已实际PASS。该结果只证明记录器，不证明Sandbox或guest。

## 3. 唯一Sandbox启动结果

新WSB静态合同SHA-256为`D37A5C84DFAB0FE2E886B5D73A21299D59DE21EF6157FE664A2C43C4BBC4E808`。Networking、Clipboard、Audio、Video、Printer和VGpu均为Disable；八项宿主输入为只读映射，唯一可写宿主映射为`evidence/resume-r2`。guest入口限定使用进程级RemoteSigned；冻结guest SHA-256仍为`578F97570EED07274A2E783730F5130126A5D12C8A03FA3F4B0E9A41C1889D39`。

本轮只调用一次`C:/Windows/System32/WindowsSandbox.exe`。原子记录和立即回读均成功：

| 字段 | 实际值 |
| --- | --- |
| PID | `41372` |
| call UTC | `2026-09-09T04:46:13.1284008Z` |
| creation UTC | `2026-09-09T04:46:13.1356631Z` |
| nonce | `M3-ISO-V02-008-R2-7c1ca3490bea4dce9be574b96fccd653` |
| identity round-trip | PASS |
| launcher真实exit | `0` |

该`WindowsSandbox.exe`进程在约2秒后结束，结束前没有出现匹配nonce的`guest.started`；没有guest result。任务规定进程在`guest.started`前结束时保存真实exit并停止，因此没有第二次Sandbox启动。

最终分类为：

`M3 PRECONDITION BLOCKED — GUEST_STARTUP_NOT_ESTABLISHED`

launcher exit=`0`只证明该启动进程正常返回，不能证明guest已启动、禁网隔离已建立或Windows Sandbox不可用。本轮取得了可靠的launcher身份和exit，仍没有建立guest侧归属证据。

## 4. 下游阶段与收尾

| 阶段 | 本轮状态 |
| --- | --- |
| guest Process/effective RemoteSigned与Security模块 | NOT_RUN |
| guest nonce、活动网卡与默认路由 | NOT_RUN |
| guest ordinary native冒烟 | NOT_RUN |
| guest batch pub/M3形状与exit37冒烟 | NOT_RUN |
| 八项复制 | NOT_RUN；count=`0` |
| 真实Git `--version` | NOT_RUN；exit=null |
| 真实Java `-version` | NOT_RUN；exit=null |
| `flutter pub get --offline` | NOT_RUN；exit=null |
| release-only M3 | NOT_RUN；exit=null |
| exact AAR | NOT_CHECKED；probe_count=`0` |

无害进程和PID `41372`的Sandbox launcher均已真实结束；结束核对没有该PID的活动进程。没有guest Job或工具子进程可收尾。原仓库、宿主SDK/cache、用户配置和旧证据未写。

## 5. 证据限制与剩余决定

本轮直接关闭了v0.8-R1的“Process身份未可靠保存”缺口，但`WindowsSandbox.exe`返回后没有建立guest nonce链。没有guest策略、隔离、复制、Git/Java、pub、M3或AAR新证据；M2仍deferred。任务结束前Owner补充说明该宿主同时只能启动一个Sandbox，且Owner不会主动关闭现有Sandbox窗口，未来相关任务可检测并使用现成Sandbox；本轮未读取或接管该未知会话，故该说明不改变本次实测分类。

后续若Owner另行决定继续，最小具体缺口是按Owner新说明安全识别现有Sandbox会话，并确认Windows Sandbox启动程序的进程归属/会话承接与guest.started记录链，使launcher返回、既有唯一实例和实际guest之间可被可靠关联。该决定不需要重跑host 4+6，也不需要重做dispatch、复制、策略或工具发现；本报告本身不授权新的Sandbox、pub、M3或M2。
