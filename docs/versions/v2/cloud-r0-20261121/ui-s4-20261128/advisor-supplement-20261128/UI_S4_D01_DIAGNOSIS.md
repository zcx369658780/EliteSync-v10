# UI-S4 补证｜D01 社区返回位置

候选 `com.elitesync.v2uis4qa / 1011818`。固定源码 `0ca97a15c35e9730a3c1c68a03fbdc5c09afd0f9`。在 emulator-5592 上使用原好友长列表的隔离数据库副本。每次比较同一稳定标题对应可见语义框的顶部 y 值，坐标单位为物理 px。下面是可共同读回的视口锚点，第二页打开详情的作品为另一卡片。因此记录的是同卡锚点的位置保持，详情标题和视口锚点分别记账。

| 当前页 | 可共同读回的视口锚点 | 详情直接返回 | 切换喜欢后返回 |
|---|---|---:|---:|
| 好友动态的第一页 | S4 Friends 36 | 0 px | +74 px |
| 加载下一页并重新定位后的第二页 | S4 Friends 19 | 0 px | +74 px |

源码确认两处相邻事实。详情互动使列表 provider 失效，刷新后一帧会重新布局。页面的 `_openPostDetail` 尝试使用 `_feedScroll` 读写像素位置，实际 `ListView` 只有 `PageStorageKey`，未挂接该 controller。因此显式恢复分支读到缺省 0，提前退出。两页的差异与互动刷新相关。列表重建时滚动范围的变化、作品相对位置或行高的各自贡献仍为 `UNKNOWN`。 [列表与恢复](../../../../../../apps/flutter_elitesync_module/lib/features/status/presentation/pages/status_square_page.dart) · [详情互动刷新](../../../../../../apps/flutter_elitesync_module/lib/features/status/presentation/pages/status_post_detail_page.dart)

后续获批时，最小方案先让同一个 controller 负责列表和恢复，保留当前会话、权限 epoch、分页 cursor 校验，并在数据及布局稳定后恢复。如果像素恢复仍因上方内容变动产生偏移，用作品 ID 和该卡相对视口的顶部位置恢复。目标本身失权、撤下或换号时回到当前合法结果及合适位置。

独立验收使用合法虚构夹具，第一页及下一页分别覆盖不变、喜欢、取消喜欢和刷新。每次取同一作品 ID，记录返回前后稳定帧的视口顶部和当前游标，偏移绝对值应 ≤10 px。进入详情时有权限、返回时失权的对照要验证旧卡、旧媒体和旧锚点均不会继续展示。另核对刷新后的点赞计数、分页和正常返回手势。
