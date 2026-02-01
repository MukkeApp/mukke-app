# Ergänzen – um Fixes zu speichern
def save_learned_fix(before, after):
    path = Path("ai_engine/memory/learned_fixes.json")
    fixes = {}
    if path.exists():
        with open(path, "r", encoding="utf-8") as f:
            fixes = json.load(f)
    fixes[before] = after
    with open(path, "w", encoding="utf-8") as f:
        json.dump(fixes, f, indent=2)
