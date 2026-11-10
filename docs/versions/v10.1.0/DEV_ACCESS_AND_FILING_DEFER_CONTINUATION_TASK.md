# EliteSync v10.1.0｜R1 同版接续长任务：开发连接收口、备案前置延期与云端试点保全

**2026-10-19 — OWNER_APPROVED_CONTINUATION_SCOPE / OWNER_MANUAL_DISPATCH_PENDING / NO_RESTORED_PUBLIC_ACCESS / V10.1.0_PARTIAL_NOT_ACCEPTED**

## 0. 任务性质

这是 v10.1.0 的**同版**后续长任务，不是 v10.1.1，不重新冻结 AC-10.1-01～AC-10.1-10，也不重开已验证的匹配、聊天、媒体、星盘或RTC全链路。Owner批准将公司注册、网站与APP备案、正式上架推迟到社交婚恋APP功能较完整、内部会议评估质量达标后再决定。现在仍是开发阶段，不是公开内测或正式对外运营。

重要：**Owner提出通过IP固定APP和后台的开发连接方式，但这种技术配置仅能在已核准的受控开发连接中使用；不授权中国内地ECS通过公网裸IP无备案提供网站/APP服务。** 不得把`slowdate.top`的ICP备案403改为IP、端口、反向代理或其他域名来规避。

官方依据（用于界定网络边界，不代替法务意见）：
- 工信部《非经营性互联网信息服务备案管理办法》第五条包含仅以IP地址访问的网站：https://www.miit.gov.cn/zcfg/xxtxl/art/2024/art_7e48434c08c24131b4b7eecfca5b2b6c.html
- 阿里云《常见网站的ICP备案场景及备案要求》明确未备案IP直连网站仍需备案：https://help.aliyun.com/zh/icp-filing/basic-icp-service/product-overview/icp-filing-requirements-for-a-regular-website
- APP备案通知：https://www.gov.cn/zhengce/zhengceku/202308/content_6897341.htm

## 1. 固定来源与当前状态

- 唯一冻结计划：`docs/versions/v10.1.0/plan.md`，Blob `d2123f345b9455d5db8311662be93ac69de795b6`。
- 初次 Codex 任务单：`docs/versions/v10.1.0/task_order.md`，Blob `f1a78c960b694a081a429e534bf66ea835067977`。
- 当前部分交付：分支 `codex/v10.1.0-cloud-devpilot`，最新报告 Commit `939ac6f95d962bed8c75d872c9fa68be2a503933`，文档 Blob `7757b1c47070e916b61a766c6d6f2a935db6ef54`；首次候选 Commit `f077875e83c7a7124e04b70fcfd3cebc8379b633`。
- 最终产品源码锚：`997af1e58e8982eb791ead54861c23e1c1a6e4a2`，源码Tree `f4d39c58785d3a1d64bccc276e6deff9fe64dae4`，apps `a1fef5535db3e196580f437040dd5b1f86fd70db`，services `7cbd25640b8c0f0c23de7e32cb60cb2e04bc9166`。
- GitHub main在本任务编制前最近核验为 `d80d3d0d1650e73e9654362d3a1491450687cdee`；执行前重读实时main，不据旧SHA覆盖。
- 本版原判定：AC-10.1-01..07、09与10在实施报告的限定范围具备可审证据，AC-10.1-08外部受邀Web管理员入口因`403 Non-compliance ICP Filing`仍PARTIAL；整版`V10.1.0_PARTIAL / NOT_ACCEPTED`。Astra尚未终验完整功能候选。
- Owner最新产品选择：管理员使用独立Web后台，手机号/密码登录；不要求同事SSH登录服务器；APP旧管理面板不恢复。原具名SSH测试方案已撤回。之前免费续证及仅`/admin`的443权限在原网络阻断下暂缓执行，不因旧授权强制续期。

## 2. 本次一轮自主工作包

### A. 资源与既有成果保全（最小核验）

核对本版云端独立目录、release/源码对象、database/Redis/php/http/websocket/queue/rtc-authority/rtc的实际身份与状态，以及已归档的管理员/配置/迁移/库备份hash。记录有无从上轮回报后的变化；不要因为只是状态收口而重启、重建、重迁移或清理任何资源。保留原dirty根、旧项目与其他worktree、历史卷/媒体/原证、旧备份和临时审阅分支。

记录云端目前持续运行服务的资源占用/必要维持条件和停止后恢复方法，给出Owner可理解的KEEP_RUNNING或SAFE_PAUSE建议；**未经单独授权不停止影响现有研发的服务**。不能把未做全量字节前后manifest的资产声称已逐字节复验。

### B. IP/地址方案仅作受控开发配置

检查已接受的APK、Flutter、Android宿主、Laravel、WebSocket及RTC终端配置。将开发网络地址固定为**明确作用域的build-time/dev-only profile**，而不是在通用生产配置、客户端公网代码或安全组中写死服务器公网IP。优先复用现有已验证的`127.0.0.1:8030`、WS专属转发及既有加密SSH/ADB reverse，或已经存在且授权的私有LAN/VPN地址（必须真实核验可路由）。

允许在本版本开发副本中维护清晰的单一地址配置来源及Android/Flutter两级防误指校验；必须能在未来换域名时最小化切换，避免代码里散落硬编码公网IP。既有正常客户端、Web后台、消息WS和RTC的端点不得因单一变量强行改为同一公网裸IP；实际每个通道分别记录Endpoint、网络作用域、Transport/TLS/权限以及证据等级。真实功能测试只在既有获授权通道执行。

Web后台开发路径继续使用当前受控管理浏览器/已授权服务器开发路径；不恢复同事SSH方案、不向同事提供服务器账号、不恢复APP管理面板。与同事会面使用后台应等到合法公网或可批准的受控私有访问方式准备好；否则该能力继续标PARTIAL。

不得新增云公网监听、Nginx公共网站、裸IP对外服务、端口映射、云安全组/系统防火墙规则、受公网可访问的443站点，亦不得借其他境外服务器/代理/CDN/VPN作未经批准的对外迁移或备案规避。若所需开发方案无法在当前许可和既有网络下实现，则报告`DEV_ENDPOINT_NETWORK_GATE_BLOCKED`，不要追绿。

### C. 备案与公司资质延后登记

整理一份**技术资料清单**（不需要真正申报）：APP名称、图标、内容分类、语言、现有Android测试包名与未来发布包名区分、证书签名状态和可安全导出的指纹获取方法、后端域名/IP依赖列表、管理后台属性、未来主体/资质/网站与APP备案待核事项，以及运营审批成熟度触发条件。APP签名/证书不准伪造，不能把debug证书冒充正式上架签名。

明确：备案助手建议公司主体只是办理建议；婚恋社交类是否必须公司/行业前置许可证应在未来由属地通信管理局、阿里云接入服务商及适用监管规则核定。未确定项目不臆定。此次**不注册公司、不申请版号、不提交网站或APP备案、不代填主办者声明、不上传身份证件、不查询或操作Owner阿里云备案账户**。

### D. 一次性受影响验证与集中结果

仅针对本次真实改变的开发profile/endpoint边界，执行必要语法/单元/配置身份测试与已授权的最小APP→云API/WS/管理后台联调。没有新产品代码差异则可以复用有效回执，不重建APK、不重跑十项AC和RTC全量窗口。若确实改变APK/Flutter/Android，则重建独立dev APK，核实包名/签名/hash，必要时在受控AVD安装和验证，绝不因网络切换变更已接受算法身份。

有限检查至少覆盖：所有dev endpoint在非开发构建fail-closed，未授权host无法由Intent/bootstrap恶意替换，HTTP明文不出受控隧道，TLS证书验证不被关闭，APP/Web/WS/RTC不能跨账号或跨环境连接，服务端当前同意与鉴权继续生效。真实网络访问如不可行则NOT_RUN，不通过模拟器mock冒称公网可用。

维护原冻结计划/验收结论；新证据只追加至同一版本的单份接续报告，不修改原实施报告中的旧时点事实和失败。不得为了让AC08通过而改写AC或将`PARTIAL`升格为PASS。

## 3. 暂停的外部依赖与明确禁止

- `slowdate.top`当前未备案；外部HTTP403 Beaver `Non-compliance ICP Filing`、云内200，属于既有实测。不得再借公网IP/端口/代理绕过。
- `Certbot`实际续期、443启用、外部正式`/admin`登录、受邀同事访问仍`NOT_RUN / PARTIAL`；此次无意启动这类步骤。
- 不需要当前注册公司、申请上架/备案/许可证；不得以“让Codex备案”为自动提交许可。
- 不使用真实用户生辰、聊天、视频或其备份做开发；不采购付费服务、扩大云费用或改公网网络。
- 不改旧真实生产/历史数据库、管理员密码、持续授权策略；不删除原dirty根、旧卷、备份/私钥、临时审阅材料和已有原始失败。
- 不自动做v10.1.0最终接受、K10产品集成或v10.1.1功能规划；下个功能版本具体内容要由Owner与Astra另行讨论。

## 4. 成功与停止条件

一次性给出：
1. 完整状态：`V10.1.0_DEV_CHANNEL_CONTINUATION_DELIVERED / EXTERNAL_ICP_GATE_OWNER_DEFERRED / AC-10.1-08_PARTIAL / VERSION_NOT_ACCEPTED`；若具体开发链接仍阻断则精准报告PARTIAL/BLOCKED。
2. 固定候选/source commit/tree、所有实际变更产品路径/blob、实际部署是否改变，以及原受保护资产和服务状态的证据等级。
3. IP/private/loopback端点配置矩阵（只记录公开安全的抽象地址类别，不公开敏感内部地址），构建模式、TLS/HTTP/WS/RTC限制和否定检查。
4. 新检查stdout/stderr/exit与原始失败；NOT_RUN逐项列明；LOCAL_ONLY路径与公开审阅副本区分。
5. 轻量备案资料清单及未来触发条件，不含身份证、密码、私钥和完整数据。
6. 后续建议：功能完善→内部评审→资质/备案判断；不得以当前决策冒称已准备好对外开放。

报告保存为`docs/versions/v10.1.0/DEV_ACCESS_AND_FILING_DEFER_CONTINUATION_RESULT.md`，并且只在必要时最小更新活动状态。若在同版开发分支正常发布，使用普通non-force GitHub push、远端回读，**不把未接受的v10.1.0产品源码合入main**。若生成需要Astra直接审阅的脱敏证据，按当前短期证据协议处理；不公开原密钥、私网与真实数据。

本任务获Owner手动派发后一次生效，Codex自主完成，不拆微任务；完成后停止等待Astra审阅。不得启动下一功能版本。
