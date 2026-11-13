# v10.1.6 R1 补充任务书

日期：2026-11-13（北京时间）。状态：**已下达，待本地Codex接续**。依据：[顾问验收](../ADVISOR_ACCEPTANCE_20261113.md)。原[计划](../plan.md)和Owner普通工程授权继续适用。

## 一 目标与接续

在已完成资料、照片和真实审核发布成果上，只修复R1-01受众旁路与R1-02部署身份问题。完成后集中交付并停下再次验收。

仓库：zcx369658780/EliteSync-v10。分支：codex/v10.1.6-backend-productization-20261113。被审候选：222923bdec970bc2b2fcec4c51320edcb4f74688。继续稳定根D:\EliteSync-v10-product-v1015-20261101。

先核实际根、remote、分支、HEAD、工作区/index，读取AGENTS、ACTIVE_STATE当前块、本任务和顾问验收。远端将有承接222923bd的文档提交，保护本地新成果后正常接续；不reset/clean/强推、不复制工程。不需要先交设计或准备报告等待批准。

## 二 R1-01 统一Showcase受众在已有投影中的执行

### 已确定的问题

SlowDatingService::projectLocked只凭public_display_eligible读取发布快照，向journey和decision响应投影self_intro、interest_tags、lifestyle_tags。当前有效匹配但不满足friends/relationship受众的对象仍可能读到这些内容。详见顾问验收的固定代码与调用链。

### 实现要求

1. 让当前可达的Showcase消费者使用一致的发布状态、所选受众和当前关系/账号/拉黑判定；至少覆盖详情、图片与慢约提案摘要，避免重复规则再次分歧。
2. 无权读取展示内容时，提案响应的Showcase部分应为空或保持既有兼容的不可见语义；合法提案状态、接受/拒绝/撤回等决策仍然正常。不得用扩大受众默认值、默认公开或关闭慢约来绕过问题。
3. 沿用当前好友、contacts、正式关系分享的实际语义；新私有草稿不进入投影，缺少显式受众也不能被随意推导为新增授权。
4. 保持既有有序用户锁和幂等重放语义。JourneyStore的提案重放会重新projectLocked，随同验证该读取结果。只按需检查Showcase当前消费者，不开展全仓安全重构。

### 最少必要验收

| ID | 完成条件 |
|---|---|
| R1-01-A | 构造“有效未到期匹配仍存在，但不是好友”的对象；friends发布内容不从GET journey或decision响应返回。relationship发布内容对无相应正式关系的匹配对象同样不返回 |
| R1-01-B | 当前真正获准的对象仍得到允许的内容；选择contacts且满足既有匹配/联系条件时保持正常结果，合法提案决策不被资料隐藏误伤 |
| R1-01-C | 当前发布快照与权限生效；代表性的撤回、受众收紧、关系失效/拉黑和命令重放仍受约束。复用现有相关检查，按本次影响补必要分支 |
| R1-01-D | 回归实际命中journey/decision应用路径，不只测试一个孤立布尔函数。记录修复前可触发条件与修复后的必要正反结果 |

两个受众和两个消费者可参数化为紧凑回归组。具名夹具可用于权限反例和接口回归，明确它们是测试条件，不冒充普通产品成功链。不要求从头完成整套匹配、等待自然轮次或重新拍摄全部APP流程。修复部署后只做受影响的最短读取/权限检查；当前真实资料链的无关验证继续继承。

## 三 R1-02 三个控制器的候选与部署身份对齐

范围仅为：
- services/backend-laravel/app/Http/Controllers/Api/V1/ProfileShowcaseDraftController.php
- services/backend-laravel/app/Http/Controllers/Api/V1/ProfileShowcasePublicationController.php
- services/backend-laravel/app/Http/Controllers/Web/AdminShowcaseController.php

旧manifest所记SHA256和固定Git字节值见顾问验收，不需要重新核查全部工程文件。

### 最少必要验收

| ID | 完成条件 |
|---|---|
| R1-02-A | 分别读取固定候选Git Blob、工作树、实际API容器部署文件的字节数及SHA256；说明旧manifest值对应什么对象，查不到则保留旧来源未确认 |
| R1-02-B | 最终实际部署逻辑对应本次候选。纯格式差异可记录各自精确字节与确定性转换；存在逻辑差异则先确定采用内容并同步源码/部署，不能只改一个hash掩盖未部署差异 |
| R1-02-C | manifest分别明确Git字节、工作树/部署字节及必要转换或相等关系，绑定最终代码；报告区分继承验证与新验证 |
| R1-02-D | 纯记录错误或可证格式差异只核对身份和必要语法；若有逻辑差异，仅验证其影响的保存/提交、Web审核或发布路径，并与R1-01检查合并 |

若APP逻辑未变，可沿用现有APK并如实绑定；不为这项记录修正强制重建APK。必要部署/服务刷新由Codex按实际情况自主完成，保留数据库与既有测试数据。

## 四 范围与交付出口

本轮不要求SFU恢复或根因定位。SFU当前exited、房间UNAVAILABLE及OPEN/UNKNOWN继续按具名时点记录；不得写成Room0或全部服务可用。真实Push、身份供应商、手机、公司/内测和集中UI不进入本R1。

仅新修改、失败或具体风险扩大验证。已完成的照片排序移除、需修改重提、真实APP/Web发布和重启持久化成果继续按具名范围继承，不重跑全量矩阵、25分钟观察或旧120张截图。

集中交付：
- 实际修复代码及与两项直接相关的回归。
- 本目录README.md一份R1结果，说明两项结论、差异来源、实际验证、继承范围及未完成项。
- 更新版本artifact_manifest.json及ACTIVE_STATE短入口，记录最终源码、三文件身份、必要候选和资源时点；原候选和本次顾问结论留在Git历史。
- 普通同步同版分支并回读，提交固定commit与报告入口，然后停下顾问验收。同步失败记PENDING_SYNC并保护本地成果。

两项均闭合且没有新实质问题即可交复核；不自动启动v10.1.7，不合main、不发布。普通修复及定向验证沿已有授权自主完成，不逐动作重新申请。
