# APP-M5-12｜Activity深链开关位置修复候选

状态：SOURCE-ONLY CANDIDATE / WORK LEVEL2 REVIEW PENDING。D:\EliteSync-v10 main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。
仅修改独立host manifest，唯一新增本摘要；其它八源码、旧摘要/validator/authority未改。

官方两准确来源批量读取/哈希1/1耗尽：
- D:/flutter/engine/src/flutter/shell/platform/android/io/flutter/embedding/android/FlutterActivity.java：24E8078A2FB65090F1A91E564121BBCD69373CD8383888F2212E700ACC2027D9。getMetaData第1313–1316行以getComponentName/GET_META_DATA读取ActivityInfo.metaData；shouldHandleDeeplinking第1423–1426行将该元数据传给deepLinkEnabled。onNewIntent第931行起转发delegate。默认getInitialRoute第1189–1201行支持Intent，独立hostoverride固定/home保留。
- 同目录FlutterActivityAndFragmentDelegate.java：4E8821C478B07FEF244A02141524D563907D4BAA409B9BF151CB61862746F46A。第250–259、485–490行优先host.getInitialRoute，null才从Intent取route；第522–529行helper先检查host.shouldHandleDeeplinking再读Intent.getData；第941–951行新Intent先转发插件，再通过helper非空route才pushRouteInformation。Activity开关关闭这条基类navigation推送路径，不证明所有插件Intent处理被禁止。
本地官方源不是未来AAR版本证明，无扩搜/SDK改动。

MainActivity只读输入hash匹配7C84B23C554FAD528126151E00AB1B63B9E179A2DFCDDD5A13AA4AC9A203176F，未编辑Kotlin。
manifest输入hash：CAE490260B4CD9AE8740F810BD6EA0C553F9F5D2DEF5E7567C233035FEA9F69A；输出hash：A7433272D1CAD6D9ACE5445F7EF3D3C56FF3C79F4B0B618B15EC183D7A6EF432。
仅把唯一flutter_deeplinking_enabled=false从application直属移入.MainActivity直属，按Activity层级缩进该行；原行尾及其它字节保持。最初编辑前匹配断言因Windows CRLF而停止，未写入、未启动验证；只读确认输入未变/摘要不存在后按原行尾匹配，实际仅写入1次。这不是XML验证失败或重跑。

新预算：单次Python -I -B XML进程1/1，30秒硬时限/双流并行排空各16384字节上限。核对唯一Activity/唯一开关false/application无开关、除开关移动外XML语义相同、准确字节移动。实际回执：
```json
{
  "command": "C:\\Users\\zcxve\\AppData\\Local\\Programs\\Python\\Python311\\python.exe -I -B -c <inline XML check>",
  "start": "2026-09-30T02:05:59.513599+00:00",
  "end": "2026-09-30T02:05:59.592859+00:00",
  "elapsed": 0.079,
  "exit": 0,
  "timeout": false,
  "streams": {
    "stderr": {
      "bytes": 0,
      "truncated": false,
      "text": ""
    },
    "stdout": {
      "bytes": 219,
      "truncated": false,
      "text": "{\"xml\": \"PASS\", \"uniqueActivityFlag\": \"PASS\", \"applicationNoFlag\": \"PASS\", \"otherXmlSemantics\": \"UNCHANGED\", \"exactByteMove\": \"PASS\", \"outputSha256\": \"A7433272D1CAD6D9ACE5445F7EF3D3C56FF3C79F4B0B618B15EC183D7A6EF432\"}\r\n"
    }
  }
}
```
目标仅此文件空白检查1/1：PASS，未用git diff空输出替代。无修复复跑或旧validator验证。

M5-11 REJECT、39/39旧PASS和耗尽预算原样保留；本候选仅源码接线修复。merged manifest、Android生命周期/新Intent运行、host编译/AAR版本仍NOT_CHECKED，M5 NOT_READY，构建settings仍拒绝。真实账号/Conversation/G08/G11/恢复门及全部旧预算不变。
所有任务外既有内容保留。无Gradle/Flutter/Android/设备、网络/UAC、目录扫描/索引、真实properties/缓存/凭据/备份/密钥/DB/SSH/API或旧仓库访问，未提交/pull/push、自接受、改authority或派发后继。停独立Work LEVEL2审查。
