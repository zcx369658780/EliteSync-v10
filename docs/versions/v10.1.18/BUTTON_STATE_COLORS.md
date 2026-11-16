# 按钮与选项状态色规范

本版在共享主题中统一 Filled、Outlined、Text 按钮和探索选项的状态样式。默认、按下、选中、禁用、键盘焦点和危险操作均使用主题色及文字色配对。Lifestyle 选项使用 primaryContainer 与 onPrimaryContainer，选中态保留勾选语义和边界，撤销自动化授权使用危险操作样式。焦点以 2px 描边表示。

| 样式 | 状态表现 |
|---|---|
| 主要操作 | 主色背景与对应前景色，禁用时改用次级表面与次级文字色 |
| 次要操作及文本操作 | 透明或表面背景、主题前景色，按下与悬停采用低透明度遮罩 |
| 已选选项 | primaryContainer 背景、onPrimaryContainer 文字和加粗边界，另保留选中语义 |
| 禁用控件 | 次级表面与次级文字色，不显示按下遮罩 |
| 危险操作 | 错误语义文字及边界，禁用时回到次级文字色 |
| 键盘焦点 | 非禁用控件显示 2px 主题描边 |

定向颜色测试对默认、按下、选中、焦点、禁用及组合状态逐项计算对比度。普通文字最低值为浅色 5.344:1、深色 5.737:1，控件边界最低值为浅色 4.841:1、深色 4.308:1，均达到本版合同的文字 4.5:1 和边界 3:1 要求。主题与 Lifestyle 联合13项定向测试通过，其中4项颜色计算、9项Lifestyle Widget，覆盖深浅主题、1 倍及 2 倍字体和键盘选择。

证据位于 `apps/flutter_elitesync_module/test/component_color_states_test.dart` 与 `apps/flutter_elitesync_module/test/features/lifestyle_discovery/lifestyle_page_test.dart`。上述数据来自 Widget 测试和颜色计算，不代表系统级辅助功能验收。

最终1011804模拟器已观察深色选中态、正常字体与Android系统2倍字体。系统字体设置已恢复。浅色和深色的1倍/2倍字体、键盘焦点、语义与减少动态效果另由定向Widget覆盖。系统级TalkBack为NOT_RUN。
