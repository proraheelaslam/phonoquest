#!/usr/bin/env python3
"""Fix context.tr strings containing apostrophes by using double quotes."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Find broken patterns: context.tr('...'s...) where string got split
BROKEN_PATTERNS = [
    (r"context\.tr\('Let's", r'context.tr("Let\'s'),
    (r"context\.tr\('You'v", r'context.tr("You\'ve'),
    (r"context\.tr\('Beat today's", r'context.tr("Beat today\'s'),
    (r"context\.tr\('Connect your child's", r'context.tr("Connect your child\'s'),
    (r"context\.tr\('Let')s", r'context.tr("Let\'s'),
]

# Strings known to need double-quote wrapping
APOSTROPHE_STRINGS = [
    "Let's set up a new space for your readers. Start by giving your\nclass an identity.",
    "Deep in the woods, letters love to join\nhands. Let's find the sounds they make\ntogether!.",
    "Deep in the woods, letters love to join\nhands. Let's find the sounds they make\ntogether!",
    "Beat today's speed trial to earn\na 2x Gem Multiplier for 1 hour!",
    "You've identified 500 sounds\ncorrectly this week!",
    "Connect your child's student profile",
    "See mastery, sound progress, and recent quests once your child's account is linked.",
    "When an 'e' sits at the end of a CVC word, it jumps over the consonant to make the vowel long!",
    "Consonants followed by the letter 'L'.",
    "Let')s practice your sounds and build some words! Every game you play makes your brain stronger.",
]


def fix_file(content: str) -> str:
    for old, new in BROKEN_PATTERNS:
        content = content.replace(old, new)

    # Fix any context.tr('... containing unescaped ' in middle - use regex to find and convert
    def fix_tr_single(m):
        inner = m.group(1)
        if "'" in inner or "'" in inner:
            escaped = inner.replace('"', '\\"')
            return f'context.tr("{escaped}")'
        return m.group(0)

    # Match context.tr('...') but broken strings won't match fully - scan manually
    for s in APOSTROPHE_STRINGS:
        sq = f"context.tr('{s}"
        if sq in content:
            esc = s.replace('"', '\\"')
            content = content.replace(sq, f'context.tr("{esc}"')
        # also try with broken apostrophe variants
        sq2 = s.replace("'", "'")
        if f"context.tr('{sq2}" in content:
            esc = s.replace('"', '\\"')
            content = content.replace(f"context.tr('{sq2}", f'context.tr("{esc}"')

    # Generic: lines with context.tr('X'Y - broken by apostrophe
    lines = content.splitlines(keepends=True)
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        if "context.tr('" in line and line.count("'") % 2 == 1:
            # Unterminated - try to merge with next lines until balanced
            merged = line
            j = i + 1
            while j < len(lines) and merged.count("'") % 2 == 1:
                merged += lines[j]
                j += 1
            # Extract content between context.tr(' and last ' before ),
            m = re.search(r"context\.tr\('(.+?)'\s*,?\s*(?:style:|textAlign:|maxLines:|overflow:|\))", merged, re.DOTALL)
            if not m:
                m = re.search(r"context\.tr\('(.+)'", merged, re.DOTALL)
            if m:
                inner = m.group(1)
                esc = inner.replace('\\', '\\\\').replace('"', '\\"')
                fixed = re.sub(
                    r"context\.tr\('.+?'\s*,?",
                    f'context.tr("{esc}"),',
                    merged,
                    count=1,
                    flags=re.DOTALL,
                )
                if fixed != merged:
                    out.append(fixed)
                    i = j
                    continue
        out.append(line)
        i += 1
    content = "".join(out)

    # Fix description: that weren't wrapped
    for s in [
        "Deep in the woods, letters love to join\nhands. Let's find the sounds they make\ntogether!",
        "Deep in the woods, letters love to join\nhands. Let's find the sounds they make\ntogether!.",
    ]:
        content = content.replace(
            f"description: '{s}'",
            f'description: context.tr("{s.replace(chr(34), chr(92)+chr(34))}")',
        )

    # Remove const before context.tr
    content = re.sub(r"\bconst\s+(?=\w+[^;]*context\.tr)", "", content)
    content = re.sub(r"child:\s*const\s+Text\(context\.tr", "child: Text(context.tr", content)

    return content


changed = 0
for f in (ROOT / "lib").rglob("*.dart"):
    orig = f.read_text(encoding="utf-8")
    new = fix_file(orig)
    if new != orig:
        f.write_text(new, encoding="utf-8")
        changed += 1
        print(f.relative_to(ROOT))

print(f"Changed {changed} files")
