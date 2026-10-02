# AUTH-152｜一次受限 SSH 公钥候选观察（Phase A 静态候选）

**作者交付：`CANDIDATE_PREPARED`，仅供 Work LEVEL 3 独立审查；不是现场 GO。** 起点为 `D:\EliteSync-v10`、本地 `main` HEAD `df9fdf22892323a3d6df68b0ec9f0b89bc04164b`。本任务唯一写入是本文件；两个既有无关未跟踪目录保留。命令助手现场预算仍 `0/1`，本文命令从未运行。

## 命令助手的固定设置与信任含义

仅在 Owner 指定的**当前阿里云上海唯一轻量实例**的已认证命令助手中，由 Work 在临运行门复核选中实例后，选 **Shell**、显式执行用户 **`root`**、平台超时 **10 秒**，最多调用一次。Owner 已接受 root 只读检查、系统自带工具无需逐字节预验，以及无秘密脚本与受限结果可能留存在阿里云；阿里云可见者和留存期限未知。控制台出现登录、密码、真人识别、权限提示或 Windows UAC 时，触发前停下，遵守当前 Work 会话的 Owner 到场与具体授权门。不得换实例、改命令、补跑或重试。

这条命令**不查配置或监听端口**；任务允许省略监听。它仅浅层查看固定 `/etc/ssh` 目录中名称形如 `ssh_host_*_key.pub` 的文件，至多四个。第五个匹配名称立即失败，绝不取前四个当成功。只打开后缀 `.pub`、非符号链接的普通文件；内核 `O_NOFOLLOW` 与打开后 `fstat` 防止检查和打开之间换成符号链接、设备或管道。每文件上限 8192 bytes、只接受一行 ASCII OpenSSH 公钥、限定算法，计算公钥二进制 blob 的 SHA-256 指纹；不输出公钥行、注释、路径、配置或任何原始错误。没有任何 `.pub`、类型异常、内容不合规、权限失败或超时都失败。不会打开不以 `.pub` 结尾的 host-key、客户端 PEM、`.env`、DB 或备份路径，也不会调用 `sshd -t/-T` 或 `ssh-keyscan`。

**完整 Shell 候选（仅静态文本，不在本任务执行）：**

```sh
exec 2>/dev/null
python3 -I -S - <<'PY'
import base64
import binascii
import hashlib
import os
import re
import signal
import stat
import sys

DIRECTORY = '/etc/ssh'
NAME = re.compile(r'ssh_host_[a-z0-9_]+_key\.pub\Z', re.ASCII)
ALGORITHMS = {
    'ssh-rsa', 'ssh-ed25519',
    'ecdsa-sha2-nistp256', 'ecdsa-sha2-nistp384', 'ecdsa-sha2-nistp521',
}

class ProbeFailure(Exception):
    pass

def fail(code):
    raise ProbeFailure(code)

def on_alarm(_signum, _frame):
    fail('TIMEOUT')

def public_record(name):
    path = DIRECTORY + '/' + name
    flags = os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK
    fd = os.open(path, flags)
    try:
        meta = os.fstat(fd)
        if not stat.S_ISREG(meta.st_mode) or meta.st_size < 16 or meta.st_size > 8192:
            fail('FILE_TYPE_OR_SIZE')
        raw = os.read(fd, 8193)
        if len(raw) > 8192 or len(raw) != meta.st_size:
            fail('FILE_CHANGED_OR_OVERSIZE')
    finally:
        os.close(fd)
    if not raw.endswith(b'\n') or raw.count(b'\n') != 1 or b'\r' in raw:
        fail('PUBLIC_FORMAT')
    try:
        line = raw[:-1].decode('ascii')
    except UnicodeDecodeError:
        fail('PUBLIC_FORMAT')
    fields = line.split(' ', 2)
    if len(fields) < 2 or not fields[0] or not fields[1]:
        fail('PUBLIC_FORMAT')
    algorithm, encoded = fields[:2]
    if algorithm not in ALGORITHMS or not re.fullmatch(r'[A-Za-z0-9+/]+={0,2}', encoded):
        fail('PUBLIC_FORMAT')
    if len(fields) == 3 and (not fields[2] or any(ord(c) < 32 or ord(c) > 126 for c in fields[2])):
        fail('PUBLIC_FORMAT')
    try:
        blob = base64.b64decode(encoded, validate=True)
    except binascii.Error:
        fail('PUBLIC_FORMAT')
    if base64.b64encode(blob).decode('ascii') != encoded or len(blob) < 5:
        fail('PUBLIC_FORMAT')
    length = int.from_bytes(blob[:4], 'big')
    if length < 1 or length > 64 or 4 + length > len(blob):
        fail('PUBLIC_FORMAT')
    try:
        inner = blob[4:4 + length].decode('ascii')
    except UnicodeDecodeError:
        fail('PUBLIC_FORMAT')
    if inner != algorithm:
        fail('PUBLIC_FORMAT')
    fingerprint = base64.b64encode(hashlib.sha256(blob).digest()).decode('ascii').rstrip('=')
    return algorithm, fingerprint

def run():
    signal.signal(signal.SIGALRM, on_alarm)
    signal.alarm(8)
    names = []
    with os.scandir(DIRECTORY) as entries:
        for entry in entries:
            if NAME.fullmatch(entry.name):
                names.append(entry.name)
                if len(names) > 4:
                    fail('MORE_THAN_FOUR')
    if not names:
        fail('NO_PUBLIC_CANDIDATE')
    records = []
    for name in sorted(names):
        records.append(public_record(name))
    if len(set(records)) != len(records):
        fail('DUPLICATE_CANDIDATE')
    signal.alarm(0)
    # Single write, after every candidate passed. No partial success during enumeration.
    body = 'AUTH152=PUBLIC_CANDIDATES;COUNT=' + str(len(records))
    for algorithm, fingerprint in records:
        body += ';ALG=' + algorithm + ',SHA256=' + fingerprint
    body += ';END=AUTH152\n'
    payload = body.encode('ascii')
    if len(payload) > 512 or os.write(1, payload) != len(payload):
        fail('OUTPUT_FAILURE')

try:
    run()
except ProbeFailure as error:
    os.write(1, ('AUTH152=FAIL;CLASS=' + str(error) + '\n').encode('ascii'))
    sys.exit(1)
except Exception:
    os.write(1, b'AUTH152=FAIL;CLASS=SYSTEM\n')
    sys.exit(1)
PY
```

Python `os.scandir` 只在 `/etc/ssh` 做单层名称观察；`os.open(..., O_NOFOLLOW)`、`fstat` 与限长读取只作用于已匹配 `.pub` 文件。`hashlib.sha256` 作用于严格 Base64 解码的公钥 blob，算法同时核对公钥文本首字段与 blob 首个 SSH string。这里没有使用 `ssh-keygen -l`：OpenSSH 官方 [`ssh-keygen(1)`](https://man.openbsd.org/ssh-keygen.1)说明它可显示指定公钥文件的指纹，但本候选需要在同一受限进程中实现无链接打开、字节上限、双流抑制和成功前不输出。Python 标准库调用语义可按官方 [`os.open`/`os.scandir`](https://docs.python.org/3/library/os.html)、[`hashlib`](https://docs.python.org/3/library/hashlib.html)核对；这些只证明一般工具语义，不证明目标实例已有 Python 3 或 `/etc/ssh` 的现状。若 `python3`、`O_NOFOLLOW`、POSIX `SIGALRM` 不可用，命令非零或无完整结果，失败即停。

**输入内容边界：** `.pub` 后缀、无符号链接、普通文件及严格公钥格式防止把常规私钥路径当输入，也防止把非公钥内容投影出去；但任何程序都必须先读 `.pub` 的有限字节才能判断它是否被误放入私钥内容。若 Work 把“绝不读私钥”解释为即使管理员将私钥内容复制到 `.pub` 路径也绝不能读一个字节，那么该目标在未知文件内容前无法技术保证，本候选必须判 `NOT_FIXED/NO-GO`，不能执行。当前候选的明确保证是**绝不打开私钥命名路径或链接目标**，且任何非公钥字节不输出、失败即停；这一剩余假设须由 Work LEVEL 3 明确裁决，不能隐去。

## 输出、异常与后继比较

成功时仅一行 `AUTH152=PUBLIC_CANDIDATES;COUNT=1..4;ALG=...,SHA256=...;END=AUTH152`，最多 512 bytes；无成功前部分结果。失败仅固定 `AUTH152=FAIL;CLASS=...` 或非零且无完整帧。解释器及外部错误标准错误从 Shell 起即导向 `/dev/null`；Python 不调用子进程，正常路径无其他标准输出。平台须对**stdout 和 stderr 各自**设置不超过 512 bytes 的显示/采集上限，整条命令 10 秒超时；如命令助手做不到双流上限、会附加无法区分的原文、缺 `END`、输出被截断/多行/额外字节、非零退出、平台超时或结果页不明，均不得接受结果。进程内 `SIGALRM` 为 8 秒；平台 10 秒是外层硬停。平台自身异常包装可能不受脚本控制，只能把异常结果视为失败，**不复制或保存原文**，预算 1/1 耗尽。若命令助手不能安全限定其异常输出，现场前 `NO-GO`。

指纹与算法原值仅留在已认证、受保护的阿里云会话，供后续经独立任务固定到受保护比较通道；不得进入聊天、Git、普通证据、截图或非受保护剪贴板。普通证据只能记时点、实例复核状态、`COUNT`、有限错误类别、退出状态、预算和 `HOST_KEY_MATCH=UNKNOWN`，不能记公网地址、端口、路径、算法/指纹原值或原始页面。阿里云脚本/结果可能长期留存，可见者与期限未知；Owner 已接受这个限定风险。候选算法/指纹只是**该实例自报的公钥文件**，不证明运行中 sshd 当前提供它。`HOST_KEY_MATCH=YES` 只有在后续单独授权的首次严格 SSH 中，客户端在发送任何认证材料前把握手所见 key 与预固定算法、SHA-256 指纹、Owner 指定目标地址和端口逐项精确匹配后才可能成立；失配或连接失败立即停。不得使用 `ssh-keyscan`、旧 `known_hosts`、自动接受新 key 或跳过校验。Owner 提供的公网地址与端口 22 仅是待核候选；本命令不验证监听，云侧规则与主机防火墙亦仍 `UNKNOWN`，不能从实例内部文件推断外部可达。

本轮不运行候选、不访问控制台/API/SSH/DB、密钥或备份，不触发 UAC，不提交、pull、push，也不访问旧 `D:\EliteSync`。仅交本地静态候选和最多两轮不执行候选的检查；Work LEVEL 3 独立审查后才可能决定现场预算，作者不自接受或派发后继。

## Work LEVEL 3 Phase A 独立审查

**ACCEPT 仅上述静态命令候选；现场提交仍 PENDING 表单与当前目标临运行核对。** Work 独立核对作者原始 SHA-256 `B9C04150B55BBB8748E5CDCA8714791F8DBA7F7EFDC0375AEB257710215699C2`、固定目录和文件名、`O_NOFOLLOW`/普通文件/8192 bytes 上限、四个候选上限、失败前无成功输出、双流和超时；作者两轮静态检查，不是现场执行证明。脚本不打开无 `.pub` 后缀的 host-key 路径，也不调用 `sshd -t/-T`、DB 或客户端密钥。正常 `.pub` 文件若被恶意误装私钥内容，任何格式检查都必须先读有限字节才能拒绝；本审查将“不得读私钥”落实为不得打开私钥命名路径、不得跟随链接、不得输出不合规内容，同时保留该异常情形的残余风险，不宣称绝对排除被攻陷实例的恶意伪装。

平台若不提供双流 512 bytes 的硬上限，不能把平台包装输出当成功；脚本本身将正常 stdout 限为 512 bytes、stderr 自始抑制。任何非零、缺失完整 `END`、额外字节、超时或平台异常均失败即停，不复制原文，不二次提交。此前浏览器自动点击旧详情关闭按钮未产生可见变化；为避免误点，已请 Owner 手动关闭并打开同一实例的执行表单，**不得在表单复核和脚本精确比对前点击确定**。命令助手预算仍 0/1，SSH/DB/备份均未运行。

## Work LEVEL 3 Phase B 临运行裁决

Owner 手动关闭旧详情并打开表单。Work 只读复核：页面为 Owner 指定的上海轻量实例，公网地址与 Owner 提供值一致；命令类型 Shell、输入命令内容、执行用户 `root`、超时 10 秒；执行列表仍只有 AUTH-148/140 两条旧记录。Work 填写 `AUTH-152-public-hostkey-candidates` 与静态候选脚本，按编辑器全选复制的可见内容核对：CRLF 规范化为 LF 后与本文件代码块逐字一致，UTF-8 SHA-256 同为 `392D1A1521B30E1787F157596CAD8A74786AAAFDAF2DB7DE4468A6A2EADDECE0`。没有点击确定或触发服务器执行。

**LEVEL 3 GO，仅 Owner 本人可在当前表单单击“确定”一次。** 单击动作即消耗本任务唯一 1/1 命令助手执行预算；无可见变化也不得重试。若表单目标/内容改变、出现密码、真人识别、UAC、权限提示或其他异常，点击前停。执行后先看是否出现唯一新记录，再另审详情读取；GO 不授权 SSH、DB 或备份。

## Owner 提交与列表回执

Owner 报告已在 GO 后手动点击确定一次，AUTH-152 执行预算 **1/1 耗尽**，不重试。Work 只读观察同一上海实例命令助手列表：新出现唯一 `AUTH-152-public-hostkey-candidates` 记录，控制面状态“执行完成”，列表共三条，另两条为旧 AUTH-148/140。列表状态不证明 Shell 退出码 0 或候选内容有效；尚未打开新详情，公钥指纹、算法与 SSH 端口仍 `UNKNOWN`。本任务至此仅接受提交/新记录事实，详情读取另立单次任务。
