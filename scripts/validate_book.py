#!/usr/bin/env python3
"""
book.json tekshiruvchisi.

Tekshiruvlar:
  1. Unicode NFC normalizatsiyasi — arabcha tashkil belgilari buzilmasligi uchun
  2. Arabcha maydondagi begona belgilar — faqat arab alifbosi, tashkil, raqamlar va tinish
  3. ID takrorlanishi — har bir section va hizb id'si yagona bo'lishi shart
  4. Bo'sh maydonlar — majburiy maydonlar bo'sh string bo'lmasligi kerak
"""

import json
import sys
import unicodedata
import re
from pathlib import Path

BOOK_PATH = Path(__file__).parent.parent / "assets" / "data" / "book.json"

# Arab harflari, tashkil belgilari, raqamlar, Qur'on belgilari, probel va tinish
ARABIC_PATTERN = re.compile(
    r'^[؀-ۿ'   # Asosiy arab bloki
    r'ݐ-ݿ'     # Arab qo'shimchasi
    r'ﭐ-﷿'     # Arab A shakllari
    r'ﹰ-﻿'     # Arab B shakllari
    r'﴾﴿'      # Qur'on qavslari ﴾﴿
    r'٠-٩'      # Arab-hind raqamlari
    r'\s\.\,\:\;\!\?'     # Probel va tinish belgilari
    r']+$'
)

errors: list[str] = []
warnings: list[str] = []


def check_nfc(text: str, location: str) -> None:
    normalized = unicodedata.normalize("NFC", text)
    if text != normalized:
        errors.append(f"[NFC] {location}: matn NFC normalizatsiyasida emas")


def check_arabic_purity(text: str, location: str) -> None:
    for i, ch in enumerate(text):
        if ch in " \t\n\r":
            continue
        cat = unicodedata.category(ch)
        name = unicodedata.name(ch, "")

        is_arabic = (
            "؀" <= ch <= "ۿ"
            or "ݐ" <= ch <= "ݿ"
            or "ﭐ" <= ch <= "﷿"
            or "ﹰ" <= ch <= "﻿"
            or ch in "﴾﴿"
            or "٠" <= ch <= "٩"
        )
        is_punctuation = cat.startswith("P") or cat.startswith("S")

        if not is_arabic and not is_punctuation:
            errors.append(
                f"[BEGONA] {location}[{i}]: '{ch}' (U+{ord(ch):04X} {name})"
            )


def check_ids(hizbs: list[dict]) -> None:
    seen_hizb: dict[str, int] = {}
    seen_section: dict[str, str] = {}

    for hizb in hizbs:
        hid = hizb["id"]
        if hid in seen_hizb:
            errors.append(f"[ID] Hizb id takrorlangan: '{hid}'")
        seen_hizb[hid] = hizb["order"]

        for section in hizb.get("sections", []):
            sid = section["id"]
            if sid in seen_section:
                errors.append(
                    f"[ID] Section id takrorlangan: '{sid}' "
                    f"('{seen_section[sid]}' va '{hid}' da)"
                )
            seen_section[sid] = hid


def check_required_fields(obj: dict, fields: list[str], location: str) -> None:
    for field in fields:
        val = obj.get(field)
        if val is None:
            errors.append(f"[BO'SH] {location}: '{field}' maydoni yo'q")
        elif isinstance(val, str) and val.strip() == "":
            errors.append(f"[BO'SH] {location}: '{field}' maydoni bo'sh")


def validate(book: dict) -> None:
    if "version" not in book:
        errors.append("[SXEMA] 'version' maydoni yo'q")
    if "hizbs" not in book:
        errors.append("[SXEMA] 'hizbs' maydoni yo'q")
        return

    hizbs = book["hizbs"]
    check_ids(hizbs)

    for hi, hizb in enumerate(hizbs):
        hloc = f"hizbs[{hi}] ({hizb.get('id', '?')})"
        check_required_fields(hizb, ["id", "order", "title", "sections"], hloc)
        check_nfc(hizb.get("title", ""), f"{hloc}.title")

        for si, section in enumerate(hizb.get("sections", [])):
            sloc = f"{hloc}.sections[{si}] ({section.get('id', '?')})"
            check_required_fields(
                section, ["id", "type", "title", "arabic"], sloc
            )

            arabic = section.get("arabic", "")
            if arabic:
                check_nfc(arabic, f"{sloc}.arabic")
                check_arabic_purity(arabic, f"{sloc}.arabic")

            title = section.get("title", "")
            if title:
                check_nfc(title, f"{sloc}.title")

            valid_types = {"salavot", "duo", "names"}
            stype = section.get("type", "")
            if stype and stype not in valid_types:
                warnings.append(
                    f"[TUR] {sloc}: noma'lum type '{stype}' "
                    f"(kutilgan: {valid_types})"
                )


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else BOOK_PATH

    if not path.exists():
        print(f"XATO: fayl topilmadi: {path}")
        return 1

    with open(path, encoding="utf-8") as f:
        book = json.load(f)

    validate(book)

    hizb_count = len(book.get("hizbs", []))
    section_count = sum(
        len(h.get("sections", [])) for h in book.get("hizbs", [])
    )
    print(f"Fayl: {path}")
    print(f"Hizblar: {hizb_count}, Bo'limlar: {section_count}")
    print()

    if warnings:
        print(f"--- OGOHLANTIRISHLAR ({len(warnings)}) ---")
        for w in warnings:
            print(f"  ⚠ {w}")
        print()

    if errors:
        print(f"--- XATOLAR ({len(errors)}) ---")
        for e in errors:
            print(f"  ✗ {e}")
        print(f"\nNatija: {len(errors)} ta xato topildi")
        return 1

    print("Natija: barcha tekshiruvlar o'tdi ✓")
    return 0


if __name__ == "__main__":
    sys.exit(main())
