"""Build a WGS84 administrative representative-point catalog from a GeoNames CN dump."""

import argparse
import hashlib
import json
import re
import zipfile
from pathlib import Path

ADMIN_NAMES = re.compile(r"[\u3400-\u9fff·]+")
SUFFIXES = {
    "ADM1": ("省", "自治区", "自治區", "市"),
    "ADM2": ("市", "自治州", "地区", "地區", "盟", "行政区划", "行政區劃"),
    "ADM3": ("区", "區", "县", "縣", "旗", "市"),
}
MUNICIPALITIES = {"北京市", "上海市", "天津市", "重庆市"}


def administrative_records(source):
    with zipfile.ZipFile(source) as archive, archive.open("CN.txt") as text:
        for line in text:
            row = line.decode("utf-8").rstrip("\r\n").split("\t")
            if len(row) != 19 or row[7] not in {"ADM1", "ADM2", "ADM3"} or row[8] != "CN":
                continue
            aliases = [value for value in dict.fromkeys((row[1], row[2], *row[3].split(","))) if 2 <= len(value) <= 50]
            label = next((value for value in aliases if ADMIN_NAMES.fullmatch(value) and value.endswith(SUFFIXES[row[7]])), None)
            if label is None:
                continue
            lat, lng = map(float, row[4:6])
            if not (-90 <= lat <= 90 and -180 <= lng <= 180):
                continue
            yield row[7], row[10], row[11], row[12], row[0], {
                "name": label, "aliases": aliases, "lat": lat, "lng": lng,
            }


def build_archive(source):
    records = list(administrative_records(source))
    provinces = {first: entry for level, first, _, _, _, entry in records if level == "ADM1" and first}
    municipalities = {code for code, province in provinces.items() if MUNICIPALITIES.intersection(province["aliases"])}
    cities = {}
    for level, first, second, _, identifier, entry in records:
        if first not in provinces:
            continue
        direct_municipality = first in municipalities
        if direct_municipality and level == "ADM1":
            key = (first, "")
        elif not direct_municipality and level == "ADM2" and second:
            key = (first, second)
        else:
            continue
        if key in cities:
            raise ValueError(f"Ambiguous catalog administration IDs {key}")
        province = provinces[first]
        cities[key] = {**entry, "province": province["name"], "province_aliases": province["aliases"],
                       "districts": {}, "geonames_id": identifier}
    for level, first, second, third, identifier, entry in records:
        if level != "ADM3" or not third:
            continue
        city = cities.get((first, "" if first in municipalities else second))
        if city is not None:
            city["districts"][identifier] = {**entry, "geonames_id": identifier}

    with source.open("rb") as content:
        source_sha256 = hashlib.file_digest(content, "sha256").hexdigest()
    return {
        "schema_version": 1, "coordinate_system": "WGS84", "source": "GeoNames",
        "source_license": "CC-BY-4.0", "source_sha256": source_sha256,
        "cities": {province + ":" + city: record for (province, city), record in cities.items()},
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    options = parser.parse_args()
    data = build_archive(options.source)
    with options.output.open("x", encoding="utf-8", newline="\n") as output:
        json.dump(data, output, ensure_ascii=False, separators=(",", ":"))
        output.write("\n")
    print(f"{len(data['cities'])} cities, {sum(len(city['districts']) for city in data['cities'].values())} districts")


if __name__ == "__main__":
    main()
