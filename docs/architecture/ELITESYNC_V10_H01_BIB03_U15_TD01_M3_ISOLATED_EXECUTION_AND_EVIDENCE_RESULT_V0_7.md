# EliteSync v10｜M3-ISO-V02-007 参数绑定修复、隔离准备与新鲜证据结果 v0.7

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — NO M2 AUTHORITY`

最终分类：**M3 PRECONDITION BLOCKED — NATIVE TOOL VERIFY ARGUMENT DISPATCH FAILURE**。

Attempt=`M3-ISO-V02-007`；日期2026-09-09（Asia/Shanghai）。Owner在Codex界面选择GPT-5.6 Sol、Medium，并在本会话直接批准v0.7 §1范围。未修改模型配置或调用辅助代理；未把006授权当作本轮自动续期。

## 1. 固定身份、输入和批准

实时main A=`24e51edbe81317b9c1ae5351bd580cbfc2274959`；FIRST交接blob=`18485c95262051e43892436fb52413132c5ee626`。任务分支指向T=`e81128e9e309c40ac7f37378ecbd509035df3afd`，任务blob=`cf7b9f29cc0b0ed81a764239fdf17a34eeb86e33`；T唯一父A，且相对A只新增任务单。local HEAD `d1b45cc5da30bba3f377ef4ead2c677d0fb6eb88`仅作上下文。

007工作区为`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-007`。四份006来源开始与结束SHA-256均匹配任务，未执行改旧文件；固定Git对象模块机械物化526个文件，1个README类路径按过滤合同排除。`flutterDartDefines`三个允许来源均未提供该键，结论`EMPTY`，追加参数数0。

首次物化器把tar父目录项`apps`误判为越界；该轮写入模块文件0。保留错误后只修正自有过滤守卫，复用同一archive并以`xb`写入成功。这不是源码或权限拒绝。

## 2. 真实修复、脚本绑定与三轮host测试

006的`RunBatch`把参数形参命名为PowerShell自动变量`args`，cases又依赖位置嵌套数组。007改为`ArgumentList`，所有生产/测试调用使用具名splatting；bindings/cases使用具名字段，参数强制`System.String[]`。首个自测进程前的纯内存检查确认6个对象、pub 3项、M3 5项、空格define 1项、EMPTY defines 0项；四脚本通过Windows PowerShell 5.1 AST，未发现把args/Host/PID/input声明或赋值为业务变量。

| 轮次 | 实际结果 | 保存的具体原因与纠正 |
| --- | --- | --- |
| 1 | 1/6；仅missing负例通过 | 调用者数组与函数接收数组已经一致；存在目标使用正斜杠交给cmd，CP936错误为文件名/目录名/卷标语法不正确。只在共享RunBatch规范化BatchPath。 |
| 2 | 1/6；仅missing负例通过 | BatchPath已为反斜杠，错误仍在；实际记录显示ProcessStartInfo的可执行路径/工作目录仍未统一规范化。只在RunNative规范化ExecutablePath和WorkingDirectory并记录actual executable。 |
| 3 | 6/6 PASS；进程exit 0 | 同一dispatch边界取得ENTERED、参数、cwd、stderr、分类和原生exit全部通过；exit37原样返回。 |

三轮专用host PowerShell的Process/effective均为`RemoteSigned`；每轮均在180秒内结束。最终脚本SHA-256：

| 文件 | SHA-256 |
| --- | --- |
| copy.ps1 | `C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC` |
| dispatch.ps1 | `8AE2F95549921F5DF6A7249F9E8549462506883AB620603A61846F1E5A1D2A29` |
| host-selftest.ps1 | `C1F575B07F3927FA93D5C72BD2CE667B1CB4ECFC15604D311B0F215CB1BFDEC0` |
| guest.ps1 | `6A4A8C5750AC5BD952524834DFAC9A16C848963BDC28B7B4E25DEA6DEEE8ACCC` |

最终六组：

| case | 调用参数数 | ENTERED | exit | 参数 | cwd | stderr | 结论 |
| --- | ---: | --- | ---: | --- | --- | --- | --- |
| pub | 3 | True | 0 | True | True | True | PASS |
| m3shape | 5 | True | 0 | True | True | True | PASS |
| spaces | 3 | True | 0 | True | True | True | PASS |
| define | 1 | True | 0 | True | True | True | PASS |
| exit37 | 1 | True | 37 | True | True | True | PASS |
| missing | 3 | False | 1 | True | True | True | PASS |

## 3. 实际冻结的共享派发实现

以下为hash `8AE2F95549921F5DF6A7249F9E8549462506883AB620603A61846F1E5A1D2A29`对应的完整实际文件；host测试和guest部署加载同一字节。它保留CMD-001的Assert-CmdAtom、Quote-CmdAtom和New-BatchArguments构造。后述直接RunNative缺陷也原样保留，不能把本段当作已获准继续执行的修复版本。

```powershell
function Assert-CmdAtom {
    param([string]$Value, [string]$Role)
    if ($null -eq $Value) { throw "CMD_${Role}_NULL_REJECTED" }
    if ($Value.IndexOf([char]0) -ge 0 -or $Value -match '[\r\n"%&|<>^!()]') {
        throw "CMD_${Role}_UNSUPPORTED_CHAR_REJECTED"
    }
}

function Quote-CmdAtom {
    param([string]$Value, [string]$Role)
    Assert-CmdAtom -Value $Value -Role $Role
    return '"' + $Value + '"'
}

function New-BatchArguments {
    param([string]$BatchPath, [string[]]$ArgumentList)
    Assert-CmdAtom -Value $BatchPath -Role 'TARGET'
    $tokens = New-Object System.Collections.Generic.List[string]
    $tokens.Add((Quote-CmdAtom -Value $BatchPath -Role 'TARGET'))
    foreach ($item in $ArgumentList) {
        $tokens.Add((Quote-CmdAtom -Value ([string]$item) -Role 'ARGUMENT'))
    }
    return '/d /s /v:off /c "' + ($tokens -join ' ') + '"'
}

$script:M3LastNativeRecord = $null
$script:M3LastBatchRecord = $null

function RunNative {
    param(
        [string]$Id,
        [string]$ExecutablePath,
        [string[]]$ArgumentList,
        [DateTime]$Limit,
        [string]$WorkingDirectory,
        [string]$Evidence,
        [string]$SerializedArguments = $null
    )
    $normalizedExecutablePath = [IO.Path]::GetFullPath($ExecutablePath)
    $normalizedWorkingDirectory = [IO.Path]::GetFullPath($WorkingDirectory)
    $info = [ordered]@{
        id = $Id
        received_exe = $ExecutablePath
        exe = $normalizedExecutablePath
        received_argument_count = @($ArgumentList).Count
        received_arguments = @($ArgumentList)
        serialized_argument_override = $SerializedArguments
        arguments_string = $null
        received_cwd = $WorkingDirectory
        cwd = $normalizedWorkingDirectory
        start = [DateTime]::UtcNow.ToString('o')
        process_started = $false
        exit = $null
        pid = $null
        creation = $null
        actual_executable = $null
        timeout = $false
        error = $null
    }
    $recordPath = $Evidence + '/' + $Id + '-process.json'
    Save-Json $recordPath $info
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $normalizedExecutablePath
    $startInfo.WorkingDirectory = $normalizedWorkingDirectory
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    if ($null -ne $SerializedArguments) {
        $startInfo.Arguments = $SerializedArguments
    } else {
        foreach ($argumentItem in $ArgumentList) {
            if ($argumentItem.Contains('"')) { throw 'ARGUMENT_QUOTE_REJECTED' }
        }
        $startInfo.Arguments = ($ArgumentList | ForEach-Object { '"' + $_ + '"' }) -join ' '
    }
    $info.arguments_string = $startInfo.Arguments
    Save-Json $recordPath $info
    $nativeProcess = [Diagnostics.Process]::new()
    $nativeProcess.StartInfo = $startInfo
    try {
        $null = $nativeProcess.Start()
        $info.process_started = $true
        $info.pid = $nativeProcess.Id
        $info.creation = $nativeProcess.StartTime.ToUniversalTime().ToString('o')
        try { $info.actual_executable = $nativeProcess.MainModule.FileName } catch { $info.actual_executable_error = $_.Exception.ToString() }
        Save-Json $recordPath $info
        $stdoutStream = [IO.File]::Open($Evidence + '/' + $Id + '-stdout.bin', [IO.FileMode]::CreateNew)
        $stderrStream = [IO.File]::Open($Evidence + '/' + $Id + '-stderr.bin', [IO.FileMode]::CreateNew)
        try {
            $stdoutCopy = $nativeProcess.StandardOutput.BaseStream.CopyToAsync($stdoutStream)
            $stderrCopy = $nativeProcess.StandardError.BaseStream.CopyToAsync($stderrStream)
            while (!$nativeProcess.WaitForExit(250)) {
                if ([DateTime]::UtcNow -gt $Limit) {
                    $info.timeout = $true
                    try { [M3Job]::StopChildren() } catch { try { $nativeProcess.Kill() } catch {} }
                    break
                }
            }
            $nativeProcess.WaitForExit()
            $null = $stdoutCopy.GetAwaiter().GetResult()
            $null = $stderrCopy.GetAwaiter().GetResult()
        } finally {
            $stdoutStream.Dispose()
            $stderrStream.Dispose()
        }
        $info.exit = $nativeProcess.ExitCode
    } catch {
        $info.error = $_.Exception.ToString()
        $info.hresult = $_.Exception.HResult
    }
    $info.end = [DateTime]::UtcNow.ToString('o')
    Save-Json $recordPath $info
    $script:M3LastNativeRecord = [pscustomobject]$info
    if ($info.timeout) { throw ('TIMEOUT ' + $Id) }
    if (!$info.process_started) { throw ('PROCESS_START_FAILURE ' + $Id + ' ' + $info.error) }
    return [int]$info.exit
}

function RunBatch {
    param(
        [string]$Id,
        [string]$BatchPath,
        [string[]]$ArgumentList,
        [DateTime]$Limit,
        [string]$WorkingDirectory,
        [string]$Evidence,
        [string]$ExpectedNonce = $null
    )
    $receivedBatchPath = $BatchPath
    $normalizedBatchPath = [IO.Path]::GetFullPath($BatchPath)
    $receivedArguments = [string[]]@($ArgumentList)
    $serialized = New-BatchArguments -BatchPath $normalizedBatchPath -ArgumentList $receivedArguments
    $targetExists = [IO.File]::Exists($normalizedBatchPath)
    $nativeCall = @{
        Id = $Id
        ExecutablePath = 'C:/Windows/System32/cmd.exe'
        ArgumentList = [string[]]@()
        Limit = $Limit
        WorkingDirectory = $WorkingDirectory
        Evidence = $Evidence
        SerializedArguments = $serialized
    }
    $nativeExit = RunNative @nativeCall
    $entered = $false
    if ($ExpectedNonce) {
        $stdoutPath = $Evidence + '/' + $Id + '-stdout.bin'
        if ([IO.File]::Exists($stdoutPath)) {
            $stdoutText = [Text.Encoding]::Default.GetString([IO.File]::ReadAllBytes($stdoutPath))
            $entered = $stdoutText -match ('(?m)^ENTERED=' + [regex]::Escape($ExpectedNonce) + '\r?$')
        }
    }
    $classification = if (!$targetExists) {
        'DISPATCH_FAILURE_TARGET_ABSENT'
    } elseif ($ExpectedNonce -and !$entered) {
        'ENTRY_NOT_ESTABLISHED'
    } else {
        'BATCH_DISPATCHED'
    }
    $script:M3LastBatchRecord = [pscustomobject]@{
        id = $Id
        received_target = $receivedBatchPath
        target = $normalizedBatchPath
        target_exists = $targetExists
        received_argument_count = $receivedArguments.Count
        received_arguments = @($receivedArguments)
        arguments_string = $serialized
        cwd = $WorkingDirectory
        process_started = $script:M3LastNativeRecord.process_started
        pid = $script:M3LastNativeRecord.pid
        creation = $script:M3LastNativeRecord.creation
        entered = $entered
        exit = $nativeExit
        classification = $classification
    }
    Save-Json ($Evidence + '/' + $Id + '-batch.json') $script:M3LastBatchRecord
    return $nativeExit
}

function Get-ToolEntry {
    param([string]$Evidence, [string]$Id, [int]$Exit)
    if ($Exit -eq 0) { return 'CONFIRMED_BY_ZERO_WRAPPER_EXIT' }
    $combined = ''
    foreach ($suffix in @('-stdout.bin', '-stderr.bin')) {
        $candidatePath = $Evidence + '/' + $Id + $suffix
        if ([IO.File]::Exists($candidatePath)) {
            $combined += [Text.Encoding]::Default.GetString([IO.File]::ReadAllBytes($candidatePath))
        }
    }
    if ($combined -match '(?i)Resolving dependencies|Got dependencies|Downloading packages|Running Gradle task|Building AAR|Flutter assets|pub get') {
        return 'CONFIRMED_BY_TOOL_OUTPUT'
    }
    return 'NOT_ESTABLISHED'
}

function New-FakeBatch {
    param([string]$Path, [string]$Nonce, [int]$ExitCode)
    $body = "@echo off`r`nsetlocal DisableDelayedExpansion`r`necho ENTERED=$Nonce`r`necho ARG1=[%~1]`r`necho ARG2=[%~2]`r`necho ARG3=[%~3]`r`necho ARG4=[%~4]`r`necho ARG5=[%~5]`r`necho CWD=[%CD%]`r`nexit /b $ExitCode`r`n"
    [IO.File]::WriteAllText($Path, $body, [Text.Encoding]::ASCII)
}
```

实际guest具名调用点：

```powershell
 $gitCall=@{Id='git-version';ExecutablePath='C:/M3/t/g/cmd/git.exe';ArgumentList=[string[]]@('--version');Limit=$deadline;WorkingDirectory='C:/M3';Evidence=$e};$r.git_exit=RunNative @gitCall
 $javaCall=@{Id='java-version';ExecutablePath='C:/M3/t/j/bin/java.exe';ArgumentList=[string[]]@('-version');Limit=$deadline;WorkingDirectory='C:/M3';Evidence=$e};$r.java_exit=RunNative @javaCall
 $pubCall=@{Id='pub';BatchPath='C:/M3/t/f/bin/flutter.bat';ArgumentList=[string[]]@('pub','get','--offline');Limit=[DateTime]::UtcNow.AddMinutes(10);WorkingDirectory=$workingDirectory;Evidence=$e};$r.pub_exit=RunBatch @pubCall
 $m3Call=@{Id='m3';BatchPath='C:/M3/t/f/bin/flutter.bat';ArgumentList=$m3ArgumentList;Limit=[DateTime]::UtcNow.AddMinutes(30);WorkingDirectory=$workingDirectory;Evidence=$e};$r.m3_exit=RunBatch @m3Call
```

## 4. Sandbox、隔离与复制证据

`WindowsSandbox.exe`精确入口存在；只启动1次，launcher PID=34388，创建时间=09/09/2026 00:28:03，exit=0。WSB `Networking=Disable`，Clipboard/AudioInput/VideoInput/Printer/VGpu均Disable；八项输入只读，唯一可写宿主映射是007 evidence。guest nonce匹配，无up adapter、无默认路由，`isolation_verified=true`；guest Process/effective均`RemoteSigned`，加载系统Security manifest和冻结部署副本成功。

guest在复制前用同一RunBatch完成pub形状、M3形状和exit37冒烟，`guest_dispatch_smoke=true`。八项复制均为一次执行、robocopy原生exit 1，且failed/mismatch/extras均0：

| copy_id | exit | copied | bytes | failed | mismatch | extras | 结论 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| module | 1 | 526 | 3233801 | 0 | 0 | 0 | PASS |
| flutter | 1 | 17932 | 3230107924 | 0 | 0 | 0 | PASS |
| android | 1 | 103648 | 9759961961 | 0 | 0 | 0 | PASS |
| java | 1 | 492 | 317293526 | 0 | 0 | 0 | PASS |
| git | 1 | 9311 | 419706698 | 0 | 0 | 0 | PASS |
| pub-seed | 1 | 82432 | 1668056282 | 0 | 0 | 0 | PASS |
| gradle-cache | 1 | 57859 | 8416661749 | 0 | 0 | 0 | PASS |
| wrapper | 1 | 67592 | 1976278523 | 0 | 0 | 0 | PASS |

## 5. 终止阻塞：直接原生参数被空覆盖

复制完成后，guest按冻结调用点验证Git和Java。两次进程都实际启动，但`RunNative`记录的函数接收参数分别是`--version`和`-version`，最终`ProcessStartInfo.Arguments`却均为空字符串：

| 工具 | 函数收到 | 最终OS参数 | exit | 原始输出结论 |
| --- | --- | --- | ---: | --- |
| Git | `--version` | EMPTY | 1 | stdout为git usage；未执行version选项 |
| Java | `-version` | EMPTY | 1 | stderr为java usage；未执行version选项 |

直接原因是实际文件把可选覆盖形参声明为`[string]$SerializedArguments = $null`。PowerShell 5.1将该typed-null绑定为空字符串；`$null -ne $SerializedArguments`因此为真，空覆盖值压过普通`ArgumentList`序列化。这个缺陷不影响总是显式提供batch serialized string的六组RunBatch测试，却阻断Git/Java的直接RunNative分支。

该事实证明的是`NATIVE TOOL VERIFY ARGUMENT DISPATCH FAILURE`，不证明Git/JDK内容缺失、离线依赖不足或Flutter失败。冻结guest不得热改，Sandbox不得重启；真实pub没有派发。

## 6. 阶段、AAR和进程收尾

| 阶段 | 实际状态 |
| --- | --- |
| host 6组集成 | PASS 6/6 |
| Sandbox启动/策略/隔离 | PASS；1次启动；Process/effective RemoteSigned；禁网控制确认 |
| guest派发冒烟 | PASS；pub/M3形状与exit37 |
| 八项复制 | PASS 8/8 |
| Git/Java工具验证 | FAIL；两者exit 1，参数未进入最终OS字符串 |
| 真实`flutter pub get --offline` | NOT_RUN；dispatch_started=false；exit=null；entry=NOT_ESTABLISHED |
| M3 | NOT_RUN；dispatch_started=false；exit=null |
| exact AAR | NOT_CHECKED；probe_count=0 |
| M2 | deferred；无进入条件 |

finalize时Job内只有guest控制器自身PID；无工具子进程残留。Windows Sandbox本次具名launcher在host请求关闭前已exit 0，终态`EXITED_BEFORE_CLOSE`。普通宿主无ExecutionPolicy参数的收尾查询为五scope Undefined、effective Restricted；没有持久策略变化声明。

## 7. 证据限制与剩余精确缺口

本轮已闭合v0.6的RunBatch参数绑定、具名cases和Windows路径规范化，并首次取得同runner host 6/6、guest禁网隔离与八项真实复制证据。仍未取得真实pub、M3、AAR或M2证据。

若Owner以后另行授权，最小代码差异是让RunNative明确区分“未提供serialized override”和“提供非空batch override”，并在Sandbox前增加直接原生参数传递测试；不得把本轮已关闭guest或复制状态当作可复用执行环境。本执行者不创建后继任务、不自我接受、不更新main。

本地证据根：`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-007/evidence`。不上传SDK/cache、模块源码、二进制、敏感配置或完整本地日志。
