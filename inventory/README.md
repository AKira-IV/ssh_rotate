# Inventario de Ansible

1. Copiá `hosts.ini.example` a `hosts.ini` y reemplazá los hosts por los de tu entorno.
2. El archivo `hosts.ini` real no debe versionarse; el `.gitignore` ya lo ignora.
3. Si necesitás compartir un inventario de referencia, generá un archivo con datos anonimizados y nombralo `hosts.<entorno>.example.ini`.
4. Considerá usar `ansible-vault` para variables sensibles en `group_vars` o `host_vars`.
