import re, sys
from pathlib import Path

errors = []

for tf_file in Path("governance").rglob("*.tf"):
    content = tf_file.read_text(encoding="utf-8")
    if "policy_rule_json" in content:
        if '"if"' not in content and "'if'" not in content:
            errors.append(f"{tf_file}: policy_rule_json missing 'if' block")

if errors:
    print(f"Policy validation FAILED -- {len(errors)} error(s):")
    for e in errors: print(f"  ERROR: {e}")
    sys.exit(1)
else:
    print("Policy JSON validation PASSED")
