#!/usr/bin/env python3
"""Apply context.tr() to static UI strings in presentation dart files."""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IMPORT_SUFFIX = "app_language_controller.dart"

SKIP_FILES = {
    "language.dart",
    "account_details.dart",
    "sound_screen.dart",
    "registration_validators.dart",
    "settings_navigation_helper.dart",
    "module_ui_helper.dart",
    "parent_link_child_helper.dart",
}

TARGET_DIRS = [
    "lib/features/auth/presentation",
    "lib/features/signup/presentation",
    "lib/features/dashboard/presentation",
    "lib/features/settings/presentation",
    "lib/features/subscription/presentation",
    "lib/features/quiz/presentation",
    "lib/features/rewards/presentation",
    "lib/features/payment/presentation",
    "lib/features/progress/presentation",
    "lib/features/notifications/presentation",
    "lib/features/home/presentation",
]

# Props that take user-visible static strings
PROP_NAMES = (
    "label",
    "title",
    "hintText",
    "subtitle",
    "stepLabel",
    "trailingText",
    "content",
    "message",
)

SKIP_STRING_PATTERNS = [
    r"^assets/",
    r"^lib/",
    r"^package:",
    r"^/",
    r"^[A-Z_]+$",  # ALL_CAPS codes used as keys sometimes - but SAVE should translate
    r"^\d",
    r"^#",
    r"^http",
    r"^pq_",
    r"^student$",
    r"^teacher$",
    r"^parent$",
]

# These ALL_CAPS are UI labels we DO want to translate
FORCE_TRANSLATE = {
    "SAVE", "ADD", "NEXT", "LOGIN", "CONTINUE", "CANCEL", "CONFIRM", "RETRY",
    "STUDENT", "PARENT", "TEACHER", "PREMIUM", "METRIC", "SCORE", "ACTION",
}


def should_skip_string(s: str) -> bool:
    if not s or len(s) < 2:
        return True
    if "$" in s or "{" in s:
        return True
    if "context.tr(" in s:
        return True
    if s in ("Student", "Parent", "Teacher", "student", "teacher", "parent"):
        return False  # role labels - translate display
    for pat in SKIP_STRING_PATTERNS:
        if re.match(pat, s, re.I):
            if s.upper() in FORCE_TRANSLATE:
                return False
            return True
    return False


def relative_import_path(file_path: Path) -> str:
    depth = len(file_path.relative_to(ROOT / "lib").parts) - 1
    return f"{'../' * depth}core/l10n/{IMPORT_SUFFIX}"


def add_import(content: str, import_line: str) -> str:
    if IMPORT_SUFFIX in content:
        return content
    lines = content.splitlines(keepends=True)
    last_import = 0
    for i, line in enumerate(lines):
        if line.startswith("import "):
            last_import = i + 1
    lines.insert(last_import, f"import '{import_line}';\n")
    return "".join(lines)


def replace_text_calls(content: str) -> tuple[str, int]:
    count = 0

    def repl_text(m: re.Match) -> str:
        nonlocal count
        prefix = m.group(1) or ""
        quote = m.group(2)
        s = m.group(3)
        if should_skip_string(s):
            return m.group(0)
        count += 1
        const_removed = prefix.replace("const ", "")
        return f"{const_removed}Text(context.tr({quote}{s}{quote})"

    # Text('...') and Text("...")
    content = re.sub(
        r"(const\s+)?Text\(\s*(['\"])(.*?)\2",
        repl_text,
        content,
        flags=re.DOTALL,
    )
    return content, count


def replace_prop_strings(content: str) -> tuple[str, int]:
    count = 0
    for prop in PROP_NAMES:

        def repl(m: re.Match, p=prop) -> str:
            nonlocal count
            prefix = m.group(1) or ""
            quote = m.group(2)
            s = m.group(3)
            if should_skip_string(s):
                return m.group(0)
            count += 1
            const_removed = prefix.replace("const ", "")
            return f"{const_removed}{p}: context.tr({quote}{s}{quote})"

        content = re.sub(
            rf"(const\s+)?{prop}:\s*(['\"])(.*?)\2",
            repl,
            content,
        )
    return content, count


def replace_textspan(content: str) -> tuple[str, int]:
    count = 0

    def repl(m: re.Match) -> str:
        nonlocal count
        quote = m.group(1)
        s = m.group(2)
        if should_skip_string(s):
            return m.group(0)
        count += 1
        return f"TextSpan(text: context.tr({quote}{s}{quote})"

    content = re.sub(
        r"const\s+TextSpan\(text:\s*(['\"])(.*?)\1",
        repl,
        content,
    )
    content = re.sub(
        r"TextSpan\(text:\s*(['\"])(.*?)\1(?!\s*,\s*style)",
        repl,
        content,
    )
    return content, count


def process_file(path: Path) -> tuple[int, list[str]]:
    original = path.read_text(encoding="utf-8")
    if path.name in SKIP_FILES:
        return 0, []
    if "context.t." in original and original.count("context.t.") > 8 and "context.tr(" not in original:
        return 0, []

    content = original
    total = 0
    for fn in (replace_text_calls, replace_prop_strings, replace_textspan):
        content, n = fn(content)
        total += n

    if total == 0:
        return 0, []

    import_line = relative_import_path(path)
    content = add_import(content, import_line)

    if content != original:
        path.write_text(content, encoding="utf-8")

    # collect new strings for map
    new_strings = re.findall(r"context\.tr\((['\"])(.*?)\1", content)
    return total, [s for _, s in new_strings]


def collect_files() -> list[Path]:
    files: list[Path] = []
    for d in TARGET_DIRS:
        p = ROOT / d
        if p.exists():
            files.extend(p.rglob("*.dart"))
    files.extend((ROOT / "lib/features/journey").glob("*.dart"))
    return sorted(set(files))


def main() -> None:
    all_strings: set[str] = set()
    modified: list[tuple[str, int]] = []
    for f in collect_files():
        n, strings = process_file(f)
        if n:
            modified.append((str(f.relative_to(ROOT)), n))
            all_strings.update(strings)

    print(f"Modified {len(modified)} files")
    for path, n in modified:
        print(f"  {n:3d} {path}")
    print(f"Total replacements: {sum(n for _, n in modified)}")

    # Check translation map
    map_path = ROOT / "lib/core/l10n/app_translation_maps.dart"
    map_text = map_path.read_text(encoding="utf-8")
    missing = sorted(s for s in all_strings if f"'{s}'" not in map_text and f'"{s}"' not in map_text)
    if missing:
        print(f"\nMissing from map ({len(missing)}):")
        for s in missing[:50]:
            print(f"  {s[:80]}")


if __name__ == "__main__":
    main()
