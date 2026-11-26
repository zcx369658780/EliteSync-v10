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

共享 Staging 数据接入与具名真机验收待授权。当前覆盖为公开样本。R1 PARTIAL，封闭内测与生产 NO_GO。
