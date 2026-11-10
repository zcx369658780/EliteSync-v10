# EliteSync v10.1.5｜Owner官方下载的OCI镜像：本地Docker存储验真优先、原始文件备选｜2026-10-31 v1.1

**状态：OWNER_PULLED_DOCKER_LOCAL_STORE_OBSERVED / ORIGINAL_DOWNLOADS_RAW_OCI_OPTIONAL_ONLY / CODEX_INDEPENDENT_IMAGE_QUALIFICATION_REQUIRED / NO_CODEX_DISPATCH_YET / NO_INSTALL_OR_DELETE**

> 本v1.1在旧Blob `47aad6d1ad89f9c6e680af53cd42623874060c47` 基础上修订，解决Owner已经使用`docker pull`直接把镜像下载到本机Docker content store、而非下载裸文件到Downloads的实际情况。原指导中“必须有owner-download-manifest.json才能启动Codex”现**不再是必要条件**。旧文件仍可在Git历史追溯。

## 1. Owner实际操作与两个不同SHA类型

Owner提供的真实输出：
- `docker pull php:8.4.27-cli-bookworm` 报告Index Digest `sha256:54b467ede1db96c66675e7b78457dd43729d0e7be31978d4a1e5c069ceabcf76`，`docker image inspect`报告`linux/amd64`、`.Id=sha256:54b467ede1db96c66675e7b78457dd43729d0e7be31978d4a1e5c069ceabcf76`。
- `docker pull mariadb:10.11.19-ubi9` 获得不同UBI9镜像，不是本任务受信优选来源；现保留，不修改/删除/运行。
- 后续 `docker image inspect mariadb:10.11.19-jammy` 报告`linux/amd64`、`.Id=sha256:7db29378d4fdab73f8123bbc2b48905c90d1a4b00cf848b028f1e81e623257f2`。Owner未提供其完整Pull stdout、RepoDigests、Descriptor或配置和diff-id的本机原始回执，尚未能从GitHub直接验真。

Docker Engine 29的containerd存储环境里，`.Id`可以是Image Index Target Digest，不能一律等于Image Config Digest。不要因PHP`.Id=54b...`却不等于旧Config`12f...`断言失败，也不要因MariaDB`.Id=7db...`和原Index`d769...`不同就断言非官方。**任何`.Id`本身都不足以证明平台子Manifest、Config、所有Layer与来源正确。**

官方文档：
- https://docs.docker.com/engine/storage/containerd/
- https://docs.docker.com/reference/cli/docker/image/inspect/
- https://docs.docker.com/reference/cli/docker/image/ls/

## 2. 官方已冻结的身份和允许核验的候选

PHP `library/php:8.4.27-cli-bookworm`：
- 旧官方Index `sha256:54b467ede1db96c66675e7b78457dd43729d0e7be31978d4a1e5c069ceabcf76`
- linux/amd64 Manifest `sha256:dd0e2b902f1edfb6ca02fbcb391c28b1554c7d35a4e36e5925876b90aa804851`
- Config `sha256:12f6d2ea136f247580f3dc42bda86b27af080fa8f04ea5ec9b581238702093ff`

MariaDB `library/mariadb:10.11.19-jammy`：
- 先前已在项目核验的旧Index `sha256:d769e37960821dfdcf096954f6e7ac89f747e116c1bba98e48edd265dfc7deae`，对应linux/amd64 Manifest `sha256:6c65a843396dc6c78dd0da19eccaa0a91d25d9d26a4c2afcb75010ac3f59f5ea`，旧Config `sha256:72b6ab51626b71b6118295b90c9408e537ff1cfdaa0b35c9930e8c2ee49a47bf`。
- Owner现有另一个**官方索引候选** `sha256:7db29378d4fdab73f8123bbc2b48905c90d1a4b00cf848b028f1e81e623257f2`；Docker Hub对这一索引显示linux/amd64 Manifest `sha256:dc9dd57be7f46ad6f350c598a331d64f295899c4abac3ec5652eff831fc38a6c`。这一替代索引/平台Manifest**不等于旧锁**，只能在新的Codex任务中从官方Registry固定Digest/平台Manifest元数据读回，并对Owner本机镜像对象、配置与RootFS diffIDs形成独立闭环后认定为`QUALIFIED_NAMED_ALTERNATE_MARIADB_10_11_19_JAMMY`；新Config Digest不得凭空假设和旧值相同。若不能闭环，停止使用，不自动替换为UBI9或可变tag。
- 官方MariaDB页面记录：`https://hub.docker.com/layers/library/mariadb/10.11.19/images/sha256-dc9dd57be7f46ad6f350c598a331d64f295899c4abac3ec5652eff831fc38a6c`；既有旧平台`https://hub.docker.com/layers/library/mariadb/10.11/images/sha256-6c65a843396dc6c78dd0da19eccaa0a91d25d9d26a4c2afcb75010ac3f59f5ea`。Docker Hub所称官方不等于本机已验真。

## 3. 下载后的Owner用户操作：不必重复拉取

Owner不必为本轮再手动运行`docker pull`、`docker save`、`docker tag`或Docker清理。已有本地镜像可保留原样。Codex**只有Owner稍后手动派发更新后的正式任务**才可从指定本地Docker Linux endpoint：
1. 仅读取指定两个镜像的`RepoDigests`、`Descriptor`（如果API提供）、`Id`、平台、大小、RootFS diffID链、Docker engine/content-store身份与当前image tags；观察其它旧容器仅限总量/自动启动风险，不查看其它项目数据。
2. 通过官方Registry的固定Index/平台Manifest与Config响应（只允许受控、完整计量的少量元数据请求）确定平台候选与配置期望；不得仅以tag、`.Id`或Docker Hub网页文本放行。
3. 可`docker image save --platform linux/amd64`将**受信的指定Owner镜像**只读导出到新task-owned临时tar，解析其Manifest/Config/RootFS diffIDs、实际export前后身份以及本地完整性。不将`docker save`生成的tar压缩格式Hash冒称原Registry压缩Layer Digest；原压缩Layer Hash必须有Registry内容地址证明，否则标`COMPRESSED_ORIGINAL_LAYER_RAW_NOT_RECALCULATED`。只有在可核实际平台、可信来源以及完整本地配置和diffID闭包的情况下，才允许创建新的**任务专属、隔离且限制外联**的容器/卷做合成回归。不能修改/删除Owner原镜像tag或共享卷。
4. 任何官方元数据不符合冻结候选、仓库本地引擎意外变化、Docker身份/许可失效、权限/计量不合格即STOP，不依赖已STOP的旧任务容器、vendor、ledger。
5. Owner本轮实际下载的数据属于`OWNER_EXTERNAL_DOCKER_PULL`、发生在新Codex task之前，不伪造为新task supply0覆盖全部真实外部下载；Codex自己新增的任何供应与代理仍遵守独立预算。

## 4. 备用：Downloads中Owner手动原始OCI文件

若在合格环境中无法从本机Docker store验证完整性，才考虑Owner此前提出的`C:\Users\zcxve\Downloads`文件式备选，建议放`EliteSync-v1015-OCI-20261031`子目录，并提供`owner-download-manifest.json`与`php/`、`mariadb/`。这是**替代输入**，不要求Owner现在再次下载；精确index/Manifest/Config/各Layer必须逐件重新SHA256/size、解压diffID、权限/路径检查后才进入新任务隔离环境。不得执行未核来源脚本，不能扫描Downloads其它文件，也不能要求Owner直接运行来源不明安装包。若需要继续下载/改变官方源，先说明具体阻断与新授权，不让用户陷入重复下载循环。

## 5. 未改的产品门禁

Owner已正式选择Laravel13+PHP8.4后续**开发基线**，但新的f407选择性主线代码仍`SAFE_INTEGRATION_NOT_ACCEPTED / TARGET_MAIN_RUNTIME_NOT_RUN`；此前9b74运行过的广义候选不等于当前main运行已验。原本11,066文件本地旧版备份继续LOCAL_ONLY保留，旧Laravel11/dirty/vendor、旧任务STOP/ledger不动。不得因此自动提交产品main、改变默认开发入口、删除旧版或关闭AC05/G2。
