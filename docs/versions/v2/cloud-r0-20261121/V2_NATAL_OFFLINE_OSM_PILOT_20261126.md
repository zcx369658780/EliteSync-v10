# 2026-11-26｜V2 排盘 OSM 离线样本

## 范围

本机原型覆盖北京市、武汉市、宜昌市的 10 个公开地点。包括 3 个城市、2 个区县、天安门城楼及 4 个医院院区。北京协和医院东单和西单两个候选分别显示院区名称及地址。武汉首义院区使用武汉大学人民医院和湖北省人民医院等已核对的别名。该目录按城市分组，未收录的名称和城市返回空结果。

城市点取 OSM 命名节点。区县、地标和院区采用已核对的 OSM 面要素，经计算得到位于面内部的代表点。客户端展示点位层级及 OSM 署名和许可入口。用户选择后只填入当前草稿。院区代表点表示院区范围。 [OSM WGS84 原始数据说明](https://wiki.openstreetmap.org/wiki/Projection) · [OSM 数据许可](https://www.openstreetmap.org/copyright) · [北京协和医院院区地址](https://www.pumch.cn/azimuth.html)

## 生成与启用

[生成器](../../../../tools/natal/build_place_catalog.py) 使用 pyosmium 4.3.2 和 Shapely 2.2.0，核对 2026-11-25 北京、湖北 Geofabrik 快照的 SHA-256 和 10 个源要素。文件 `beijing.osm.pbf` 和 `hubei.osm.pbf`、下载回执、生成的 `NATAL_OSM_PLACE_CATALOG.json` 及本机 HTTP 回执保存在本机评估目录。生成数据采用 ODbL，保留署名和来源元数据，随部署单独提供。 [Geofabrik 地区索引](https://download.geofabrik.de/asia/china/)

```text
python tools/natal/build_place_catalog.py --beijing <beijing.osm.pbf> --hubei <hubei.osm.pbf> --output <catalog.json>
NATAL_PLACE_CATALOG_PATH=<catalog.json 的可读本机绝对路径>
```

专用环境从该配置读取本机目录。未配置、文件不可读或坐标系不符时，排盘地点路由返回 503。路由保留鉴权、限流和 `private, no-store`。查询只有地点名称和城市，由 EliteSync 进程在本机读取目录完成。

## 本机验收

- Laravel 定向 15/15，覆盖无配置、错误坐标系、城市约束、普通地点接口和排盘相邻功能。配置有效目录且存在百度凭据的合成回归验证排盘查询无出站调用、无命盘写入。
- Flutter 排盘定向 12/12，覆盖错误坐标系、服务不可用、来源和代表点展示、选择后回填以及会话切换防护。
- 真实本机 HTTP 使用合成身份和独立 SQLite。健康 200，未登录请求 401，已登录公开查询 10/10。北京协和两院区消歧、武汉别名、宜昌城市样本、跨城空结果和未收录空结果通过。天安门城楼代表点距公开参考点 15.6 米。命盘记录写入 0。 [天安门公开参考点](https://commons.wikimedia.org/wiki/Tiananmen?uselang=zh)

## Staging 和 APK 1011813

Owner 同意继续专用 Staging 样本试用。服务只读挂载原目录，API 要求新客户端声明 `X-EliteSync-Natal-Places: osm-v1`，确保回填前能显示点位层级和数据来源。旧客户端继续收到 503。回环健康 200，未鉴权请求 401。运行应用返回北京协和两院区，出站调用 0 次。原数据库、队列、网关与应用网络不变。

1011813 已完成 AAR 和 Android 宿主构建。包名 `com.elitesync.v2stagingremote`，与 1011812 同签名，arm64-v8a。候选 SHA-256 为 `987302ff12db14f642761e9f52cd4d793b22ba7bfa4a0f97df7633ee433b1b10`。地名目录通过服务器提供。具名手机 25060RK16C 的已装版本与 1011812 哈希回读通过。新候选安装需按具名 SHA 确认。

最新回归为 Laravel 地点 8/8、Flutter 12/12、合成身份本机 HTTP 10/10。旧客户端请求 503，新能力请求 200，命盘写入 0。真机回填待验。

Owner 已确认具名手机和候选 SHA。25060RK16C 由 1011812 原位升级到 1011813，调用 1 次，退出 0。版本、已装 APK 哈希、appId、首次安装时间、数据目录和包清单回读通过。装机授权已消费。更新后 APP 首页已打开，随后手机从 ADB 列表消失，实际地点搜索与草稿回填待测。公开天安门城楼样本为 WGS84 39.907359, 116.391263。

## 1011813 真机回填

25060RK16C 重新连入后，真实搜索先显示服务未开通。外层 V2 Staging 代理沿精确路径白名单返回闭路 404，无上游。将唯一的 `POST /api/v1/profile/natal/places` 纳入现有 app 来源类别，与仓库模板同步。隔离回环 Nginx 规则 6/6，覆盖目标 POST、同路径 GET、子路径 POST、尾斜线 POST 及既有命盘 GET/POST。语法检查和热重载通过。来源、鉴权、TLS、端口和云防火墙设定保持原状态。公网 443 连通性探测 0 次。

真机用公开输入 `Tiananmen / Beijing` 搜到天安门城楼，候选显示离线样本、地标代表点、OSM 署名及 WGS84 39.907359, 116.391263。选中后地点、纬度和经度均从实体表单确认。复验时外层脱敏回执为允许来源、HTTP 200 和上游正常。退出并重新进入后确认三个测试字段已清空，命盘保存或计算按钮未触发。范围为 1011813 在 25060RK16C 的一个公开地点。

## Owner 实机反馈

Owner 确认 1011813 可使用已保存坐标进行三盘计算。从外部百度地图手动切回后，原排盘坐标保持。百度 Android 地点搜索 URI 的作用是启动搜索结果页面，系统返回负责切回 EliteSync。排盘页内「搜索并带入坐标」在选中离线候选后更新当前草稿，亦可手动填写已确认的 WGS84 坐标。 [百度地图调起说明](https://lbsyun.baidu.com/docs/webapi?title=mapadjustment%2Furi%2Fandriod)
