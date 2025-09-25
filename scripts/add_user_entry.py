#!/usr/bin/env python3
"""
Inserta/actualiza entrada de usuario en group_vars/<ambiente>.yml
Uso: add_user_entry.py <ambiente> <username> <nombre> <pubkey_path1> [pubkey_path2]
"""
import sys, yaml, pathlib
env, username, fullname, *keys = sys.argv[1:]
gv = pathlib.Path("group_vars")/f"{env}.yml"
data = {}
if gv.exists():
    data = yaml.safe_load(gv.read_text()) or {}
data.setdefault("users", [])
# reemplaza si existe
data["users"] = [u for u in data["users"] if u.get("username") != username]
data["users"].append({
    "username": username,
    "name": fullname,
    "use_ssh_key": True,
    "ssh_keys": [f"{{{{ lookup('file', '{'roles/users/files/public_keys/' + pathlib.Path(k).name}') }}}}" for k in keys],
    "state": "present",
    "sudo": True
})
gv.write_text(yaml.safe_dump(data, sort_keys=False))
print(f"Actualizado {gv}")