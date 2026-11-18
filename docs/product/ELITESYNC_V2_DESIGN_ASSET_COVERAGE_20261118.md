# EliteSync V2｜A0–A6.6 设计资产核查与缺口（2026-11-18）

状态：`LOCAL_ORIGINALS_SAVED / GITHUB_ORIGINAL_SVG_VERIFIED / GITHUB_ORIGINAL_PNG_PENDING`。

## 一、结论（不可误报）

本地交接包从会话挂载文件中逐SHA去重，保留54项不同内容的设计与说明文件：**43项PNG、4项SVG、6项Markdown、1项PDF**，每一项在ASSET_MANIFEST.json和ASSET_MANIFEST.csv列出相对路径、大小和SHA256。会议包自身及Project Sources的2026-11-12快照为附属参考，不计入54项素材清单。

GitHub已实现的内容：A1–A6.5的多份产品决议、审查清单、低保真结构重绘SVG；本次补入A6.6的设计说明以及4份**原始SVG**，且4份GitHub Blob SHA和本地Git Blob SHA逐字节一致。

**但原始PNG截至本核查还没有直接通过当前GitHub连接上传。** GitHub提供的重绘SVG不能证明对应PNG原件存在。故用户提出的“全部原稿都已在GitHub”条件仍然`PARTIAL / PENDING_BINARY_UPLOAD`，不能宣布完全闭合。本地完整包已保存所有可读取的原始PNG和必要原始SVG。

## 二、各阶段概念稿核对

| 阶段 | 关键设计成果 | Owner状态 | GitHub设计文档/重绘SVG | 本次原始原件情况 |
|---|---|---|---|---|
| A0 | 三张初始海报式构成主义二次元探索 | 仅历史视觉方向参考 | 后续设计文档可追溯 | PNG原图在本地包，GitHub PNG待补 |
| A1 | 首次Lifestyle、内容首页、匹配准备 | Owner认可阶段方向 | 早期A1–A3归档和重绘结构图 | PNG原图在本地包，GitHub PNG待补 |
| A2 | Lifestyle题、登录/访客首页、匹配状态 | Owner认可概念方向 | A1–A3设计及重绘SVG | PNG原图在本地包，GitHub PNG待补 |
| A3 | Lifestyle保存中/失败/改选/恢复 | Owner认可概念方向 | A3重绘SVG与设计说明 | PNG原图在本地包，GitHub PNG待补 |
| A4/A4-R | 提案、Connection、消息许可、聊天及等待撤回失效 | Owner认可概念方向 | A4/A5 V0.3及结构稿 | PNG原图在本地包，GitHub PNG待补 |
| A5/A5-3/A5-4 | 四入口、资料回流、消息/我的、八项检查清单 | Owner明确认可审查清单 | A5归档、A5-4原文重读归档 | PNG在本地包，GitHub PNG待补 |
| A6 | 会议规范/PDF/Markdown | 材料内容可用但会议暂缓 | 早期产品文档引用，未正式冻结 | 原PDF及会议原件在本地包，GitHub原件待补 |
| A6.1 | 匹配2/5、消息通知、我的三屏 | Owner认可概念 | A6.1文档与重绘SVG | 「我的」原始SVG **GitHub SHA一致**；PNG在本地包 |
| A6.2 | 主头像昵称、社交/匹配覆盖与对外展示 | Owner认可概念 | A6.1–A6.5汇总 | 原始SVG **GitHub SHA一致**；PNG本地 |
| A6.3 | 来源/用途/受众/修改影响 | Owner认可概念 | A6.1–A6.5汇总 | 原PNG本地，GitHub原PNG待补 |
| A6.4 | 授权撤回与资料纠错独立 | Owner认可概念 | A6.1–A6.5汇总 | 原始SVG **GitHub SHA一致**；PNG本地 |
| A6.5 | 易截图可留证、可退出反馈、失权脱敏 | Owner明确接受并要求归档 | A6.5详细说明与重绘SVG | 原PNG本地，GitHub原PNG待补 |
| A6.6 | 跨页面状态一致性恢复五屏 | **待Owner审阅** | A6.6原始设计说明 | 原始SVG **GitHub SHA一致**；PNG本地 |

## 三、原始SVG核验

| 文件 | GitHub位置 | 本地/GitHub一致的Git Blob SHA |
|---|---|---|
| A6.1 我的简化三屏 | `docs/product/ui-concepts-20261118/original-svg/A61_ME_SIMPLIFIED_ORIGINAL.svg` | `7017a8fa691658bb209a3ad05332cff31d268817` |
| A6.2 形象与展示权限 | `docs/product/ui-concepts-20261118/original-svg/A62_AVATAR_DISPLAY_PERMISSIONS_ORIGINAL.svg` | `d58639cfa317cd6c2ea5d295894670f6413940d3` |
| A6.4 授权撤回与资料纠错 | `docs/product/ui-concepts-20261118/original-svg/A64_WITHDRAW_CORRECT_ORIGINAL.svg` | `9ce672dfb2f29c6bc9bf5d8e6e1c786807974342` |
| A6.6 跨页面五屏 | `docs/product/ui-concepts-20261118/original-svg/A66_CROSS_PAGE_RECOVERY_ORIGINAL.svg` | `9ac9145de04e1b4948331761ace5949cd31770a3` |

A5-4、A6.1、A6.5、A6.6的原始Markdown从附件中通过文本接口重读并存储为source-notes，但**文本归一化读取不保证与本地文件字节一致**，不对其宣称原字节SHA一致。

## 四、如何闭合缺口（需Owner后续手动同步或拥有二进制上传能力时执行）

1. 在本地备份ZIP中读取`ASSET_MANIFEST.csv`与`CHECKSUMS_SHA256.txt`，通过SHA验证所有原始PNG。
2. 在Owner确认不影响本地未提交成果/工程后，用包中`tools/import_assets_to_repo.sh`将已认可稿和探索稿复制到治理分支的`docs/product/ui-concepts-20261118/original-render-assets/`下（脚本**不自动git add/commit/push**）。
3. 使用现行已授权Git管理流程核对路径、差异、大小及敏感内容，然后Git提交至治理分支（**不合main**）；必要时由Owner手动操作或明确授权执行，不是Codex产品开发任务。
4. 在GitHub用原文件下载哈希与本地SHA对比，按本表逐阶段关闭`PENDING_BINARY_UPLOAD`，更新CSV中的`github_exact_original_verified`状态。
5. 不使用图片重绘文件、GitHub文件名或聊天截图链接冒充原始PNG已经存入GitHub。

## 五、权威边界

图像生成的概念示意可含与真实合同不符的字段和状态，**产品决策Markdown优先于图中示意文案**；A6.6仍是顾问方案，未获Owner最终接受。仓库治理资料不是本地工程或现行功能验收。Codex当前无新实施授权；会议暂缓。