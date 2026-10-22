# v10.1.5 P1 USB/ICE-TCP 最小动态观测报告

2026-10-22（Asia/Shanghai）。**DEVICE_NOT_PRESENT / READY_AWAITING_PHONE / P1_PRECONDITION_BLOCKED / SOURCE_UNCHANGED / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本次在G0必需设备门停止：17:10:08（UTC+08）一次ADB设备清单读取exit0，未匹配到此前Owner明确选定的USB手机，状态为NOT_PRESENT。它不证明手机物理上未插入或硬件故障，只说明本次ADB清单中既定身份不可用。没有选择其他设备或AVD，没有再次枚举/试连，没有启动APP/数据库/SFU/guard、创建reverse或发起Room.connect。**本次call数和Room.connect尝试数均为0；没有新的listener、candidate pair、STUN或DTLS观测。**

本报告集中交付前置阻断；不是旧媒体结果复测，更不是ICE连接或RTC接受。

## 固定Authority与源码

| 对象 | 固定身份 |
|---|---|
| 正式任务 | `OWNER_APPROVED_P1_USB_ICE_MINIMAL_OBSERVATION_TASK_20261022.md`，Blob `5957cf95b4d41fc27344de5cb6e56955b1d43a75`；全文读取、原字节Blob重算并与main固定路径关联核验。 |
| 实时main | `7ce7c91d82147db5742a9ea5a543dae754f064b7`；Root `d547e0e6f038f1ca2eb16e26fee8b81a83a40be3`。 |
| main接受产品 | apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，仍为v10.1.4；未以main覆盖R1候选。 |
| 固定R1源码 | `1c5cd2bb7919c435e8486a76959db75e9ccc367f`；Root `165eb1f362db533ca94bfe1db677ff6f7bd477ed`。 |
| R1完整产品Tree | apps `0784c8aa7b0915a04b83693a45401197e31d93a2` / services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`；本次完整保留。 |
| 本候选唯一Parent | 上轮只读审计 `7fd2b9f205df7edcf4f713d1374e924e6a6caad6`；Root `fd50d00e817ceabdbd5fc35b84ebd0dba55cc5a1`。 |
| 旧审计原件 | 报告Blob `bffb7d1fb520fdd5da6e7e24a9b9a06a6c237971` / 清单Blob `cbbe7ff5c61a0f66b1dee7674f6c5b20bff98b3d`，未改写。 |
| Astra审计复审 | Blob `f24e293c59a289fb259a20ae4c5b0e69b8ba3d15`，完整读取；只读审计范围的ACCEPTED_WITH_OBSERVATIONS不等于RTC产品接受。 |

使用原单一归属干净工作树，分支 `codex/v10.1.5-p1-usb-ice-observation`，仅新增本报告和 `p1_usb_ice_dynamic_observation_manifest.json`。最终候选SHA/Root/两文档Blob由发布后的对象回读回执列明，避免文档自身哈希循环。

## G0～G5 实际执行

| 门 | 本次结果 | 证据与停止边界 |
|---|---|---|
| G0.1 USB及安装身份 | **DEVICE_NOT_PRESENT** | 只执行一次ADB清单；精确选定身份未出现。没有adb -s设备命令；实际包版本、安装路径、签名、当前APK字节和当前麦克风权限均NOT_RUN。 |
| G0.2 Git及历史保护 | VERIFIED_LOCAL，终检见后 | 新main/固定任务、R1/旧审计对象已核；五历史根及950份既有文件、原refs/private env建立本轮基线。 |
| G0.3 数据库恢复点/有效连接 | NOT_RUN_DEVICE_GATE_NOT_MET | 未访问/启动数据库，不读取活库身份、不发SQL，不把旧恢复点或旧fixture状态当本次实核。 |
| G0.4 占用/SFU镜像归属 | NOT_RUN_DEVICE_GATE_NOT_MET | 未查运行时端口、未启动或inspect本轮SFU，未用host TCP connect替代容器listener。旧镜像digest仅是历史引用。 |
| G1 容器内ICE7891 listener与Docker后端 | **NOT_RUN** | G0不满足，未启动任何服务；REACHABLE_FROM_DOCKER_BACKEND=NOT_ASSESSED。本次不能确证或排除bind mismatch。 |
| G2 唯一Room.connect | **NOT_RUN（0次）** | 未运行APP或HTTP peer，未新建call/token/reverse；没有selected pair/STUN/DTLS/track结果。未消耗Room.connect机会，也未自动安排下一窗口。 |
| G3 因果定位/修正 | PRECONDITION_BLOCKED | 唯一已证阻断是既定手机在ADB清单中不可用；本次不新增ICE根因或配置修正结论。 |
| G4 非作者复核 | 见下 | 对本次门禁、身份与分层结论作一次静态审查，不补造设备或网络运行。 |
| G5 交付/资源收尾 | NO_NEW_RUNTIME_RESOURCES | 本轮没有需停止的APP/服务/容器，也没有需移除的新增reverse；未向旧资源发送stop/kill或全局ADB/Docker/WSL操作。 |

预期复用APP为 `com.elitesync.v1015r1dev` / `10.1.5-r1-dev`，预期APK SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`。**这些是冻结任务及历史已验证身份，不是本次设备包核验结果**；没有重装、覆盖或回取包。原独立库、镜像、权限及CN/MC也未被当作已恢复运行。

## 本次观测漏斗与保留缺口

| 层 | 本次等级/结果 |
|---|---|
| 选定设备出现在ADB清单 | LOCAL_RECEIPT：NOT_PRESENT；一次查询，exit0。 |
| 实际容器ICE/TCP listen接口、namespace、Docker backend | NOT_RUN；无新DIRECT_RUNTIME记录。 |
| candidate/tcpType/ICE role | NOT_RUN；不能将上轮20条快照改为本次数据。 |
| pair checking/STUN/nominated/selected | NOT_RUN；没有协议头采样或端口试连。 |
| DTLS/track/归属音频 | NOT_RUN；未启麦、无合成声音或环境音录制。 |
| HTTP-only peer | NOT_RUN；历史控制端仍不是第二个媒体APP。 |

旧Room.connect约30.224s失败、SIGNAL_SOURCE_CLOSE、20候选/715观测及历史输出边界事件均保持原件；本次没有重跑或赋予新因果含义。初次设备检查的**ADB本身exit0**，本地门禁封装因 `READY_AWAITING_PHONE` 断言返回exit1，是遵守停止条件，不是SFU/SDK产品缺陷。完整ADB清单未持久化，以白名单选定身份匹配/state摘要留证；不保存或公开其他设备详情。没有伪造原stdout或补跑来取得第二份清单。

## 后续最小条件与权限

首先需要Owner使**同一台已授权USB手机**在ADB中可见并保持此前调试信任，再明确继续此受限任务；本次不会后台轮询或自动恢复。再次执行时必须重新做G0安装身份及数据库/恢复点/端口归属核验，然后才可到G1。

本次没有形成新的P1修复建议：旧审计中的容器bind与Docker后端路径潜在矛盾仍是HYPOTHESIS，不能据此改监听、node_ip或publish。未来若G1确证仅容器loopback监听与非loopback DNAT目标冲突，按原任务立即停在call前，只提交具名最小配置变更供Owner决定。P2隔离LAN/TCP仍只是先前后备提案，需要接口/设备/端口/候选及必要防火墙的单独批准；本次不切换P2，不开放LAN/UDP/TURN，也不改SDK或产品代码。

四项冻结硬门全部保留：双APP双向真实媒体NOT_VERIFIED；same-call真实媒体重连、旧JWT首入/重入拒绝、撤权COMMIT后流动媒体停止≤5秒均NOT_RUN。没有流动媒体、HTTP控制状态或新ICE证据可以替代它们。

## G4 非作者有界复核

独立非作者GPT-6.1 Sol/high完成一次有界静态复核，结果BOUNDED_STATIC_REVIEW_COMPLETED_NO_CONTENT_BLOCKER。核对指定文档、6份匿名证据bytes/hash及本地Git对象，确认ADB exit0与封装exit1分层、G0停止、Room.connect=0、无新增资源、历史身份未冒充本次实核及四项AC05仍OPEN。

非作者未进行设备、DB/API、容器、网络、测试或写操作，不构成动态验收或产品ACCEPTED。其提出的交付前完成项（主代理保护/隐私终检、回填复核和发布身份回读）均分别由真实回执承载，不把静态复核当作950文件现场重算。

## G5 保护及发布

本地终检：5个历史保护根的HEAD、branch、index SHA256与dirty/untracked状态全部与本轮基线一致；950份既有文件bytes/SHA256不变，原490个refs及private .env不变。保留原907份及上轮审计新增原件。当前代码树仅有两份指定新docs；没有改产品或任何旧证据。未生成/停止运行资源，未触及手机安装/数据、旧volume、备份或全局ADB/Docker/WSL。此为主代理LOCAL_ONLY保护回执，不冒称Astra本机核验。

公共材料仅含匿名设备别名、状态/协议角色、预期包身份、Git对象与原证hash/bytes；不上传序列号、私人IP、SSID/MAC、JWT/密钥、原candidate/SDP、完整设备日志、SQL/APK或声音。该目录的新设备摘要不含原序列号。旧资产只读取/计算hash，未清理任何工作树、审阅分支、SQL/APK、备份、volume或手机数据。

仅普通nonforce发布本次两文档候选，核验最终Git SHA/Root/Parent、两份Blob和R1完整apps/services子Tree；main不集成。**DEVICE_NOT_PRESENT / READY_AWAITING_PHONE / AWAITING_ASTRA_INDEPENDENT_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。
