# EliteSync V2｜P1 脱敏证据索引

逐条 SHA-256 对应本机脱敏回执。控制面原图、真实 IP、证书密钥、账户及临时配置保存在私有证据目录。

| 回执 | SHA-256 | 证明范围 |
| --- | --- | --- |
| `01-ip-readonly.json` | `5509726098aa49470ed70bc48c06579b6609e1edd46d164386328eecae47a03b` | 公网身份、监听、时间同步、系统 Certbot 和只读基线 |
| `01b-acme-client.json` | `7ef80aaf5ecd34ee6125bf9b40538fc67f456cc753e4824170fd746c9490adc6` | 隔离 Certbot 5.4.0，系统包状态保持 |
| `01d-console-firewall-verified.json` | `e7768b1f6bc42bec6c70b944221e18cdebac57273bf7e41cff70cbdc71e8971e` | 上一轮控制面 443 与 22 规则脱敏回执 |
| `05-acme-staging.json` | `15239e2c28a3235dfa436b27ee396963f2274421eaaf5ec12e8f04a77f5ddad5` | 首次 token 路由预检 STOP 与回滚 |
| `05b-acme-diagnose.json` | `0ed43b401e383cccd2a5b4c91c471620bda56b0020d5d91ec453fb67e695a7dc` | 首次预检实际返回 410 |
| `05c-acme-staging.json` | `2af265c2979b5b5f5eb91c0e6acb645716143ff1d34c4bcc120c3f4ed1951836` | 官方 staging IP SAN、链、有效期、密钥通过，续期初次超时及回滚 |
| `05e-renew-delay.json` | `7b40246177a12233b4987d3f7d5b7eac2bafc27156a3733abe32fa3da592d61b` | 初次续期随机等待超过演练上限 |
| `05g-acme-renew.json` | `f10edf53981a4d6b2f8200e46faa8f0ac9bf0d96731c8aabce078a00a7c5c60f` | staging dry-run、测试 hook 和原配置恢复通过 |
| `06b-post-cloud-ports.json` | `2771ea42d7783809790a1890c3a3fd7420a47a7867b01ec5e5752edbed6b0006` | 最终 80 SHA、旧路由、云健康、回环端口和 Workerman |
| `07b-final-ip-edge-matrix.json` | `cea0ebce37333a8b9965a33ad5b370c17c1eab41b87f46ba076029c4c993932e` | 隔离 Nginx 和 deploy hook 40 项，含失败回滚 |
| `04f-named-profile-and-transport.log` | `e54acc0f87913a99f1eb3089eebdb5cae118f3993a489570bb53e6c637d8836b` | Flutter 资料、编辑与端点定向 27 PASS |
| `15-native-ip-negatives.json` | `370cc3a0aab738a02d00ec193f6ea72a4e0cb5ea4d98ff0dac3ac845e62cad3a` | Gradle 共享地址与混合模式两项拒绝 |
| `14-ip-apk-identity.json` | `bbf8d2b9695f86c06d1e4698564832a1617a0d1766303ba0aeba867dce1bb656` | 最终 APK、AAR、AOT、签名与双端点脱敏回执 |

正式证书、真实来源、443 启用、Chrome、实体手机远程 APP、真实 WLAN 和双物理设备验收均待后续具名回执。
