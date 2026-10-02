# APP-M5-28｜Work独立审查

2026-09-30；LEVEL2 REJECT AS IMPLEMENTABLE CONTRACT / CLOSED AUTHOR BUDGET。保留候选，不修改或删除旧证据。

最终plan SHA256 57A2A856780B687E4E582E1DFAC1C71FBE3069D80C51726BEDF66028F2D254FC匹配。Work已读task/完整plan及原回执；独立Sol/high只读助手识别四项Required，Work核相应文本后确认：
1. plan:40宣称tasks-full/init-full实际插入并保留原bytes，:380却仅返回边界替换段和callback首锚拼接，未定义完整转换结果或结构化修订操作。后继必须选定并完整定义一个输出域。
2. plan:36/38允许任意64hex input_id，:361及:380把64a调用文本作为固定输出，与动态InvocationContract/properties不一致。固定64a只能是P1预期。
3. P1 properties:373-376的output-dir='publication'与helper:100/init:232的root projectDir派生路径不一致，缺少逻辑token到安装值的明确映射。当前properties不能直接作为runtime安装表。
4. helper:87与init:208-210把已存在但值null的mode当未设置，违反:82“只有完全未设置才回落”。需先判存在，再验证作用域/非null准确值。
以上均为已提出合同的内部文本逻辑问题，不能由编译/运行UNKNOWN豁免。

同次exec-ea41f742-ebd4-4b77-8ab2-82c7f4c997a8/chunkfe1687：exit0、stdout26047B，七证据121468B、预期hash匹配，第一轮1/1。exec-6b326027-911d-4cfd-9b67-ac8f4bebd3fe/chunk4c697f：exit0、stdout1924B，附回执前plan31318B/hash E887EFB5684B428D3BD127004EC784317864CD5436187C80E0DE4E5B17AF197B，最终33736B/hash如上，一次文本检查PASS、第二轮1/1。Work从同次rollout恢复两原回执，read_thread展示截断不重跑；2/2关闭。作者静态PASS不证明合同逻辑正确。

main HEAD cf8bfaa4a03b8c9a682105617b185141904413be，178条状态保留；最新Codex19次启动idle/error=null，可沿用。没有源码/SDK/运行/真实数据动作。本轮下达M5-29仅修四Required，唯一新plan、新两轮预算；原M5-28与全部更早预算关闭，未授权实现或重跑。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与真实账号/Conversation/恢复/UAC门保持。最终裁决归Work。