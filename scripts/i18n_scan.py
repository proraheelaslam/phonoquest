import re
from pathlib import Path

base = Path("lib/features")
dirs = [
    "auth/presentation",
    "signup/presentation",
    "dashboard/presentation",
    "settings/presentation",
    "subscription/presentation",
    "quiz/presentation",
    "rewards/presentation",
    "payment/presentation",
    "progress/presentation",
    "notifications/presentation",
    "home/presentation",
]
files = []
for d in dirs:
    p = base / d
    if p.exists():
        files.extend(p.rglob("*.dart"))
files.extend(Path("lib/features/journey").glob("*.dart"))

skip_files = {
    "language.dart",
    "account_details.dart",
    "sound_screen.dart",
    "registration_validators.dart",
    "settings_navigation_helper.dart",
    "module_ui_helper.dart",
    "parent_link_child_helper.dart",
}

for f in sorted(set(files)):
    if f.name in skip_files:
        continue
    text = f.read_text(encoding="utf-8")
    if "context.t." in text and text.count("context.t.") > 8 and "context.tr(" not in text:
        continue
    count = len(re.findall(r"Text\(\s*['\"]", text))
    tr_count = text.count("context.tr(")
    if count > 0 or tr_count > 0:
        print(f"{f}: Text literals~{count}, tr={tr_count}")
