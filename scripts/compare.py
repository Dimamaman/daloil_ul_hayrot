#!/usr/bin/env python3
"""
Ikki matn faylini so'zma-so'z solishtirish.

Har bir yozuvning 'ar' maydonini so'zlarga bo'lib, farqni
harakatlar darajasida rangli ko'rsatadi.

Foydalanish:
  python compare.py <eski.json> <yangi.json>
  python compare.py <eski.json> <yangi.json> --id h1_s1
  python compare.py <eski.json> <yangi.json> --no-color
"""

import json
import sys
import argparse
from pathlib import Path
from difflib import SequenceMatcher

# ─── Terminal ranglari ───

class Colors:
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    CYAN = "\033[36m"
    DIM = "\033[2m"
    BOLD = "\033[1m"
    RESET = "\033[0m"
    BG_RED = "\033[41;37m"
    BG_GREEN = "\033[42;30m"

class NoColors:
    RED = GREEN = YELLOW = CYAN = DIM = BOLD = RESET = BG_RED = BG_GREEN = ""


def load_entries_by_id(path: Path) -> dict[str, dict]:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)

    entries: list[dict] = []
    if isinstance(data, list):
        entries = data
    elif isinstance(data, dict) and "sections" in data:
        entries = data["sections"]
    elif isinstance(data, dict) and "hizbs" in data:
        for hizb in data["hizbs"]:
            entries.extend(hizb.get("sections", []))
    else:
        raise ValueError(f"{path}: tanilmagan format")

    by_id: dict[str, dict] = {}
    for entry in entries:
        eid = entry.get("id", "")
        if eid:
            by_id[eid] = entry
    return by_id


def tokenize_arabic(text: str) -> list[str]:
    tokens: list[str] = []
    current = ""
    for ch in text:
        if ch in " \t\n\r":
            if current:
                tokens.append(current)
                current = ""
        else:
            current += ch
    if current:
        tokens.append(current)
    return tokens


def format_word_diff(old_words: list[str], new_words: list[str], c) -> list[str]:
    sm = SequenceMatcher(None, old_words, new_words)
    lines: list[str] = []

    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            chunk = " ".join(old_words[i1:i2])
            lines.append(f"{c.DIM}{chunk}{c.RESET}")
        elif tag == "delete":
            chunk = " ".join(old_words[i1:i2])
            lines.append(f"{c.BG_RED} -{chunk} {c.RESET}")
        elif tag == "insert":
            chunk = " ".join(new_words[j1:j2])
            lines.append(f"{c.BG_GREEN} +{chunk} {c.RESET}")
        elif tag == "replace":
            old_chunk = " ".join(old_words[i1:i2])
            new_chunk = " ".join(new_words[j1:j2])
            lines.append(f"{c.BG_RED} -{old_chunk} {c.RESET}")
            lines.append(f"{c.BG_GREEN} +{new_chunk} {c.RESET}")

    return lines


def compare_field(
    old_text: str | None,
    new_text: str | None,
    field: str,
    entry_id: str,
    c,
) -> tuple[list[str], bool]:
    output: list[str] = []
    changed = False

    if old_text == new_text:
        return output, False

    if old_text is None and new_text is not None:
        output.append(
            f"  {c.CYAN}{field}{c.RESET}: "
            f"{c.GREEN}+yangi qo'shilgan{c.RESET}"
        )
        return output, True

    if old_text is not None and new_text is None:
        output.append(
            f"  {c.CYAN}{field}{c.RESET}: "
            f"{c.RED}-o'chirilgan{c.RESET}"
        )
        return output, True

    old_words = tokenize_arabic(old_text or "")
    new_words = tokenize_arabic(new_text or "")

    diff_parts = format_word_diff(old_words, new_words, c)
    if diff_parts:
        output.append(f"  {c.CYAN}{field}{c.RESET}:")
        output.append("    " + " ".join(diff_parts))
        changed = True

    return output, changed


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Ikki JSON faylni so'zma-so'z solishtirish"
    )
    parser.add_argument("old", type=Path, help="Eski fayl")
    parser.add_argument("new", type=Path, help="Yangi fayl")
    parser.add_argument(
        "--id", dest="filter_id", default=None,
        help="Faqat bitta yozuvni solishtirish"
    )
    parser.add_argument(
        "--no-color", action="store_true",
        help="Rangsiz chiqish"
    )
    parser.add_argument(
        "--fields", default="ar,tr,uz",
        help="Solishtiriladigan maydonlar (vergul bilan, default: ar,tr,uz)"
    )
    args = parser.parse_args()

    c = NoColors() if args.no_color else Colors()
    fields = [f.strip() for f in args.fields.split(",")]

    for p in (args.old, args.new):
        if not p.exists():
            print(f"XATO: fayl topilmadi: {p}", file=sys.stderr)
            return 1

    try:
        old_entries = load_entries_by_id(args.old)
        new_entries = load_entries_by_id(args.new)
    except (ValueError, json.JSONDecodeError) as e:
        print(f"XATO: {e}", file=sys.stderr)
        return 1

    all_ids = list(dict.fromkeys(list(old_entries.keys()) + list(new_entries.keys())))

    if args.filter_id:
        if args.filter_id not in old_entries and args.filter_id not in new_entries:
            print(
                f"XATO: '{args.filter_id}' id hech bir faylda topilmadi",
                file=sys.stderr,
            )
            return 1
        all_ids = [args.filter_id]

    print(f"{c.BOLD}Solishtirish:{c.RESET} {args.old.name} ↔ {args.new.name}")
    print(f"Maydonlar: {', '.join(fields)}")
    print()

    changed_count = 0
    added_count = 0
    removed_count = 0

    for eid in all_ids:
        old_entry = old_entries.get(eid)
        new_entry = new_entries.get(eid)

        if old_entry is None:
            added_count += 1
            print(f"{c.GREEN}+ [{eid}]{c.RESET} — yangi yozuv")
            continue

        if new_entry is None:
            removed_count += 1
            print(f"{c.RED}- [{eid}]{c.RESET} — o'chirilgan yozuv")
            continue

        entry_output: list[str] = []
        entry_changed = False

        for field in fields:
            # "ar" bo'lsa "arabic" maydonini ham tekshirish
            old_val = old_entry.get(field)
            new_val = new_entry.get(field)
            if field == "ar":
                old_val = old_val or old_entry.get("arabic")
                new_val = new_val or new_entry.get("arabic")
            field_output, field_changed = compare_field(
                old_val, new_val, field, eid, c
            )
            entry_output.extend(field_output)
            if field_changed:
                entry_changed = True

        # status o'zgarishini ham ko'rsatish
        old_status = old_entry.get("status", "")
        new_status = new_entry.get("status", "")
        if old_status != new_status:
            entry_output.append(
                f"  {c.CYAN}status{c.RESET}: "
                f"{c.YELLOW}{old_status}{c.RESET} → "
                f"{c.GREEN}{new_status}{c.RESET}"
            )
            entry_changed = True

        if entry_changed:
            changed_count += 1
            print(f"{c.YELLOW}~ [{eid}]{c.RESET}")
            for line in entry_output:
                print(line)
            print()

    # ─── Xulosa ───
    print(f"{c.BOLD}Xulosa:{c.RESET}")
    print(f"  Jami yozuvlar: eski={len(old_entries)}, yangi={len(new_entries)}")
    if changed_count:
        print(f"  {c.YELLOW}O'zgargan: {changed_count}{c.RESET}")
    if added_count:
        print(f"  {c.GREEN}Qo'shilgan: {added_count}{c.RESET}")
    if removed_count:
        print(f"  {c.RED}O'chirilgan: {removed_count}{c.RESET}")
    if not changed_count and not added_count and not removed_count:
        print(f"  {c.GREEN}Farq yo'q ✓{c.RESET}")

    return 1 if (changed_count or added_count or removed_count) else 0


if __name__ == "__main__":
    sys.exit(main())
