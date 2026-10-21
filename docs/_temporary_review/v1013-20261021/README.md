# v10.1.3 一次性公开脱敏审阅副本

状态：CODEX_REPORTED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE。基线、源码、APK身份见 source-identity.json 和 apk-final-manifest.json。完整产品源码及测试可在本分支父提交 e27db2012e2c57390c4da179330552a6b64a728d 直接审查，34项path/mode/blob见 changed-product-paths.json。

此目录只在独立短期审阅分支跟踪，不能合入main或产品候选分支。原件留本地；无账号凭据、私有SQL、APK、设备日志、截图、原始JWT、capability或个人路径。command-exit-index是执行原流的exit与SHA256索引；final-check-receipts是实际stdout摘录，绝不代表全部原流已公开。失败均保留，rr-three-cases-v2整体仍为exit1。

证据分层：HTTP正负例走真实Laravel入口；Buddy双进程竞争调用实际产品服务，不冒称双HTTP socket；RR读者走HTTP，写者为独立CLI事务中实际Controller/service；APP和Web证据来自执行方实际受控操作。独立复核未亲自重跑物理链，Astra须自行核源码和回执。最后SELF撤权发生在重启一致性检查之后。

所有个人路径以占位符脱敏。重启hash仅含本版虚构开发表，未公开数据内容。最终SQL备份、带账号/令牌的UI原证和完整运行原流均LOCAL_ONLY。BYTE_MIRROR_PENDING不等于Owner未更新ChatGPT附件。资源已停止，卷保留。阅后清理须另行精确授权，当前未清理。
