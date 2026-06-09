import json, subprocess, sys
from pathlib import Path

def generate_impact_report(plan_file="governance.tfplan"):
    print("=== POLICY GOVERNANCE IMPACT REPORT ===")
    result = subprocess.run(["terraform","show","-json",plan_file], capture_output=True, text=True, cwd="governance")
    if result.returncode != 0:
        print(f"Failed to parse plan: {result.stderr}"); sys.exit(1)
    plan = json.loads(result.stdout)
    changes = [c for c in plan.get("resource_changes",[]) if "no-op" not in c.get("change",{}).get("actions",["no-op"])]
    print(f"Total governance changes: {len(changes)}")
    for c in changes:
        print(f"  [{', '.join(c['change']['actions']).upper()}] {c['type']}.{c['name']}")
    print("=== END IMPACT REPORT ===")

if __name__ == "__main__":
    generate_impact_report(sys.argv[1] if len(sys.argv) > 1 else "governance.tfplan")
