#!/usr/bin/env python3
"""Fix missing commas after Text(context.tr(...)) when style/other params follow."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FOLLOW_PARAMS = ("style", "textAlign", "maxLines", "overflow", "softWrap", "strutStyle", "textDirection", "locale", "semanticsLabel")

for f in ROOT.rglob("lib/**/*.dart"):
    text = f.read_text(encoding="utf-8")
    original = text

    # Fix apostrophe escapes in tr strings
    text = text.replace("\\')", "'")
    text = text.replace("Let')s", "Let's")
    text = text.replace("child')s", "child's")
    text = text.replace("today')s", "today's")
    text = text.replace("You')ve", "You've")
    text = text.replace("letter ')L", "letter 'L")
    text = text.replace("an ')e", "an 'e")

    lines = text.splitlines(keepends=True)
    fixed = []
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        if "Text(context.tr(" in stripped or "TextSpan(text: context.tr(" in stripped:
            # If line ends with ) but not ),  add comma when next line has named param
            if i + 1 < len(lines):
                nxt = lines[i + 1].strip()
                for param in FOLLOW_PARAMS:
                    if nxt.startswith(f"{param}:"):
                        if stripped.endswith(")") and not stripped.endswith("),"):
                            stripped = stripped[:-1] + "),"
                        break
        # Remove const when line has context.tr
        if "context.tr(" in stripped:
            stripped = re.sub(r"\bconst\s+(?=(Text|TextSpan|DropdownMenuItem|StandardScreenHeader|SnackBar|AlertDialog))", "", stripped)
            stripped = re.sub(r"\bconst\s+(Text\(context\.tr)", r"\1", stripped)
            stripped = re.sub(r"items:\s*const\s+\[", "items: [", stripped)
        fixed.append(stripped + ("\n" if line.endswith("\n") else ""))

    text = "".join(fixed)

    # StandardScreenHeader const fix
    text = re.sub(
        r"const\s+StandardScreenHeader\(title:\s*'([^']+)'\)",
        r"StandardScreenHeader(title: context.tr('\1'))",
        text,
    )
    # Add import to StandardScreenHeader files if needed
    if "StandardScreenHeader(title: context.tr" in text and "app_language_controller" not in text:
        depth = len(f.relative_to(ROOT / "lib").parts) - 1
        imp = f"import '{'../' * depth}core/l10n/app_language_controller.dart';\n"
        lines = text.splitlines(keepends=True)
        li = 0
        for i, line in enumerate(lines):
            if line.startswith("import "):
                li = i + 1
        lines.insert(li, imp)
        text = "".join(lines)

    if text != original:
        f.write_text(text, encoding="utf-8")
        print(f"fixed: {f.relative_to(ROOT)}")
