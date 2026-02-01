from pathlib import Path

file = Path("start_server.py")

original_code = file.read_text(encoding="utf-8")

fixed_code = original_code.replace("self.logger.info(", "logger.info(")
fixed_code = fixed_code.replace("self.name", "module_name")

# Backup speichern
Path("start_server_backup_before_self_fix.py").write_text(original_code, encoding="utf-8")

# Neue Version schreiben
file.write_text(fixed_code, encoding="utf-8")

print("✅ self.logger und self.name wurden automatisch ersetzt.")
print("🔒 Backup gespeichert unter: start_server_backup_before_self_fix.py")
