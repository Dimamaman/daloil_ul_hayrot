#!/usr/bin/env python3
"""
Kontent validatori.

Tekshiruvlar:
  1. id takrorlanishi
  2. Bo'sh yoki yo'q maydonlar (id, ar, status — majburiy)
  3. status qiymati: draft / proofread / verified
  4. "verified" status uchun kamida 2 ta verified_by
  5. Tashkil (harakat) nisbati — past bo'lsa ogohlantirish
  6. Umumiy hisobot: draft / proofread / verified soni

Foydalanish:
  python validate.py <fayl.json>
  python validate.py <papka/>          # papkadagi barcha .json
  python validate.py <fayl.json> --strict
"""

import json
import sys
import unicodedata
import argparse
from pathlib import Path

VALID_STATUSES = {"draft", "proofread", "verified"}
REQUIRED_FIELDS = ["id", "status"]
MIN_VERIFIED_BY = 2

# Tashkil (harakat) belgilari diapazoni: U+064B — U+0652 + U+0670 (superscript alif)
TASHKIL_RANGE = set(range(0x064B, 0x0653)) | {0x0670}
# Asosiy arab harflari (tashkil va raqamlardan tashqari)
ARABIC_LETTER_CATS = {"Lo", "Lm"}

# Tashkil nisbati chegaralari
TASHKIL_ERROR_RATIO = 0.15   # bundan past → XATO (deyarli harakatsiz)
TASHKIL_WARN_RATIO = 0.30    # bundan past → ogohlantirish


class Validator:
    def __init__(
        self,
        strict: bool = False,
        tashkil_error: float = TASHKIL_ERROR_RATIO,
        tashkil_warn: float = TASHKIL_WARN_RATIO,
    ):
        self.errors: list[str] = []
        self.warnings: list[str] = []
        self.strict = strict
        self.tashkil_error = tashkil_error
        self.tashkil_warn = tashkil_warn
        self.stats = {"draft": 0, "proofread": 0, "verified": 0, "unknown": 0}

    def check_required(self, entry: dict, loc: str) -> None:
        for field in REQUIRED_FIELDS:
            val = entry.get(field)
            if val is None:
                self.errors.append(f"{loc}: '{field}' maydoni yo'q")
            elif isinstance(val, str) and val.strip() == "":
                self.errors.append(f"{loc}: '{field}' maydoni bo'sh")

        # Arabcha matn — "ar" yoki "arabic" bo'lishi kerak
        ar_val = entry.get("ar") or entry.get("arabic")
        if ar_val is None:
            self.errors.append(f"{loc}: 'ar' maydoni yo'q")
        elif isinstance(ar_val, str) and ar_val.strip() == "":
            self.errors.append(f"{loc}: 'ar' maydoni bo'sh")

        # Ixtiyoriy maydonlar — bor lekin bo'sh bo'lsa ogohlantirish
        for field in ("tr", "uz", "source", "transliteration", "translation"):
            val = entry.get(field)
            if isinstance(val, str) and val.strip() == "":
                self.warnings.append(f"{loc}: '{field}' maydoni bo'sh string")

    def check_status(self, entry: dict, loc: str) -> None:
        status = entry.get("status", "")
        if not status:
            return

        if status not in VALID_STATUSES:
            self.errors.append(
                f"{loc}: noma'lum status '{status}' "
                f"(ruxsat etilgan: {', '.join(sorted(VALID_STATUSES))})"
            )
            self.stats["unknown"] += 1
            return

        self.stats[status] += 1

    def check_verified_by(self, entry: dict, loc: str) -> None:
        status = entry.get("status", "")
        verified_by = entry.get("verified_by", [])

        if status == "verified":
            if not isinstance(verified_by, list):
                self.errors.append(
                    f"{loc}: 'verified_by' list bo'lishi kerak"
                )
                return

            if len(verified_by) < MIN_VERIFIED_BY:
                self.errors.append(
                    f"{loc}: 'verified' status uchun kamida {MIN_VERIFIED_BY} ta "
                    f"verified_by kerak, hozir {len(verified_by)} ta"
                )

            # Bo'sh ismlar
            for i, name in enumerate(verified_by):
                if not isinstance(name, str) or name.strip() == "":
                    self.errors.append(
                        f"{loc}: verified_by[{i}] bo'sh"
                    )

    def check_tashkil(self, entry: dict, loc: str) -> None:
        arabic = entry.get("ar") or entry.get("arabic", "")
        if not arabic:
            return

        letter_count = 0
        tashkil_count = 0

        for ch in arabic:
            cp = ord(ch)
            if cp in TASHKIL_RANGE:
                tashkil_count += 1
            elif unicodedata.category(ch) in ARABIC_LETTER_CATS:
                letter_count += 1

        if letter_count == 0:
            return

        ratio = tashkil_count / letter_count
        status = entry.get("status", "")
        detail = (
            f"{ratio:.1%} ({tashkil_count} harakat / {letter_count} harf), "
            f"status={status}"
        )

        # proofread/verified matnda tashkil_warn dan past → har doim XATO
        if status in ("proofread", "verified") and ratio < self.tashkil_warn:
            self.errors.append(
                f"{loc}: tekshirilgan matnda tashkil yetarli emas — {detail}"
            )
        elif ratio < self.tashkil_error:
            self.errors.append(
                f"{loc}: tashkil juda past — {detail}. "
                f"Matn deyarli harakatsiz, ilovaga yaramaydi"
            )
        elif ratio < self.tashkil_warn:
            self.warnings.append(
                f"{loc}: tashkil nisbati past — {detail}. "
                f"Kiritishda harakat tushib qolgan bo'lishi mumkin"
            )

    def check_nfc(self, entry: dict, loc: str) -> None:
        for field in ("ar", "arabic", "tr", "uz", "transliteration", "translation"):
            val = entry.get(field)
            if not isinstance(val, str):
                continue
            if val != unicodedata.normalize("NFC", val):
                self.errors.append(f"{loc}.{field}: NFC normalizatsiyasida emas")

    def validate_entry(self, entry: dict, index: int, file_label: str = "") -> None:
        eid = entry.get("id", f"#{index}")
        prefix = f"{file_label}[{eid}]" if file_label else f"[{eid}]"

        self.check_required(entry, prefix)
        self.check_nfc(entry, prefix)
        self.check_status(entry, prefix)
        self.check_verified_by(entry, prefix)
        self.check_tashkil(entry, prefix)


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
    raise ValueError(f"{path}: tanilmagan format")


def collect_files(target: Path) -> list[Path]:
    if target.is_file():
        return [target]
    if target.is_dir():
        files = sorted(target.glob("**/*.json"))
        if not files:
            print(f"XATO: {target} papkasida .json fayl topilmadi", file=sys.stderr)
            sys.exit(1)
        return files
    print(f"XATO: {target} topilmadi", file=sys.stderr)
    sys.exit(1)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Kontent JSON validatori"
    )
    parser.add_argument(
        "input", type=Path,
        help="JSON fayl yoki papka (papkadagi barcha .json tekshiriladi)"
    )
    parser.add_argument(
        "--strict", action="store_true",
        help="Ogohlantirishlarni ham xato sifatida hisoblash"
    )
    parser.add_argument(
        "--tashkil-error", type=float, default=TASHKIL_ERROR_RATIO,
        help=f"Tashkil XATO chegarasi (default: {TASHKIL_ERROR_RATIO})"
    )
    parser.add_argument(
        "--tashkil-warn", type=float, default=TASHKIL_WARN_RATIO,
        help=f"Tashkil ogohlantirish chegarasi (default: {TASHKIL_WARN_RATIO})"
    )
    args = parser.parse_args()

    files = collect_files(args.input)
    validator = Validator(
        strict=args.strict,
        tashkil_error=args.tashkil_error,
        tashkil_warn=args.tashkil_warn,
    )
    all_ids: dict[str, str] = {}  # id → fayl nomi
    total_entries = 0

    for path in files:
        try:
            entries = load_entries(path)
        except (ValueError, json.JSONDecodeError) as e:
            validator.errors.append(f"{path.name}: {e}")
            continue

        file_label = path.name if len(files) > 1 else ""

        for i, entry in enumerate(entries):
            total_entries += 1
            eid = entry.get("id", "")

            # ID takrorlanishi — barcha fayllar bo'ylab
            if eid and eid in all_ids:
                validator.errors.append(
                    f"[{eid}]: id takrorlangan "
                    f"({all_ids[eid]} va {path.name} da)"
                )
            elif eid:
                all_ids[eid] = path.name

            validator.validate_entry(entry, i, file_label)

    # ─── Hisobot ───
    print(f"Fayllar: {len(files)}")
    print(f"Yozuvlar: {total_entries}")
    print()

    s = validator.stats
    total_status = s["draft"] + s["proofread"] + s["verified"]
    if total_status > 0:
        print("STATUS HISOBOTI:")
        print(f"  draft:     {s['draft']:>4} ({s['draft']/total_status:.0%})")
        print(f"  proofread: {s['proofread']:>4} ({s['proofread']/total_status:.0%})")
        print(f"  verified:  {s['verified']:>4} ({s['verified']/total_status:.0%})")
        if s["unknown"]:
            print(f"  noma'lum:  {s['unknown']:>4}")
        print()

    if validator.warnings:
        print(f"OGOHLANTIRISHLAR ({len(validator.warnings)}):")
        for w in validator.warnings:
            print(f"  ⚠ {w}")
        print()

    if validator.errors:
        print(f"XATOLAR ({len(validator.errors)}):")
        for e in validator.errors:
            print(f"  ✗ {e}")
        print()
        exit_code = 1
    else:
        exit_code = 0

    if args.strict and validator.warnings:
        exit_code = 1

    if exit_code == 0:
        print("Natija: barcha tekshiruvlar o'tdi ✓")
    else:
        err_count = len(validator.errors)
        warn_count = len(validator.warnings)
        print(f"Natija: {err_count} xato, {warn_count} ogohlantirish")

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
