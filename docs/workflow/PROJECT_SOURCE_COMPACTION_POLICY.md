# Project Sources 瘦身与历史封存规则

生效：2026-10-31。Owner已授权本轮项目源治理。适用于ChatGPT Project Sources与本仓库的长期同步。

## 1. 权威分层

1. 工程实时状态只认 `docs/workflow/ACTIVE_STATE.md` 的最新首段和live main；项目源状态文档只作启动摘要，不得覆盖GitHub实时状态。
2. 当前会话交接只保留一个最新有效入口。旧交接、旧状态快照、旧任务入口按形成时点封存，不继续作为首读材料。
3. 稳定产品原则、Owner决定、冻结计划、正式验收与运行回执分开；不得把规划、CODEX_REPORTED、LOCAL_ONLY、NOT_RUN、PENDING混写为接受事实。
4. 冻结计划/原始接受设计/Owner决定不因瘦身而改写其历史含义。可在Project Sources中以短摘要替代全文，但必须提供GitHub固定路径和适用边界。

## 2. Project Sources 保留规则

- 只保留：一份首读索引、一份当前状态摘要、一份稳定治理/架构边界、一份Owner决定摘要、一份路线图摘要、必要的原始设计/接受材料（按需读取）、一份工作流摘要、必要研究结论摘要。
- 删除Project Sources中的重复别名、过期CURRENT快照、旧交接全文、已被GitHub固定文档取代的历史执行快照；这仅指下一版Project Sources ZIP，不删除GitHub历史文件、Git对象、分支、备份或本地原件。
- 大型历史研究、竞品盘点、历史失败报告、旧任务单、旧验收证据留在GitHub具名归档/原始路径；Project Sources仅保留结论摘要、证据级别、局限和链接。
- 不复制完整ACTIVE_STATE、TASK_CURRENT、CURRENT、全量日志或整仓清单进入Project Sources。
- 同一正文不得以多个文件名重复装入；别名只在索引里说明对应的唯一规范路径。

## 3. 交接与证据复用

- 新会话首读：本索引 → 最新交接 → ACTIVE_STATE当前首段 → 当前冻结plan（仅当前版本）→ 本次真正相关的专项合同。
- 不递归展开旧交接引用；仅在新任务触及对应事实且证据适用时，定点读取原文。
- 既有接受证据按源码Tree/Blob、适用测试和失效条件复用。只有源码、环境、合同或风险边界发生相关变化时，才执行增量重验。
- 每份摘要必须标注快照日期、GitHub权威链接、非权威声明和不得推断事项。

## 4. GitHub封存与保全

- 历史文件不做删除、重命名、force-push或覆盖。封存通过日期化索引记录原路径、原Blob/commit（可取得时）、历史时点、为何不再首读及其继续适用的证据范围。
- 历史文档中当时真实的PENDING/NOT_RUN/授权状态仍是历史事实，不得倒填成当前状态。
- 任何原始私密证据、密钥、个人数据、LOCAL_ONLY日志/APK/数据库不进入公开GitHub或Project Sources。

## 5. ZIP交付

- 每次生成日期化完整替换包，包含该版全部Project Sources文件、README/索引、文件清单与SHA-256 manifest。
- ZIP只包含唯一版本的完整新集合，不把增量包与旧集合叠加；Owner手动替换旧Project Sources。
- 生成ZIP不等于GitHub同步，也不等于Project Sources已替换。Codex必须分别回报GitHub归档/规则同步与本地项目源镜像状态；Owner手动上传后再确认Project附件已替换。
- Codex仅按Owner派发的文档同步指令操作，不触碰产品源码、运行库、构建、ADB、设备或任何版本预算。

## 6. 本轮适用

本轮新ZIP以2026-10-31项目源快照为准，保留v10.1.5当前PARTIAL/AC05 OPEN/G2 false/真实Push PENDING等事实；两项Owner新运行授权仅在当前对话明确记录，不代表任务已发布/派发/执行。瘦身完成并由Owner手动替换Project Sources、Codex完成本地镜像同步后，才继续已授权的v10.1.5剩余工作。
