# APP-M5-09｜当前模拟器用户准确包占用候选

状态：READONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。

仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。固定adb.exe SHA-256匹配：7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606。

## 脱敏事实

```json
{
  "serial": "emulator-5554",
  "package": "com.elitesync.syntheticdemo",
  "occupancy": "NOT_INSTALLED_FOR_CURRENT_USER",
  "qemu": "1",
  "current_user": 0,
  "nonexact_match_count": 0,
  "exact_match_count": 0
}
```

停点：三条授权只读查询完成；等待Work独立审查。

## 实际逐命令回执

```json
[
  {
    "step": 1,
    "command": [
      "C:\\Users\\zcxve\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe",
      "-H",
      "localhost",
      "-P",
      "5037",
      "-s",
      "emulator-5554",
      "shell",
      "getprop",
      "ro.kernel.qemu"
    ],
    "start": "2026-09-30T00:40:37.128116+00:00",
    "exit": 0,
    "startup_failed": false,
    "timeout": false,
    "end": "2026-09-30T00:40:37.174856+00:00",
    "elapsed": 0.047,
    "streams": {
      "stdout": {
        "bytes": 3,
        "truncated": false
      },
      "stderr": {
        "bytes": 0,
        "truncated": false
      }
    }
  },
  {
    "step": 2,
    "command": [
      "C:\\Users\\zcxve\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe",
      "-H",
      "localhost",
      "-P",
      "5037",
      "-s",
      "emulator-5554",
      "shell",
      "am",
      "get-current-user"
    ],
    "start": "2026-09-30T00:40:37.175861+00:00",
    "exit": 0,
    "startup_failed": false,
    "timeout": false,
    "end": "2026-09-30T00:40:37.228074+00:00",
    "elapsed": 0.047,
    "streams": {
      "stderr": {
        "bytes": 0,
        "truncated": false
      },
      "stdout": {
        "bytes": 3,
        "truncated": false
      }
    }
  },
  {
    "step": 3,
    "command": [
      "C:\\Users\\zcxve\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe",
      "-H",
      "localhost",
      "-P",
      "5037",
      "-s",
      "emulator-5554",
      "shell",
      "cmd",
      "package",
      "list",
      "packages",
      "--user",
      "0",
      "com.elitesync.syntheticdemo"
    ],
    "start": "2026-09-30T00:40:37.228074+00:00",
    "exit": 0,
    "startup_failed": false,
    "timeout": false,
    "end": "2026-09-30T00:40:37.285088+00:00",
    "elapsed": 0.062,
    "streams": {
      "stdout": {
        "bytes": 0,
        "truncated": false
      },
      "stderr": {
        "bytes": 0,
        "truncated": false
      }
    }
  }
]
```

三步各新预算最多1/1；已启动命令各消耗1/1，后续未启动命令0/1且NOT_CHECKED，不复跑。20秒硬时限、stdout/stderr各16384字节限额并行排空；非0/超时/截断/stderr非空/格式异常立即停。所有命令显式-H localhost -P 5037 -s emulator-5554，U为get-current-user实际值，以参数列表传入，没有shell拼接。未重新枚举设备/用户/全包，未执行旧pm path或旧任务未执行命令。原始额外包名称未输出或落盘。

仅建立该模拟器当前用户此时占用事实，不证明其它用户、其它设备或未来安装安全；com.elitesync.syntheticdemo仍为拟议ID，并非已接受产物身份。M5-08非0包回执保持UNKNOWN，旧预算及旧证据不追改。

摘要写入前git非忽略状态157→157，逐条一致=True；本摘要唯一新增交付，保留所有dirty/untracked。无源码/authority/其它证据修改，无安装/卸载/clear/启动/截图/logcat/pull/push/reverse/forward、Gradle/Flutter、properties/凭据、网络API/生产DB/真实备份/密钥/SSH/旧仓库/UAC/物理设备访问。未自接受、派发后继或提交Git。M5仍NOT_READY；产物/入口/AAR身份/数据隔离和真实数据/Conversation/恢复门未解除。
