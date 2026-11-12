# EliteSync v10.1.5 顾问验收入口

Owner于2026-11-12要求将验收资料上传GitHub新分支，本目录据此提供功能说明、120张实际截图、控件与导航结构、实际测试结果和去敏证据摘要。

## 阅读顺序

1. [APP功能说明](APP_FUNCTIONS.md)
2. [全部已盘点按钮、菜单、条件和导航层级](UI_NAVIGATION_AND_CONTROLS.md)
3. [GitHub截图画廊](GALLERY.md)、[截图索引](SCREENSHOTS.md)、[截图与控件元数据](screenshot-index.json)
4. [实际测试结果与未完成项](TEST_RESULTS.md)
5. [实施报告](IMPLEMENTATION_REPORT.md)、[代码与APK身份](artifact_manifest.json)、[证据摘要](evidence/README.md)

[HTML检索画廊](GALLERY.html)可在下载此目录后用浏览器打开。GitHub画廊可直接展开各图，全部PNG均与本机资料包原图SHA256一致。

## 代码身份

- APP源码 `0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f`。
- 后端源码 `6549f02880968f99ae3f45439d15a37c1b3d5251`。
- 上传基线 `790d684191ccf0076959492d3e280381f8f01d84`。
- 分支 `codex/v10.1.5-advisor-acceptance-20261112`。
- 当前APK的SHA256为 `1e9adad71b962c8adfcfd280450ed9ae9e5b1f7127988d225a036e3c3826dfea`，身份详情见manifest。

## 验收状态

通知闪烁获Owner实机确认，版本误降级、选图发送衔接、后台RTC快照累积与来电过期停留已作具名修复及定向验证。最终同包call46自然过期自动终态、47正常拒绝与熄屏恢复通过。其余消息、媒体、问卷、MBTI、私有盘和管理页面按各自候选和实际范围记录。

当前仍为 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。顾问总验收和Owner最终接受PENDING。自然期限、硬件、完整权限并发/停媒/长时、蓝牙、部分条件页与正式构建变体含NOT_RUN/UNKNOWN，盘面独立准确性UNVERIFIED，媒体开发服务monitor超时根因UNKNOWN。

当前开发包使用恢复本地构建。资料使用虚构测试数据。截图保留原采样候选与失败身份，源码控件图谱的SRC_ONLY与实际设备结果各自标记。

## 本次上传范围

本目录收录验收文档、120张已核对测试截图、画廊、控件元数据、去敏结果摘要和文件哈希清单。发布清单记录每个上传文件与本机资料包的来源。Owner本机保管APK、凭据、SQL/数据库、许可证、原始设备日志与原始私有回执。
