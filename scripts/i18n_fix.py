#!/usr/bin/env python3
"""Fix i18n apply issues: const+context.tr, broken apostrophes, remaining patterns."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

DIRS = [
    ROOT / "lib/features",
]


def fix_apostrophes(content: str) -> str:
    # Fix Let\')s -> Let's inside tr strings
    content = re.sub(r"\\'\)", "'", content)
    content = re.sub(r"\\'\)", "'", content)
    # Fix You\')ve -> You've
    content = content.replace("\\')", "'")
    content = content.replace("\\'s", "'s")
    content = content.replace("\\'t", "'t")
    content = content.replace("\\'re", "'re")
    content = content.replace("\\'e", "'e")
    return content


def remove_const_with_tr(content: str) -> str:
    # const Text(context.tr -> Text(context.tr
    content = re.sub(r"\bconst\s+(Text\(context\.tr)", r"\1", content)
    content = re.sub(r"\bconst\s+(TextSpan\(text:\s*context\.tr)", r"\1", content)
    # const DropdownMenuItem with context.tr inside
    content = re.sub(
        r"const\s+(\[?\s*DropdownMenuItem\([^)]*context\.tr)",
        lambda m: m.group(0).replace("const ", "", 1),
        content,
        flags=re.DOTALL,
    )
    # items: const [ ... context.tr
    content = re.sub(r"items:\s*const\s+\[", "items: [", content)
    # const StandardScreenHeader(title: 'X') -> StandardScreenHeader(title: context.tr('X'))
    def fix_header(m):
        s = m.group(1)
        if "context.tr" in s:
            return m.group(0).replace("const ", "")
        return f"StandardScreenHeader(title: context.tr('{s}')"
    content = re.sub(
        r"const\s+StandardScreenHeader\(title:\s*'([^']+)'\)",
        fix_header,
        content,
    )
    # PrimaryButton label const patterns
    content = re.sub(
        r"PrimaryButton\(\s*label:\s*'([^']+)'",
        lambda m: f"PrimaryButton(label: context.tr('{m.group(1)}')",
        content,
    )
    # SnackBar AlertDialog title/content static
    content = re.sub(
        r"(title|content):\s*Text\('([^'$][^']*)'\)",
        lambda m: f"{m.group(1)}: Text(context.tr('{m.group(2)}'))",
        content,
    )
    # Remove remaining const before widgets with context.tr in children
    lines = content.splitlines(keepends=True)
    out = []
    for line in lines:
        if "context.tr(" in line and "const " in line:
            line = re.sub(r"\bconst\s+(?=\w)", "", line)
        out.append(line)
    return "".join(out)


def add_import_if_needed(path: Path, content: str) -> str:
    if "context.tr(" not in content:
        return content
    if "app_language_controller.dart" in content:
        return content
    depth = len(path.relative_to(ROOT / "lib").parts) - 1
    imp = f"import '{'../' * depth}core/l10n/app_language_controller.dart';\n"
    lines = content.splitlines(keepends=True)
    last_import = 0
    for i, line in enumerate(lines):
        if line.startswith("import "):
            last_import = i + 1
    lines.insert(last_import, imp)
    return "".join(lines)


def process(path: Path) -> bool:
    original = path.read_text(encoding="utf-8")
    content = fix_apostrophes(original)
    content = remove_const_with_tr(content)
    content = add_import_if_needed(path, content)
    if content != original:
        path.write_text(content, encoding="utf-8")
        return True
    return False


def main():
    changed = 0
    for d in DIRS:
        for f in d.rglob("*.dart"):
            if process(f):
                changed += 1
    print(f"Fixed {changed} files")


if __name__ == "__main__":
    main()
