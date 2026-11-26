"""Build the natal search sample from the two evaluated Geofabrik extracts."""

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

import osmium
from shapely import from_wkb

SNAPSHOTS = {
    "beijing": "2805e226b1a0ce32e755dcfc34d7115a5f17f83c54e8844ba34184a397ca0db5",
    "hubei": "08b1330dc9e08f375e72c713df89cd8c2303bac5a1a8cba736d9cbb0db4aa744",
}
CITIES = {
    "北京市": ("北京市", ["北京", "Beijing"]),
    "武汉市": ("湖北省", ["武汉", "Wuhan"]),
    "宜昌市": ("湖北省", ["宜昌", "Yichang"]),
}


@dataclass(frozen=True)
class Site:
    extract: str
    osm_type: str
    osm_id: int
    osm_name: str
    city: str
    label: str
    point_kind: str
    aliases: tuple[str, ...] = ()
    area: str = ""
    address: str = ""


SITES = (
    Site("beijing", "node", 25248662, "北京市", "北京市", "北京市", "city", ("北京", "Beijing")),
    Site("hubei", "node", 244082219, "武汉市", "武汉市", "武汉市", "city", ("武汉", "Wuhan")),
    Site("hubei", "node", 244082544, "宜昌市", "宜昌市", "宜昌市", "city", ("宜昌", "Yichang")),
    Site("beijing", "relation", 288600, "东城区", "北京市", "东城区", "district", ("东城", "東城區"), "东城区"),
    Site("hubei", "relation", 3076297, "武昌区", "武汉市", "武昌区", "district", ("武昌", "武昌區"), "武昌区"),
    Site("beijing", "relation", 8847697, "天安门", "北京市", "天安门城楼", "landmark",
         ("天安门", "天安門", "Tiananmen", "Gate of Heavenly Peace"), "东城区", "西长安街1号"),
    Site("beijing", "relation", 19126182, "北京协和医院", "北京市", "北京协和医院东单院区", "campus",
         ("北京协和医院", "协和医院", "协和东单", "北京协和医院东院"), "东城区", "帅府园1号"),
    Site("beijing", "way", 922427110, "北京协和医院（西区）", "北京市", "北京协和医院西单院区", "campus",
         ("北京协和医院", "协和医院", "协和西单", "北京协和医院西区"), "西城区", "大木仓胡同41号"),
    Site("hubei", "way", 116577978, "武汉大学人民医院 (湖北省人民医院)", "武汉市", "武汉大学人民医院首义院区", "campus",
         ("武汉大学人民医院", "湖北省人民医院", "武汉大学人民医院主院区", "湖北省人民医院首义院区"), "武昌区", "解放路238号"),
    Site("hubei", "way", 690674886, "武汉协和医院", "武汉市", "武汉协和医院主院区", "campus",
         ("武汉协和医院", "协和医院", "华中科技大学同济医学院附属协和医院"), "江汉区", "解放大道1277号"),
)


class ReadSites(osmium.SimpleHandler):
    def __init__(self, sites):
        super().__init__()
        self.sites = {(site.osm_type, site.osm_id): site for site in sites}
        self.points = {}
        self.geometry = osmium.geom.WKBFactory()

    def node(self, node):
        key = ("node", node.id)
        if key in self.sites:
            self.check_name(key, node.tags)
            self.points[key] = (node.location.lat, node.location.lon)

    def area(self, area):
        key = ("way" if area.from_way() else "relation", area.orig_id())
        if key not in self.sites:
            return
        self.check_name(key, area.tags)
        geometry = from_wkb(bytes.fromhex(self.geometry.create_multipolygon(area)))
        if geometry.is_empty or not geometry.is_valid:
            raise ValueError(f"Invalid reference geometry for {key}")
        point = geometry.representative_point()
        if not geometry.contains(point):
            raise ValueError(f"Representative point is outside {key}")
        self.points[key] = (point.y, point.x)

    def check_name(self, key, tags):
        if tags.get("name") != self.sites[key].osm_name:
            raise ValueError(f"Name mismatch for {key}")


def build(extracts):
    regions = {city: {"aliases": aliases, "places": []} for city, (_, aliases) in CITIES.items()}
    for name, path in extracts.items():
        with path.open("rb") as stream:
            digest = hashlib.file_digest(stream, "sha256").hexdigest()
        if digest != SNAPSHOTS[name]:
            raise ValueError(f"{name} differs from the evaluated snapshot")
        sites = [site for site in SITES if site.extract == name]
        handler = ReadSites(sites)
        handler.apply_file(path, locations=True, idx="flex_mem")
        if handler.sites.keys() != handler.points.keys():
            raise ValueError(f"Missing reference geometry: {handler.sites.keys() - handler.points.keys()}")
        for key, site in handler.sites.items():
            lat, lng = handler.points[key]
            regions[site.city]["places"].append({
                "label": site.label,
                "aliases": site.aliases,
                "province": CITIES[site.city][0],
                "city": site.city,
                "area": site.area,
                "address": site.address,
                "point_kind": site.point_kind,
                "lat": round(lat, 7),
                "lng": round(lng, 7),
                "osm_ref": f"{site.osm_type}/{site.osm_id}",
            })

    return {
        "schema_version": 1,
        "coordinate_system": "WGS84",
        "source": "OpenStreetMap",
        "source_license": "ODbL-1.0",
        "source_snapshot_date": "2026-11-25",
        "source_sha256": SNAPSHOTS,
        "regions": regions,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--beijing", required=True, type=Path)
    parser.add_argument("--hubei", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    if args.output.exists():
        parser.error("output already exists")
    catalog = build({"beijing": args.beijing, "hubei": args.hubei})
    with args.output.open("x", encoding="utf-8", newline="\n") as output:
        json.dump(catalog, output, ensure_ascii=False, indent=2)
        output.write("\n")
    print(f"{len(SITES)} places in {len(CITIES)} regions")


if __name__ == "__main__":
    main()
