#!/usr/bin/env python3
"""
Arabcha matn normalizer.

Kiritilgan JSON faylni tozalaydi:
  - Unicode NFC normalizatsiyasi
  - Ko'p bo'shliqlarni bittaga, qator boshi/oxiridagi bo'shliq olib tashlash
  - Arabcha bo'lmagan belgilar haqida ogohlantirish
  - Arab va arab-hind raqamlari aralashganda ogohlantirish

Foydalanish:
  python normalize.py <fayl.json>
  python normalize.py <fayl.json> -o <chiqish.json>
  python normalize.py <fayl.json> --dry-run
"""

import json
import sys
import re
import unicodedata
import argparse
from pathlib import Path

# ─── Belgi tekshirish uchun diapazonlar ───

# Ko'rinmas belgilar — ogohlantirish kerak
INVISIBLE_CHARS = {
    "‌": "ZWNJ (Zero Width Non-Joiner)",
    "‍": "ZWJ (Zero Width Joiner)",
    "‎": "LRM (Left-to-Right Mark)",
    "‏": "RLM (Right-to-Left Mark)",
    "​": "ZWSP (Zero Width Space)",
    "⁠": "Word Joiner",
    "﻿": "BOM (Byte Order Mark)",
    "­": "Soft Hyphen",
    "؜": "Arabic Letter Mark",
}

# Noto'g'ri tire belgilari — arabchada ishlatilmasligi kerak
WRONG_DASHES = {
    "–": "EN DASH (–)",
    "—": "EM DASH (—)",
    "‒": "FIGURE DASH (‒)",
    "―": "HORIZONTAL BAR (―)",
    "-": "HYPHEN-MINUS (-)",
}

# Arab raqamlari (٠-٩) va lotin raqamlari (0-9)
ARABIC_INDIC_DIGITS = set("٠١٢٣٤٥٦٧٨٩")
LATIN_DIGITS = set("0123456789")

# Ruxsat etilgan arabcha belgilar
def is_arabic_char(ch: str) -> bool:
    cp = ord(ch)
    return (
        0x0600 <= cp <= 0x06FF      # Arabic
        or 0x0750 <= cp <= 0x077F   # Arabic Supplement
        or 0x08A0 <= cp <= 0x08FF   # Arabic Extended-A
        or 0xFB50 <= cp <= 0xFDFF   # Arabic Presentation Forms-A
        or 0xFE70 <= cp <= 0xFEFF   # Arabic Presentation Forms-B
        or 0xFD3E <= cp <= 0xFD3F   # ﴾﴿
        or ch == "﷼"           # ﷼
    )


class Normalizer:
    def __init__(self, dry_run: bool = False):
        self.warnings: list[str] = []
        self.changes: list[str] = []
        self.dry_run = dry_run

    def normalize_whitespace(self, text: str, loc: str) -> str:
        original = text

        # Boshi va oxiridagi bo'shliq
        stripped = text.strip()
        if stripped != text:
            self.changes.append(f"  {loc}: boshi/oxiridagi bo'shliq olib tashlandi")
            text = stripped

        # Ko'p bo'shliqlarni bittaga
        collapsed = re.sub(r"[ \t]+", " ", text)
        if collapsed != text:
            self.changes.append(f"  {loc}: ko'p bo'shliqlar bittaga tushirildi")
            text = collapsed

        # Bo'sh qator ichidagi ortiqcha bo'shliqlar
        cleaned = re.sub(r" *\n *", "\n", text)
        if cleaned != text:
            self.changes.append(f"  {loc}: qator atrofi bo'shliqlari tozalandi")
            text = cleaned

        return text

    def normalize_nfc(self, text: str, loc: str) -> str:
        normalized = unicodedata.normalize("NFC", text)
        if normalized != text:
            diff_count = sum(1 for a, b in zip(text, normalized) if a != b)
            self.changes.append(
                f"  {loc}: NFC normalizatsiyasi ({diff_count} belgi o'zgardi)"
            )
        return normalized

    def check_invisible_chars(self, text: str, loc: str) -> None:
        for pos, ch in enumerate(text):
            if ch in INVISIBLE_CHARS:
                name = INVISIBLE_CHARS[ch]
                self.warnings.append(
                    f"  {loc}[{pos}]: ko'rinmas belgi — {name} (U+{ord(ch):04X})"
                )

    def check_wrong_dashes(self, text: str, loc: str) -> None:
        for pos, ch in enumerate(text):
            if ch in WRONG_DASHES:
                name = WRONG_DASHES[ch]
                self.warnings.append(
                    f"  {loc}[{pos}]: noto'g'ri tire — {name}"
                )

    def check_non_arabic(self, text: str, loc: str) -> None:
        for pos, ch in enumerate(text):
            if ch in " \t\n\r":
                continue
            cat = unicodedata.category(ch)
            if cat.startswith("P") or cat.startswith("S"):
                continue
            if is_arabic_char(ch):
                continue
            if cat == "Nd" and ch in ARABIC_INDIC_DIGITS:
                continue

            name = unicodedata.name(ch, f"U+{ord(ch):04X}")
            if cat.startswith("L") and "LATIN" in name.upper():
                self.warnings.append(
                    f"  {loc}[{pos}]: LOTIN harfi — '{ch}' ({name})"
                )
            elif cat == "Nd" and ch in LATIN_DIGITS:
                pass  # raqam aralashmasi alohida tekshiriladi
            else:
                self.warnings.append(
                    f"  {loc}[{pos}]: arabcha bo'lmagan belgi — "
                    f"'{ch}' (U+{ord(ch):04X} {name})"
                )

    def check_mixed_digits(self, text: str, loc: str) -> None:
        has_arabic = bool(ARABIC_INDIC_DIGITS & set(text))
        has_latin = bool(LATIN_DIGITS & set(text))
        if has_arabic and has_latin:
            self.warnings.append(
                f"  {loc}: arab (٠-٩) va lotin (0-9) raqamlari aralashgan"
            )

    def process_arabic_field(self, text: str, loc: str) -> str:
        text = self.normalize_nfc(text, loc)
        text = self.normalize_whitespace(text, loc)
        self.check_invisible_chars(text, loc)
        self.check_wrong_dashes(text, loc)
        self.check_non_arabic(text, loc)
        self.check_mixed_digits(text, loc)
        return text

    def process_text_field(self, text: str, loc: str) -> str:
        text = self.normalize_nfc(text, loc)
        text = self.normalize_whitespace(text, loc)
        return text

    def process_entry(self, entry: dict, index: int) -> dict:
        eid = entry.get("id", f"#{index}")
        loc_prefix = f"[{eid}]"

        result = dict(entry)

        for ar_field in ("ar", "arabic"):
            if ar_field in entry and isinstance(entry[ar_field], str) and entry[ar_field]:
                result[ar_field] = self.process_arabic_field(
                    entry[ar_field], f"{loc_prefix}.{ar_field}"
                )

        for field in ("tr", "uz", "source", "transliteration", "translation",
                       "title", "titleUz"):
            if field in entry and isinstance(entry[field], str) and entry[field]:
                result[field] = self.process_text_field(
                    entry[field], f"{loc_prefix}.{field}"
                )

        return result


def load_entries(path: Path) -> list[dict]:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and "sections" in data:
        return data["sections"]
    if isinstance(data, dict) and "hizbs" in data:
        entries = []
        for hizb in data["hizbs"]:
            entries.extend(hizb.get("sections", []))
        return entries
    raise ValueError(
        "JSON formati tanilmadi — list, {sections:[...]}, yoki {hizbs:[...]} kutilgan"
    )


def save_entries(path: Path, original_data, entries: list[dict]) -> None:
    if isinstance(original_data, list):
        out = entries
    elif isinstance(original_data, dict) and "sections" in original_data:
        out = dict(original_data)
        out["sections"] = entries
    elif isinstance(original_data, dict) and "hizbs" in original_data:
        out = dict(original_data)
        idx = 0
        for hizb in out["hizbs"]:
            n = len(hizb.get("sections", []))
            hizb["sections"] = entries[idx : idx + n]
            idx += n
    else:
        out = entries

    with open(path, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Arabcha matn normalizer — NFC, bo'shliq, begona belgilar"
    )
    parser.add_argument("input", type=Path, help="Kirish JSON fayli")
    parser.add_argument(
        "-o", "--output", type=Path, default=None,
        help="Chiqish fayli (berilmasa, asl fayl ustiga yoziladi)"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Faqat hisobot — faylni o'zgartirmaslik"
    )
    args = parser.parse_args()

    if not args.input.exists():
        print(f"XATO: fayl topilmadi: {args.input}", file=sys.stderr)
        return 1

    with open(args.input, encoding="utf-8") as f:
        original_data = json.load(f)

    try:
        entries = load_entries(args.input)
    except ValueError as e:
        print(f"XATO: {e}", file=sys.stderr)
        return 1

    norm = Normalizer(dry_run=args.dry_run)
    processed = [norm.process_entry(entry, i) for i, entry in enumerate(entries)]

    # ─── Hisobot ───
    print(f"Fayl: {args.input}")
    print(f"Yozuvlar: {len(entries)}")
    print()

    if norm.changes:
        print(f"O'ZGARISHLAR ({len(norm.changes)}):")
        for c in norm.changes:
            print(c)
        print()

    if norm.warnings:
        print(f"OGOHLANTIRISHLAR ({len(norm.warnings)}):")
        for w in norm.warnings:
            print(w)
        print()

    if not norm.changes and not norm.warnings:
        print("Hech qanday muammo topilmadi.")
        return 0

    if args.dry_run:
        print("(--dry-run: fayl o'zgartirilmadi)")
        return 1 if norm.warnings else 0

    out_path = args.output or args.input
    save_entries(out_path, original_data, processed)
    print(f"Saqlandi: {out_path}")

    return 1 if norm.warnings else 0


if __name__ == "__main__":
    sys.exit(main())
