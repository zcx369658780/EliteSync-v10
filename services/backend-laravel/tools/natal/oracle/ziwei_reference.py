#!/usr/bin/env python3
"""Independent rule oracle, standard library only; no product/library imports.

Consumes independently established lunar dates, never converts solar dates.
Only placement facts are modelled; this is not a scientific validity assertion.
See ziwei_reference_sources.json for rule provenance and deliberate omissions.
CLI: python ziwei_reference.py < input.json ; --samples emits frozen sample results.
"""
import json
import sys
from pathlib import Path

STEMS = "甲乙丙丁戊己庚辛壬癸"
BRANCHES = "子丑寅卯辰巳午未申酉戌亥"
PALACES = ["命宫", "兄弟", "夫妻", "子女", "财帛", "疾厄", "迁移", "仆役", "官禄", "田宅", "福德", "父母"]
# Thirty Na-yin pairs in sexagenary order: factual element classification.
NAYIN = "金火木土金火水土金木水土火木水金火木土金火水土金木水土火木水"
BUREAUS = {"水": 2, "木": 3, "金": 4, "土": 5, "火": 6}
# Modern ten-stem profile, independently transcribed from two publishers.
HUA = [
    ["廉贞", "破军", "武曲", "太阳"],
    ["天机", "天梁", "紫微", "太阴"],
    ["天同", "天机", "文昌", "廉贞"],
    ["太阴", "天同", "天机", "巨门"],
    ["贪狼", "太阴", "右弼", "天机"],
    ["武曲", "贪狼", "天梁", "文曲"],
    ["太阳", "武曲", "太阴", "天同"],
    ["巨门", "太阳", "文曲", "文昌"],
    ["天梁", "紫微", "左辅", "武曲"],
    ["破军", "巨门", "太阴", "贪狼"],
]
HUA_TYPES = ["禄", "权", "科", "忌"]


def index(value, alphabet, field):
    if isinstance(value, int) and not isinstance(value, bool) and 0 <= value < len(alphabet):
        return value
    if isinstance(value, str) and value in alphabet and len(value) == 1:
        return alphabet.index(value)
    raise ValueError("invalid " + field)


def chart(data):
    """Indices use 子=0 and 甲=0. Lunar year is supplied, not inferred.

    algorithmSex is male/female, only for directional traditional rules.
    leapMonth=true: day 1..15 uses nominal month, 16..30 next month;
    the lunar DAY is retained (it is not reduced by fifteen).
    yearStem/yearBranch must agree with independently supplied lunarYear.
    """
    year, month, day = (data[k] for k in ("lunarYear", "lunarMonth", "lunarDay"))
    if any(not isinstance(x, int) or isinstance(x, bool) for x in (year, month, day)):
        raise ValueError("lunar values must be integers")
    if not 1 <= month <= 12 or not 1 <= day <= 30:
        raise ValueError("lunar month/day out of bounds")
    if not isinstance(data.get("leapMonth", False), bool):
        raise ValueError("leapMonth must be boolean")
    ys = index(data["yearStem"], STEMS, "yearStem")
    yb = index(data["yearBranch"], BRANCHES, "yearBranch")
    hour = index(data["hourBranch"], BRANCHES, "hourBranch")
    if ys != (year - 4) % 10 or yb != (year - 4) % 12:
        raise ValueError("lunar year and supplied year stem/branch disagree")
    sex = data["algorithmSex"]
    if sex not in ("male", "female"):
        raise ValueError("algorithmSex must be male/female")
    effective_month = month + int(data.get("leapMonth", False) and day > 15)
    month_anchor = (2 + effective_month - 1) % 12
    life, body = (month_anchor - hour) % 12, (month_anchor + hour) % 12
    # Five tigers: 寅 receives 丙/戊/庚/壬/甲; advance from 寅 through 丑.
    yin_stem = (2 * (ys % 5) + 2) % 10
    palace_stems = [(yin_stem + (b - 2) % 12) % 10 for b in range(12)]
    cycle = next(i for i in range(60) if i % 10 == palace_stems[life] and i % 12 == life)
    element = NAYIN[cycle // 2]
    bureau = BUREAUS[element]
    # Independent arithmetic interpretation of the published placement rule.
    quotient = (day + bureau - 1) // bureau
    supplement = quotient * bureau - day
    ziwei = (2 + quotient - 1 + (supplement if supplement % 2 == 0 else -supplement)) % 12
    tianfu = (4 - ziwei) % 12  # reflection around the 寅/申 axis
    stars = {}

    def put(name, branch):
        stars[name] = branch % 12

    for name, offset in (("紫微", 0), ("天机", -1), ("太阳", -3), ("武曲", -4), ("天同", -5), ("廉贞", -8)):
        put(name, ziwei + offset)
    for name, offset in (("天府", 0), ("太阴", 1), ("贪狼", 2), ("巨门", 3), ("天相", 4), ("天梁", 5), ("七杀", 6), ("破军", 10)):
        put(name, tianfu + offset)
    put("左辅", 4 + effective_month - 1)
    put("右弼", 10 - (effective_month - 1))
    put("文昌", 10 - hour)
    put("文曲", 4 + hour)
    # Modern named profile: 辛午寅, 丙丁亥酉, not literal 卷二 readings.
    kui, yue = [(1, 7), (0, 8), (11, 9), (11, 9), (1, 7), (0, 8), (1, 7), (6, 2), (3, 5), (3, 5)][ys]
    put("天魁", kui)
    put("天钺", yue)
    lu = [2, 3, 5, 6, 5, 6, 8, 9, 11, 0][ys]
    put("禄存", lu)
    put("擎羊", lu + 1)
    put("陀罗", lu - 1)
    # yb % 4 identifies the four trines: 子辰申, 丑巳酉, 寅午戌, 卯未亥.
    fire, bell = [(2, 10), (3, 10), (1, 3), (9, 10)][yb % 4]
    put("火星", fire + hour)
    put("铃星", bell + hour)
    put("天马", [2, 11, 8, 5][yb % 4])
    put("地空", 11 - hour)  # ancient 天空 here is modern 地空, not modern 天空.
    put("地劫", 11 + hour)
    put("台辅", 6 + hour)
    # Named production-target profile, independently attested by 卷二 and NCC.
    # The v1 Sanqing reverse variant and its 60/72 mismatches are preserved.
    put("封诰", 2 + hour)
    put("天刑", 9 + effective_month - 1)
    put("天姚", 1 + effective_month - 1)
    put("三台", stars["左辅"] + day - 1)
    put("八座", stars["右弼"] - (day - 1))
    put("天哭", 6 - yb)
    put("天虚", 6 + yb)
    put("龙池", 4 + yb)
    put("凤阁", 10 - yb)
    put("红鸾", 3 - yb)
    put("天喜", 9 - yb)
    put("天空", 1 + yb)
    put("天伤", life - 7)
    put("天使", life - 5)

    # Source-directed edge: source palace stem transforms a star at destination.
    def edges(source, stem):
        return [{"sourceBranchIndex": source, "sourceStem": STEMS[stem],
                 "transformation": kind, "star": star,
                 "targetBranchIndex": stars[star]} for kind, star in zip(HUA_TYPES, HUA[stem])]

    direction = 1 if ((ys % 2 == 0) == (sex == "male")) else -1
    by_branch = []
    for b in range(12):
        label = PALACES[(life - b) % 12]
        by_branch.append({"branchIndex": b, "branch": BRANCHES[b],
                          "stem": STEMS[palace_stems[b]], "name": label,
                          "isBodyPalace": b == body,
                          "stars": sorted(name for name, at in stars.items() if at == b)})
    return {"oracle": "independent-ziwei-rules-v2-fenggao-forward", "input": data,
            "effectiveLunarMonth": effective_month,
            "lifeBranchIndex": life, "bodyBranchIndex": body,
            "fiveElement": element, "bureauNumber": bureau,
            "palaces": by_branch, "starPositions": stars,
            "birthHua": edges(None, ys),
            "palaceStemHuaEdges": [edge for b in range(12) for edge in edges(b, palace_stems[b])],
            "decadeDirection": direction,
            "decades": [{"branchIndex": (life + direction * i) % 12,
                         "startAge": bureau + i * 10, "endAge": bureau + i * 10 + 9}
                        for i in range(12)],
            "unknown": ["brightness", "unlistedMinorStars", "calendarConversion",
                        "lunarMonthExistenceAndLength", "birthTimeConversion", "interpretation"]}


def main():
    if sys.argv[1:] == ["--samples"]:
        source = json.loads(Path(__file__).with_name("ziwei_reference_sources.json").read_text(encoding="utf-8"))
        result = [{"id": case["id"], "split": case["split"], "expected": chart(case["input"])}
                  for case in source["samples"]]
    elif sys.argv[1:]:
        raise SystemExit("usage: ziwei_reference.py [--samples]")
    else:
        value = json.load(sys.stdin)
        result = [chart(item) for item in value] if isinstance(value, list) else chart(value)
    print(json.dumps(result, ensure_ascii=False, sort_keys=True, indent=2))


if __name__ == "__main__":
    main()
