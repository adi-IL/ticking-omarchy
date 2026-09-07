#!/usr/bin/env python3
import os
import sys
import re

print("=== Checking QML Structure and Integrity ===")

repo_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
qml_files = []

for root, _, files in os.walk(repo_dir):
    if ".git" in root or ".venv" in root:
        continue
    for f in files:
        if f.endswith(".qml"):
            qml_files.append(os.path.join(root, f))

print(f"Found {len(qml_files)} QML files to analyze.")

prohibited_patterns = [
    (re.compile(r"org\.kde\.plasma"), "Prohibited KDE Plasma import"),
    (re.compile(r"org\.kde\.kirigami"), "Prohibited Kirigami import"),
    (re.compile(r"Plasmoid\."), "Prohibited Plasmoid API call"),
    (re.compile(r"Kirigami\."), "Prohibited Kirigami API call"),
    (re.compile(r"i18nc?\("), "Prohibited KDE i18n call"),
]

errors = 0

for path in qml_files:
    rel_path = os.path.relpath(path, repo_dir)
    with open(path, "r", encoding="utf-8") as file:
        content = file.read()

    # Check balanced braces
    open_braces = content.count("{")
    close_braces = content.count("}")
    if open_braces != close_braces:
        print(f"❌ {rel_path}: Unbalanced braces ({open_braces} open vs {close_braces} close)")
        errors += 1

    # Check balanced parentheses
    open_parens = content.count("(")
    close_parens = content.count(")")
    if open_parens != close_parens:
        print(f"❌ {rel_path}: Unbalanced parentheses ({open_parens} open vs {close_parens} close)")
        errors += 1

    # Check prohibited patterns
    for pattern, desc in prohibited_patterns:
        matches = pattern.findall(content)
        if matches:
            print(f"❌ {rel_path}: {desc} ({len(matches)} occurrences)")
            errors += 1

    if errors == 0:
        print(f"✔ {rel_path}: Syntax clean, zero KDE legacy dependencies.")

if errors > 0:
    print(f"\nFailed with {errors} errors.")
    sys.exit(1)
else:
    print("\n=== All QML Structure Checks Passed ===")
