#!/usr/bin/env python3
"""Remove const from widgets whose subtree contains context.tr."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

CONST_WIDGETS = ("Padding", "Row", "Column", "Align", "Center", "SizedBox", "DefaultTextStyle", "RichText", "ListTile", "InputDecoration")

for f in (ROOT / "lib/features").rglob("*.dart"):
    text = f.read_text(encoding="utf-8")
    original = text
    for widget in CONST_WIDGETS:
        # const Padding( ... context.tr - remove const
        text = re.sub(
            rf"\bconst\s+({widget}\()",
            r"\1",
            text,
        )
    # Fix broken apostrophe in plain string assignments (not context.tr)
    fixes = [
        ("_errorMessage = 'Enter your child's Quest ID, email, or PQ code first.'",
         '_errorMessage = "Enter your child\'s Quest ID, email, or PQ code first."'),
        ("content: Text('Message sent to ${detail.displayName}'s parent.')",
         'content: Text("Message sent to ${detail.displayName}\'s parent.")'),
    ]
    for old, new in fixes:
        text = text.replace(old, new)
    if text != original:
        f.write_text(text, encoding="utf-8")
        print(f.relative_to(ROOT))
