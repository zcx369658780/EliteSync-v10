# APP-M5-08｜模拟器只读预检候选回执

状态：READONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。M5运行仍NOT_READY。

仓库 D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。固定adb.exe存在并只读哈希：7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606。未搜索替代工具。

## 脱敏事实

```json
{
  "emulators": [
    {
      "serial": "emulator-5554",
      "state": "device"
    }
  ],
  "ignored_physical_count": 0,
  "qemu": "1",
  "sdk": 36,
  "com.elitesync.syntheticdemo": "UNKNOWN"
}
```

停点：com.elitesync.syntheticdemo: COMMAND_FAILED_TIMEOUT_TRUNCATION_OR_STARTUP。

## 逐命令回执与预算

```json
[
  {
    "step": "devices",
    "command": [
      "C:\\Users\\zcxve\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe",
      "-H",
      "localhost",
      "-P",
      "5037",
      "devices"
    ],
    "start": "2026-09-30T00:37:33.916108+00:00",
    "exit": 0,
    "timeout": false,
    "startup_failed": false,
    "elapsed": 0.047,
    "end": "2026-09-30T00:37:33.953431+00:00",
    "streams": {
      "stderr": {
        "bytes": 0,
        "truncated": false
      },
      "stdout": {
        "bytes": 50,
        "truncated": false
      }
    }
  },
  {
    "step": "qemu",
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
    "start": "2026-09-30T00:37:33.955001+00:00",
    "exit": 0,
    "timeout": false,
    "startup_failed": false,
    "elapsed": 0.047,
    "end": "2026-09-30T00:37:34.008950+00:00",
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
    "step": "sdk",
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
      "ro.build.version.sdk"
    ],
    "start": "2026-09-30T00:37:34.008950+00:00",
    "exit": 0,
    "timeout": false,
    "startup_failed": false,
    "elapsed": 0.047,
    "end": "2026-09-30T00:37:34.051884+00:00",
    "streams": {
      "stderr": {
        "bytes": 0,
        "truncated": false
      },
      "stdout": {
        "bytes": 4,
        "truncated": false
      }
    }
  },
  {
    "step": "com.elitesync.syntheticdemo",
    "command": [
      "C:\\Users\\zcxve\\AppData\\Local\\Android\\Sdk\\platform-tools\\adb.exe",
      "-H",
      "localhost",
      "-P",
      "5037",
      "-s",
      "emulator-5554",
      "shell",
      "pm",
      "path",
      "com.elitesync.syntheticdemo"
    ],
    "start": "2026-09-30T00:37:34.051884+00:00",
    "exit": 1,
    "timeout": false,
    "startup_failed": false,
    "elapsed": 0.062,
    "end": "2026-09-30T00:37:34.110345+00:00",
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

每个已启动命令新预算1/1消耗，未执行命令0/1、NOT_CHECKED；无重跑。所有命令显式-H localhost -P 5037；设备命令绑定唯一online emulator serial。各20秒硬时限、双流并行排空，每路仅捕获前16384字节；超时只终止本地子进程。原始stdout/stderr只在内存解析，不进入证据；物理项只保留忽略数量，包路径只保留状态/条数，不保存物理serial、包路径或用户文件。

## 工作区与限制

摘要写入前git非忽略状态条目156→156，逐条一致=True；本摘要为唯一新增交付，无源码/配置/authority或其它证据修改。未执行install/uninstall/clear/launch/am start、截图/logcat、pull/push/reverse/forward、Gradle/Flutter构建、真实网络/数据、旧仓库、properties、备份/密钥/DB/SSH/API/UAC或物理设备操作；未提交Git或自接受/创建后继。

包占用查询不授予拟议syntheticdemo包产物身份，未装也不证明安装启动安全。本预检不建立APK、host/AAR、入口、应用数据隔离、Android生命周期或真实账号/Conversation权限证明。M5仍NOT_READY，所有真实数据/恢复门和旧预算不变。
