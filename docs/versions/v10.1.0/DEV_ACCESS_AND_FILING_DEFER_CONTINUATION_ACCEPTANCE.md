# EliteSync v10.1.0 R1｜Astra 独立接续审阅与限定接受

**2026-10-19 — R1_ACCEPTED_WITH_OBSERVATIONS / DEV_CHANNEL_CONTINUATION_COMPLETE_IN_APPROVED_SCOPE / V10.1.0_PARTIAL_NOT_ACCEPTED / AC-10.1-08_PARTIAL**

## 1. 裁决与边界

Astra 对本版已冻结 R1 接续任务作独立 GitHub 对象核验，并审阅唯一结果报告、原冻结计划、原实施报告身份、Owner 的备案延期决定及本版受控端点合同。

**裁决：R1_ACCEPTED_WITH_OBSERVATIONS，仅关闭“受控开发通道保全／备案延期登记”这项同版任务。**

这不等于 v10.1.0 整版功能验收通过，不意味着受邀同事已经从外部访问独立 Web 后台，不表示公网裸IP具有备案豁免，也不授权将未接受的v10.1.0源码集成main或开始v10.1.1。冻结AC-10.1-08仍为PARTIAL；整版仍为PARTIAL/NOT_ACCEPTED。

## 2. GitHub独立核验

- 固定R1任务：main `e802b926a95e49f7b8398fd85ac7ed8463777d0c`，Blob `f2c37373b4ae4ea6b208c2f7f52076d2ab73b437`。
- R1结果交付Commit：`3ef84dbce8ff927363a1d71f9296b73a3f9442e2`；Tree `ea26a6adc82f842fd2a49609189b7fac5531b420`。
- 唯一parent：`939ac6f95d962bed8c75d872c9fa68be2a503933`。该parent的Tree为`4b831329cfecc64d296a3bee34daf38d2eee4009`。
- 固定结果报告：`docs/versions/v10.1.0/DEV_ACCESS_AND_FILING_DEFER_CONTINUATION_RESULT.md`，Blob `b7ee597a7bdbaecfc7f4739ca0f81848c2add119`。
- GitHub compare显示仅1个普通后继提交、2个Markdown路径：新增上述结果报告，向该开发分支的`CURRENT_STATE.md`前置一段R1状态。前版历史正文保留，未触及源码、测试、APK、数据库实体或私钥。
- R1前后完整apps Tree保持`a1fef5535db3e196580f437040dd5b1f86fd70db`；services Tree保持`7cbd25640b8c0f0c23de7e32cb60cb2e04bc9166`。
- 审阅时GitHub main仍为`e802b926a95e49f7b8398fd85ac7ed8463777d0c`；未合入未接受产品源码，main的接受产品对象不变。
- 原v10.1.0冻结plan Blob `d2123f345b9455d5db8311662be93ac69de795b6`、首份task Blob `f1a78c960b694a081a429e534bf66ea835067977`、初次实施报告Blob `7757b1c47070e916b61a766c6d6f2a935db6ef54`保留。

## 3. R1目标与实际完成分类

1. **资源保全——PASS WITH LOCAL_ONLY LIMIT。** 报告载明云端658个受检源文件0 mismatch、5份既有备份hash和可读性未变、8项试点服务active、旧SSH配置/旧SFU/原dirty根的限定身份一致；未清理备份、媒体、卷或worktree。上述云端与Windows运行事实是`CODEX_REPORTED / LOCAL_ONLY`，Astra未直接登录主机执行。未有全量dirty/untracked/ignored文件的前后字节清单，故不认证全资产字节不变。
2. **受控开发端点——PASS WITH OBSERVATIONS。** R1将既有debug APK的6项build-time define与原转发关系集中登记在LOCAL_ONLY dev-profile，未修改或重构通用产品地址系统；报告限定APP HTTP 8030、实际消息WS 8081、RTC 8033经loopback与既有受控SSH通道使用。外部裸IP、公网域名、443、未批准的新转发/网络规则均未启用。此次只执行3项最小匿名GET与本机端口/进程读回，未重启APP、AVD或重跑WS/RTC媒体。
3. **备案/公司资质延期登记——PASS。** 明确公司注册、网站/APP备案与上架以后视产品完整度、内部会议质量与实际运营计划再决定；整理已知debug APK/正式包区分、debug证书指纹、后端通道、后台入口和待决主体资料，不冒称已取得许可或已申报。
4. **最小验证与交付——PASS WITH EVIDENCE LIMITATION。** Codex报告configuration-check、APK签名/包身份、最小GET、final-netstat/final-owned-process等限定检查成功；原失败与漏保存的隧道父脚本独立命令流仍如实登记。最终只读PowerShell脚本受到执行策略阻断(exit1)，其后使用netstat/tasklist证实监听/进程，但**没有直接二次读取完整进程命令行**；不能凭该替代证据宣称验证范围更广。未重新执行业务、算法、RTC、数据库重启或外部访问验收。

## 4. 必须保留的未解项

- **公网备案入口：** 外部域名已有`403 Non-compliance ICP Filing`，本轮未重测；证书续期、443、受邀同事外部`/admin`登录均NOT_RUN，AC-10.1-08继续PARTIAL。
- **R1开发profile：** 仅LOCAL_ONLY准备清单与既有编译配置的准确登记，没有生成新APK、没有使生产构建获得新的受信任地址管理能力；未来切域名/新网络需重建、检查签名/构建门与真实运行。
- **WS实际消费：** 当前聊天仍派生loopback8081，不能把profile里WS8030当作实际使用路径。
- **Android网络范围：** 旧`network_security_config.xml`的base-config仍较宽，现有pilot业务白名单不等于所有SDK明文流量均已限定。
- **RTC信令信任：** 客户端尚无对join-info返回URL的独立pilot host白名单；当前信任依赖服务端授权、私有代理与已核验端点。公网/多环境扩张前需要专门收口，不在本R1里偷加范围。
- **既有科学/测试与运行观察：** 主实施报告的旧PHP integrated smoke失败、历史RTC/AEC及科学/许可限制、human audibility NOT_TESTED、call10音频RMS=0和其它原始失败全部维持，不以R1最小检查追认。
- **实际网络等级：** 本地三转发建立与8服务状态、各备份SHA等都由Codex执行并保留LOCAL_ONLY原证；Astra只审阅远端报告及可读取Git对象，未独立连接云端或重跑原始命令。
- **活动状态并发：** R1开发分支的`CURRENT_STATE.md`源自旧开发分支；main另有较新的Owner备案延期决定与R1任务入口，后续若安全集成产品必须保留main全部并发治理文档，不得整体merge开发分支的旧活动状态。

## 5. 正式项目状态

- `V10.1.0_R1_ACCEPTED_WITH_OBSERVATIONS`：仅本同版接续目标。
- `V10.1.0_PARTIAL_DELIVERY / NOT_ACCEPTED`：整版仍未最终接受。
- `AC-10.1-08_PARTIAL / EXTERNAL_ICP_GATE_OWNER_DEFERRED`：不变。
- `MAIN_PRODUCT_V10.0.11_ACCEPTED`：保持原有效接受产品。
- `V10.1.0_PRODUCT_MAIN_INTEGRATION_NOT_AUTHORIZED`：不动。
- 公司、域名、网站/APP备案、生产上架：Owner未来根据功能和内部评审另行决定，不应从R1自动触发。
- 下个功能版本须Owner与Astra**在版前单独讨论**，此次不规划、不冻结、不派发。

本验收是doc-only状态登记，不要求Codex重新执行R1，不操作云资源、不清理审阅分支/开发备份、不启动公网入口。
