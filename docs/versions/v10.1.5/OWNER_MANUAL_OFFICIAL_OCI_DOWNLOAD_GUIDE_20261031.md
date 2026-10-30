# EliteSync v10.1.5｜Owner 手动获取固定 OCI 官方镜像｜2026-10-31

**状态：OWNER_MANUAL_DOWNLOAD_STAGING_GUIDE_ONLY / NOT_DOWNLOADED_BY_ASTRA / NO_CODEX_TASK_DISPATCH / NO_INSTALL / ALL_HASHES_MUST_BE_RECHECKED**

## 1. Owner 交付约定与本地入口

Owner 明确同意：在 `C:\Users\zcxve\Downloads` 下载好官方镜像后，才将下一份 Codex 综合任务启动 Prompt 交给 Codex。此处文件夹是**Owner staging input**，不是任务私有 root、Docker image storage、vendor/cache、生产数据目录或允许 Codex 任意扫描的开放目录。推荐独立子目录：

`C:\Users\zcxve\Downloads\EliteSync-v1015-OCI-20261031`

只允许读取该目录中明确 Manifest 所列镜像元数据和 Layer blob；不得全盘枚举Downloads其它个人文件，不得把下载文件移动/删除、写Global Docker缓存或重用此前已经STOP的任务私有OCI/vendor/DB卷。无文件时任务保持 `AWAITING_OWNER_DOWNLOAD`，没有手动派发。

## 2. 官方入口与固定不可变对象

Docker Hub是OCI Registry。Docker Hub网页不是完整离线 TAR/ZIP 下载链接；真实 OCI 下载要走公开的Registry v2 API，使用临时匿名 Bearer token、固定 Manifest/Layer Digest并处理HTTPS CDN跳转。不要复制短时效token/带签名CDN URL进入仓库。Docker官方文档：https://docs.docker.com/reference/api/registry/latest/ 与 https://docs.docker.com/reference/api/registry/auth/ 。

**PHP 官方镜像：**
- 产品页：https://hub.docker.com/_/php
- 只作为人类核对的tag：`php:8.4.27-cli-bookworm`。真正锁定平台是`linux/amd64`，不能只信任可变tag。
- repository：`library/php`
- OCI index Digest：`sha256:54b467ede1db96c66675e7b78457dd43729d0e7be31978d4a1e5c069ceabcf76`
- **linux/amd64** Manifest Digest：`sha256:dd0e2b902f1edfb6ca02fbcb391c28b1554c7d35a4e36e5925876b90aa804851`
- Config Digest：`sha256:12f6d2ea136f247580f3dc42bda86b27af080fa8f04ea5ec9b581238702093ff`
- 当前锁的官方 userland为 Debian bookworm，不得称Ubuntu24.04本身已运行。

**MariaDB 官方镜像：**
- 产品页：https://hub.docker.com/_/mariadb
- 只作为人类核对的tag：`mariadb:10.11`；具体已运行过的旧合成任务曾验证MariaDB10.11.19，**当前手动文件必须以同一个固定manifest/实际镜像内部版本重新核查，不能仅凭tag声明patch**。
- repository：`library/mariadb`
- OCI index Digest：`sha256:d769e37960821dfdcf096954f6e7ac89f747e116c1bba98e48edd265dfc7deae`
- **linux/amd64** Manifest Digest：`sha256:6c65a843396dc6c78dd0da19eccaa0a91d25d9d26a4c2afcb75010ac3f59f5ea`
- Config Digest：`sha256:72b6ab51626b71b6118295b90c9408e537ff1cfdaa0b35c9930e8c2ee49a47bf`

所有Digest来自此前已在GitHub冻结的本项目`laravel13_safe_integration_toolchain_input_receipt_20261030.json`（Blob `023063c48424897aa247a8b85e55f1676db3acd9`）及已限定接受的Linux工具链回执。它们是**此项目的候选锁定来源**，不是Astra于2026-10-31再次从本机联网下载的镜像原字节。若tag现在指向别的Digest，必须仍按以上不可变对象请求；确实无法从官方registry获取则停止并单独报告，不自动换tag。

## 3. 实际下载方式：Owner 自主运行可选本地辅助脚本

建议使用在本会话提供的 `EliteSync_Owner_Official_OCI_Download_20261031.py`，代码SHA256 `12e6b6e0fa10b3542f245162e2fb1ac8def93d4346f5961b44d3a7d899e2afde`。这是**Owner自愿运行的纯Python3标准库下载辅助程序**；其Windows网络表现未经Astra本机执行检验。它不启动Docker/WSL、不安装任何软件、不读取旧项目源/数据库、不运行Codex。只从官方Docker Registry按上面Digest下载index/manifest/config及全部被manifest引用的Layer；每份文件核SHA256、Descriptor size，失败限次重取，不把partial冒作完整镜像，不保存匿名token或CDN授权URL。

将辅助脚本先保存到Owner自己的Downloads，使用已安装Python3自行运行：`py -3 EliteSync_Owner_Official_OCI_Download_20261031.py` （或实际可用的`python`）。默认输出推荐子目录。成功时应出现`DOWNLOAD_AND_SHA256_PASS`与`owner-download-manifest.json`，两个镜像分目录保存Blob文件。**此成功只是Owner本地文件下载/Hash报告；Codex必须在新独立任务中复验。** 用户也可用符合相同Digest和Manifest的其他官方下载工具；绝不强制运行脚本。脚本若失败/没有最终Manifest，则不派发Codex，不手动改SHA或用第三方不明包替代。不要粘贴匿名token/raw链接到聊天或GitHub。

Docker官方Registry两个核心只读API（需要有效Bearer Token，不是可直接用浏览器保存文件的公共直链）：
- `GET https://registry-1.docker.io/v2/library/php/manifests/<PINNED_DIGEST>` 与 `.../blobs/<LAYER_SHA256>`
- `GET https://registry-1.docker.io/v2/library/mariadb/manifests/<PINNED_DIGEST>` 与 `.../blobs/<LAYER_SHA256>`
- 公开token端点：`https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/php:pull`，MariaDB同理；token是短期临时数据，不得公开或长期缓存。

## 4. Codex启动前文件检查

Owner在`C:\Users\zcxve\Downloads\EliteSync-v1015-OCI-20261031`应看到`owner-download-manifest.json`、`php/`及`mariadb/`两个目录，内部各有index、manifest、config和镜像层blob。**只是存在不够**：用户侧下载完成后Codex重新检查：
1. GitHub固定index SHA256，index必须选出唯一linux/amd64且Manifest Digest精确匹配；
2. Manifest Config SHA、各Layer SHA、字节长度全部符合Descriptor；Linux/amd64 Config身份及`rootfs.diff_ids`数目一致；
3. 对每层安全解压到新task-owned根、逐层核uncompressed diff-id、检测tar路径穿越/设备文件/特殊属性风险，组装可回读OCI或Docker save archive，导入任务专属tag并再核实际镜像配置/hash/platform；不得直接对Downloads文件`docker load`未经验证；
4. 备份本机原旧目录11,066件和SHA回执沿旧任务保持不变，备份不上传，不覆盖旧工作根、不清旧镜像/volume。手动获取的原始文件始终是**OWNER_EXTERNAL_SUPPLY**，不可虚称为新任务通过代理计量的网络请求/字节，亦不能把其计入“Codex下载了0所以全流程总供给为0”；
5. PHP/Composer依赖可能仍需新任务在严格预算内自有可信HTTPS供应。若无合格可信下载/计量能力则STOP，不要从Downloads猜测其他包可用。

## 5. 现在不代表已完成

`FILES_STAGED`：NOT_YET_CONFIRMED；`CODEX_IMPORT`：NOT_RUN；`LARAVEL13_TARGET_MAIN_RUNTIME`：NOT_RUN；`MAIN_PRODUCT_INTEGRATED`：FALSE；`OLD_VERSION_DELETION_AUTHORIZED`：FALSE。等Owner真正下载完成、手动提交启动Prompt后，Codex才能按**新正式综合任务**行动，不能续前轮STOP账本、默认接受历史业务逻辑或删除旧版。
