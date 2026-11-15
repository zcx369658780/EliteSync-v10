# B1 生活方式探索艺术指导 V1

## 当前美术资产状态

2026-11-15，R1-01文档对齐。下表依据产品源码 `2123496a4d347220e17b84eeec4df9d9f9455399`、候选 `10.1.15-dev / 1011501` 的已有记录整理。

五幅图片均已生成，GPT-6 Astra已完成五图静态视觉审阅，状态为 `REVIEWED_WITH_NOTES`。实际图像模型名称为 `UNKNOWN`，模型版本为 `UNKNOWN`，元数据状态为 `MODEL_IDENTIFIER_UNVERIFIED`。AC15-02维持 `PARTIAL_EXACT_MODEL_IDENTIFIER_UNAVAILABLE`。[资产manifest](../../../design/assets/lifestyle-discovery/v1/asset_manifest.json)

| 核验项 | 当前状态 | 证据与范围 |
| --- | --- | --- |
| 五幅插画生成 | `GENERATED_ALL_FIVE` | 五个场景的原图与优化图已交付。[资产manifest](../../../design/assets/lifestyle-discovery/v1/asset_manifest.json) |
| Astra静态视觉审阅 | `REVIEWED_WITH_NOTES` | 已查看联系表和五幅原图。共餐中央桌略大、相聚圆片稍鲜亮的备注保留。[首批静态审阅记录](#2026-11-15-首批生成图艺术复核) |
| APP内实际呈现 | `PASS_IN_NAMED_SCOPE` | 1011501模拟器具名场景呈现与十三张代表截图已有记录。[实施报告](IMPLEMENTATION_REPORT.md)及[代表截图](evidence/) |
| 场景前进与返回动画 | `PASS` | 范围为Widget与观察到的APP导航，对应 `animations_forward_reverse`。[证据摘要](EVIDENCE_SUMMARY_20261115.json) |
| 减少动态效果逻辑 | `PASS`（Widget） | 对应 `reduced_motion` 的Widget验证。[证据摘要](EVIDENCE_SUMMARY_20261115.json) |
| 系统级减少动态效果设备验证 | `NOT_RUN` | 对应 `device_system_reduced_motion`，沿已有记录保留。[证据摘要](EVIDENCE_SUMMARY_20261115.json) |
| 本地素材打包与离线可用 | `PASS` | 范围为APK内五图及题库逐字节核对、本地场景渲染，对应 `offline_artwork`。[实施报告](IMPLEMENTATION_REPORT.md)及[证据摘要](EVIDENCE_SUMMARY_20261115.json) |
| Owner手机验证 | `NOT_RUN` | 对应 `phone` 的本版记录。[证据摘要](EVIDENCE_SUMMARY_20261115.json) |

## 生成前历史快照（已被后续记录取代）

> 生成前历史状态，已被2026-11-15生成及审阅记录取代。下方原始过程文字按当时时点保留。当前分项状态见本文件开头摘要。

日期为 2026-11-15，北京时间。艺术指导由本轮 GPT-6 Astra 助手提供，精确服务端版本未暴露。范围仅为 v10.1.15 B1。主代理保留题库定稿、实现、产品边界、工程验收和 Git 权力。

本文件依据已固定的 `task_order.md`、`plan.md`、`DEVELOPMENT_ALIGNMENT.md` 与 `app_colors.dart`。当前交付为艺术指导和提示词包，未生成、审阅或验收图片，素材状态为 `ASSET_GENERATION_PENDING`。艺术指导模型与之后实际调用的图像模型须分别记录。

## 统一视觉

用五幅安静的日常小景呈现五个问题。每幅画是一处完整空间，所有选项线索同时存在，没有默认被选中的中心人物或高亮物件。不要把主图拆成三个对照小卡，不用更美、更明亮或更大的区域暗示推荐答案。

冻结风格为低分辨率质感、几何色块、低刺激、二次元卡通与构成主义。采用裁纸般的大色面、少量阶梯边缘、克制的颗粒，物体轮廓明确，基本没有细线纹理。拒绝摄影感、真实材质、复杂景深、立体渲染和霓虹。低分辨率质感不等于模糊，手机小尺寸仍需辨认主要物件。

统一采用略俯视的舞台式构图，主物件位于中下部，上部留出呼吸空间。光线为柔和、无方向性强光的日间环境光。所有场景使用同一种圆角几何家具和纸片植物，不加入品牌、豪宅、昂贵交通工具或身份符号。可优先无人物，确需人物时仅用等大小的简化成人剪影，不指定性别、族群、职业、情侣关系或身体标准。

主图按 16∶10 横向矩形设计，适合手机上方展示。四周 8% 为裁切安全区，关键线索放在宽度 12% 至 88%、高度 18% 至 84% 内。最终尺寸由生成能力和客户端清晰度决定，不强制 1080 宽度。五图保持相同比例、视觉尺度和安全区。题目、进度、跳过、按钮、选择说明全部由 Flutter 渲染，图片中不放文字、字母、数字、图标标签或水印。

## 色板与使用比例

| 用途 | 颜色 | 使用建议 |
| --- | --- | --- |
| 现有主色 | `#5AA8FF` | 本地选中描边与少量图中点缀 |
| 现有辅色 | `#8B7CFF` | 小面积紫色物件，与蓝色保持同等强调 |
| 现有强调色 | `#5FE1C8` | 小面积植物或布面，不表示正确答案 |
| 深色框架 | `#08101F` | 遵循现有暗背景，图内仅少量轮廓 |
| 浅色框架 | `#F6F8FC` | 遵循现有浅背景，图内可用作留白 |
| 场景雾蓝 | `#A7C3DE` | 大色面 |
| 场景灰紫 | `#B8B0D0` | 次级大色面 |
| 场景灰绿 | `#AACFC5` | 植物、桌布、地面局部 |
| 场景淡灰 | `#E7EBF2` | 墙面与天空 |

大约 70% 使用淡灰与低饱和色面，25% 使用雾蓝、灰紫、灰绿，5% 以内使用原有品牌亮色。比例是审阅方向，不是逐像素硬指标。场景辅助色只用于插画，不修改全局 App 颜色令牌。选项之间不用红绿对照，不借用成功、错误、警告色。插画不是承载文字的背景，暗浅主题均由现有界面提供可读文本和清楚边界。

## 五个场景与十五个选项

下表是题库定稿建议。映射只记录本题所表达的偏好，采用有限的分类值，不排优劣、不跨题诊断，不凭选择推断经济水平、心理特征或敏感属性。主代理应将最终场景、选项、规则和解释同步到正式题库与机器配置，并使用同一版本号。

| 场景 ID | 题目 | 选项 ID 与显示文案 | 可解释维度 |
| --- | --- | --- | --- |
| `home_atmosphere` | 在家放松时，你更喜欢哪种氛围？ | `quiet` 安静一点 / `background_sound` 有些背景声音 / `situational` 看当天状态切换 | 居所声音氛围 |
| `travel_structure` | 去一个新地方走走，你喜欢怎样安排？ | `planned` 提前排好主要行程 / `open` 到了再随兴探索 / `mixed` 定几个去处，其余留白 | 旅行安排方式 |
| `weekend_activity` | 空出半天时，你通常更想做什么？ | `rest` 放空休息 / `movement` 出门走走活动一下 / `making` 做点手作或创作 | 空闲活动偏好 |
| `meal_company` | 有空好好吃一顿时，你更想怎样度过？ | `one_to_one` 和一个人慢慢聊 / `small_group` 三五个人一起吃 / `solo` 自己自在地吃 | 共餐人数偏好 |
| `shared_time` | 长期相处中，你更喜欢怎样安排相聚时间？ | `regular` 留出固定的相聚时间 / `spontaneous` 有空时再约 / `flexible_plan` 提前商量，也留出调整空间 | 相聚时间安排方式 |

每题均允许用户按近期倾向回答，并可返回纠正。不存在“正确选项”。共餐只表达这顿饭的人数偏好，不解释为外向或内向。居所声音不等于社交需求。长期相处不限婚姻或同居，不询问婚育、房产、收入或承诺水平。旅行计划与相聚时间分别描述出行和人际安排，不把二者合并成“自律性”评分。

## 构图与本地反馈

五图均保持等权的三个视觉线索。表中的位置是美术构图目标，生成后需检查实际位置，再确定本地归一化锚点，不能假定提示词能保证像素坐标。

| 场景 | 一张主图的内容 | 三个反馈线索，从左至右 |
| --- | --- | --- |
| 居所氛围 | 普通小客厅，窗、软垫、矮桌、无品牌小音箱，均无奢华材质 | 窗旁安静软垫 / 桌边小音箱 / 可切换位置的两块等大坐垫 |
| 旅行安排 | 同一公园入口与弯曲步道，前景一张无字地图和三枚普通石子，不出现酒店或交通等级 | 连续短路径 / 宽松分散小点 / 短路径接留白 |
| 周末活动 | 公园边的公共休闲角，三块等大小空间融在同一画面 | 靠垫坐席 / 平缓步道 / 纸张与彩色几何积木桌 |
| 共餐人数 | 同一个日常共餐空间，三张等大朴素圆桌，食物份量与装饰不过度区分 | 两个等大座位 / 四个等大座位 / 一个座位 |
| 相聚时间 | 普通共享活动室，背景为窗和空白软木板，前景三组相同圆片与短线构成时间安排意象 | 等距圆片 / 自由分布圆片 / 两枚有序圆片接一枚可移动圆片 |

主图只承担情境，选项文案承担准确含义。不要让用户必须识别抽象图案才能回答。若三组线索难以准确生成，保留简洁统一的情境主图，将所有三组抽象线索交给 Flutter 绘制，不能为弥补生成误差增加十五张选项图。

选择反馈复用一套本地几何组件。可用圆角轮廓、两枚短线和低透明品牌色面，叠在当前选项对应锚点附近。一次只显示一个选中图层，配合按钮选中形态与可访问性标签，颜色不是唯一信号。反馈不加奖章、分数、烟花或优劣评语。主图不能烘焙选中状态，不用重新生成图像表示修改答案。

## 正向、反向与减少动态效果

选项反馈使用一个 0 到 1 的本地动画进度，建议 180 至 220 毫秒。进度控制轮廓淡入与轻微展开，最大缩放建议 1.00 到 1.02。改选时旧反馈退回 0，新反馈推进 1，快速连续点击从当前进度衔接，最终只以最新选择为准。

场景前进采用约 240 毫秒的短距离水平过渡与淡入，移动距离约为卡片宽度的 4%。返回时沿相反方向回放同一组变换，读回上一题已保存选择。返回是导航行为，不能把它当成撤销已保存答案。动画状态与答案持久化分开，任何动画中断都不能导致答案丢失或虚构完成状态。

系统启用减少动态效果时，关闭位移、缩放、视差与自动播放，仅保留即时状态切换或极短淡入。此方案不包含音乐、声音或额外音频资源，因此不会默认播放。若后续在既定范围内加入音频，必须另行落实静音与系统偏好，不能把本文件当成已验证音频行为的证据。

## GPT Image 提示词包

正式生成时对每幅图使用下方公共前缀，加对应场景段落。第一幅合格图可作为其余四幅的风格参考，参考图只用于保持画面语言，不能复制场景内容。若工具不支持图像参考，重复同一前缀并通过联系表人工核对，不假定独立生成会自动一致。

### 公共前缀

```text
Create one horizontal 16:10 editorial illustration for the upper part of a mobile lifestyle discovery screen. A calm low-resolution-inspired 2D cartoon with constructivist composition, large cut-paper geometric color blocks, a few deliberate stepped edges and very subtle grain. Crisp recognizable silhouettes at small display size. No photorealism, no 3D rendering, no glossy materials, no cinematic lighting, no detailed textures, no neon.

Use a consistent slightly elevated stage-like view, simple rounded geometric furniture, paper-cut plants and diffuse quiet daylight. Use pale gray #E7EBF2, mist blue #A7C3DE, muted lavender #B8B0D0 and muted mint #AACFC5 for most areas. Reserve tiny accents for #5AA8FF, #8B7CFF and #5FE1C8. Very limited deep navy #08101F outlines and off-white #F6F8FC breathing space. Low contrast within the illustration, clear large shapes, no dark or bright spotlight on any choice cue.

Compose one coherent everyday setting, not three separate panels or a comparison chart. Keep all three described cues equally visible and similarly weighted. Do not imply a preferred or superior choice. Put essential content within the central 76 percent of the width and between 18 and 84 percent of the height. Keep the outer 8 percent safe to crop and leave the upper area visually quiet. Prefer an unoccupied scene. No luxury objects, brands, status symbols, romantic stereotypes or identity cues. No text, letters, numbers, labels, interface controls, selection marks, logos, signatures or watermarks. The app will render every question, option and selection indicator separately.
```

### 居所氛围

```text
Show a modest comfortable living room as one continuous space. A window, a low rounded table, a small plain speaker without a screen, cushions and one paper-cut plant. Arrange three equally weighted cues across the lower middle of the image. On the left, a comfortable quiet window cushion. Near the middle, the small speaker on the low table. On the right, two matching movable cushions arranged casually. Keep the room equally welcoming throughout, with no person and no symbols for silence or music. Do not visually rate the cues. No headphones, sound waves, musical notes or readable controls. This is an ordinary place to unwind, not a property advertisement.
```

### 旅行安排

```text
Show a public park entrance and a gentle winding walking path in one continuous everyday landscape. Put a blank folded paper map on a simple foreground bench with a few small smooth stones. Three restrained geometric arrangements near the lower middle suggest a short orderly path on the left, loosely scattered stepping dots in the middle, and a short path followed by open space on the right. These arrangements must have equal scale and visual emphasis, without arrows, checkmarks or labels. Keep the real park path soft and welcoming. No airport, hotel, car, luggage brand, tourist landmark or expensive equipment. The image evokes ways to explore a new place, not distance traveled or spending power.
```

### 周末活动

```text
Show a quiet public leisure corner beside a small park, as one connected setting. Across the lower middle, give equal visual weight to a simple cushioned seat on the left, an easy flat walking path in the middle, and a small plain table with blank paper and a few colorful geometric craft blocks on the right. Use the same modest scale and pleasant daylight for all three cues. No athletic performance, fitness body, finished masterpiece, trophies, productivity symbols or equipment brands. Resting, moving and making should all feel equally available and worthwhile. No people are needed.
```

### 共餐人数

```text
Show one modest shared dining space with three equally sized plain round tables in a continuous room, not separate panels. Keep the tables and surrounding floor areas equally weighted. The left table has two simple matching seats, the middle table has four matching seats, and the right table has one matching seat. Use the same understated bowls, cloth colors and visual quality across the tables. Do not make the single seat lonely or the group table more festive. No people, romance symbols, alcohol emphasis, restaurant branding, fine dining cues or lavish food. The number of seats is the only meaningful difference.
```

### 相聚时间

```text
Show a simple shared activity room with a broad window, an empty cork board and a low foreground shelf. Across the lower middle, arrange three groups of identical soft geometric discs and short line pieces as subtle abstract still-life objects. The left group uses evenly spaced discs, the middle group places discs freely, and the right group uses two ordered discs plus one loose disc with room around it. All groups must use equal object size and equal color emphasis. The objects gently evoke regular, spontaneous and adjustable ways of spending time together. No calendar text, numbers, clocks, wedding imagery, family roles, children, money, home ownership or permanence symbols. Do not imply that one arrangement is more responsible or loving.
```

## 生成、审阅与交付准则

生成服务使用当时可确认的最新在线 GPT Image，不能将艺术指导模型名写进图像模型字段。记录工具实际返回的精确模型标识、日期、完整提示词、参考图身份、输出尺寸、压缩处理、权利或条款依据和 SHA256。工具若不暴露精确版本，明确记录 `UNKNOWN` 与可得标识，交主代理评估 AC 缺口，不凭猜测填写版本。模型不可用则保持 `ASSET_GENERATION_PENDING`。

资产固定在 `design/assets/lifestyle-discovery/v1/`。建议五幅优化主图使用场景 ID 命名，另附五图联系表、提示词包、元数据和 SHA256 manifest。原始生成物与优化输出的身份分别记录，优先压缩与合适尺寸，不自行引入 Git LFS、付费存储或未知来源素材。所有运行时引用均为本地固定资源。

一致性审阅先看五图联系表，再按真实手机显示大小查看。以下条件需要逐项留下实际结果，未执行记为 `NOT_RUN`。

- 五图是否保持同一视角、几何边缘、颗粒密度、物件尺度、色板和留白。
- 每张是否仍是一幅完整生活场景，三种线索是否同等清楚，是否意外形成好坏、热闹与孤独、贫富或承诺高低的对比。
- 是否出现伪文字、水印、品牌、真实人物特征、婚育暗示、财富暗示或写实渲染。
- 手机裁切是否保住关键物件，本地反馈是否对齐实际锚点，叠层是否遮挡物件或泄漏到安全区外。
- 文字与按钮是否全部由 Flutter 提供，选中态是否同时具有形状和可访问性说明，是否能在暗浅主题下识别。
- 前进、返回、改选、快速连点与动画中断后是否保持正确选择，减少动态效果是否关闭位移与缩放。
- 离线是否可展示五图和全部反馈，图片尺寸与总包体是否在主代理实际评估后接受。

> 下段为生成前历史状态，已被2026-11-15生成及审阅记录和后续工程验证记录取代。

当前图片与动画审阅均为 `NOT_RUN`。本指导不构成正式素材验收、用户偏好测量有效性证明或产品接受。用户答案不得进入图像提示词，不调用运行时 AI，不改变匹配算法。

## 2026-11-15 首批生成图艺术复核

> 本节保留五图静态审阅时点的记录。其中运行时呈现、动画、减少动态效果和离线检查的 `NOT_RUN` 为该时点状态，已由后续实施报告及证据摘要中的具名验证记录更新。当前分项状态见本文件开头摘要。

本次由 GPT-6 Astra 查看 `design/assets/lifestyle-discovery/v1/preview.jpg` 与 `originals/` 下五幅 PNG 原图。以上 `ASSET_GENERATION_PENDING` 和图片 `NOT_RUN` 保留为生成前记录。本次只将所列图片的静态视觉审阅记为 `REVIEWED_WITH_NOTES`，不代表 AC15-02 完整通过或正式素材接受。真实图像模型精确版本仍未暴露，保留 `UNKNOWN`。运行时呈现、动画、减少动态效果和离线检查仍为 `NOT_RUN`。

五图共同采用雾蓝、灰紫和灰绿，柔和纸感颗粒、阶梯背景和大块几何物件形成一致语言。画面是二次元平面插画，未见摄影、复杂材质或三维渲染漂移。低分辨率质感主要表现为简化轮廓与阶梯边缘，未采用硬像素点阵。五图均无人物、可读文字、品牌、水印或明显的身份、财富和婚育暗示，联系表标题属于预览标记，不属于场景图内容。

居所、旅行和周末图的三类线索可辨认，主图上方均有充足留白。共餐中央四人桌略大于两侧桌，构图等权有轻微偏差，未出现奢华或孤独的明显对比。相聚图的前景圆片亮度与饱和度高于其余四图，但三组圆片沿用相同颜色与尺度，没有预选状态。建议保留这些观察，由主代理结合手机预览判断，不据此自行重生成。所有本地反馈采用同一强度和大小，避免再强调中央共餐选项或相聚图亮色。

下列锚点是根据原图目视估计的中心坐标，原点位于图像左上角，宽高各归一为 1。它们只用于选择反馈定位，不作为图片热区或无文字题目。应按实际渲染后的图像矩形换算，遇到裁切需重新核对，不能直接映射到整个卡片。

| 场景 | 左侧选项锚点 | 中间选项锚点 | 右侧选项锚点 | 对应内容 |
| --- | --- | --- | --- | --- |
| `home_atmosphere` | `(0.14, 0.61)` | `(0.49, 0.69)` | `(0.83, 0.74)` | 窗边软垫、小音箱、可移动坐垫 |
| `travel_structure` | `(0.24, 0.70)` | `(0.48, 0.67)` | `(0.70, 0.72)` | 连续石板、散布圆石、两块石板与留白 |
| `weekend_activity` | `(0.24, 0.74)` | `(0.49, 0.75)` | `(0.81, 0.69)` | 坐席、步道、手作桌 |
| `meal_company` | `(0.19, 0.63)` | `(0.50, 0.63)` | `(0.79, 0.63)` | 两人桌、四人桌、单人桌 |
| `shared_time` | `(0.21, 0.77)` | `(0.48, 0.76)` | `(0.79, 0.77)` | 等距圆片、自由圆片、可调整圆片 |

选择反馈不应覆盖共餐椅子数量或相聚圆片排列。旅行前景地图和相聚柜体延伸至下边缘，属于可裁切环境物件，关键选择线索仍在内部。周末手作桌偏右，居所坐垫也靠近右侧，额外横向裁切尤其需要手机复核。现阶段锚点校准属于建议，未实测客户端叠层。

本次审阅原图 SHA256 如下，后续替换图片须重审受影响部分。

| 原图 | SHA256 |
| --- | --- |
| `home_atmosphere.png` | `473519A8CCD81F4C7D8277BAADBF230B92C2B2AA468DDD950792327BE3DB7789` |
| `travel_structure.png` | `12B1E1347675241A5856C390615BDAA378695F1A459C0CBFFAE0B282E498DE51` |
| `weekend_activity.png` | `80587D18ED862E5C5A53A5C0F43EA35E3209AF0316F8AAC2539D02A8F7AC85A1` |
| `meal_company.png` | `BEE5EB4001119E89977B3CB26A65C9056A6EA5646926EE120FEC8AC3B8E19907` |
| `shared_time.png` | `F5F57BEB0743967404D859100AC915FC67E20577AFDAFFA03A6F7AFFD77AE1CB` |
