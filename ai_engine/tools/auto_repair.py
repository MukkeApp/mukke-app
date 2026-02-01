import os
from ai_engine.memory.code_patterns import save_learned_fix

def suggest_fix(error_log, code_snippet):
    # Dummy-Beispielregel
    if "NoneType" in error_log and "has no attribute" in error_log:
        return code_snippet.replace(".", "?.") + " ?? 'Fehler'"
    return None

def apply_fix(original_code, fix_code, file_path):
    if os.getenv("AUTO_REPAIR_CONFIRM", "false").lower() == "true":
        print("\n⚠️  Jarviz hat einen möglichen Fix gefunden:")
        print("Vorher:\n", original_code)
        print("Vorschlag:\n", fix_code)
        confirm = input("💡 Fix übernehmen? (j/n): ").strip().lower()
        if confirm != "j":
            print("❌ Fix abgelehnt.")
            return False
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(fix_code)
    print("✅ Fix übernommen.")
    save_learned_fix(original_code, fix_code)
    return True
