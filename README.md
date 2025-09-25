# ssh_rotate

Repositorio Ansible para rotar claves y gestionar cuentas SSH de forma segura en entornos Linux.

## Características
- Gestión declarativa de usuarios y grupos mediante `group_vars/*`.
- Distribución de claves públicas (ED25519 por defecto) a través del rol `users`.
- Playbook de auditoría y limpieza de cuentas (`playbooks/remove_users.yml`).
- Pipeline Jenkins opcional para orquestar cargas de claves.

## Requisitos
- Ansible >= 2.13
- Python 3.8+
- Acceso SSH hacia los hosts gestionados

Instalá las colecciones necesarias con:

```bash
ansible-galaxy collection install -p collections -r requirements.yml
```

## Configuración Inicial
1. Copiá `inventory/hosts.ini.example` a `inventory/hosts.ini` y reemplazá los hosts con tus servidores.
2. Ajustá los valores de `group_vars/*.yml` según tus políticas (usuarios, grupos, LDAP, etc.).
   - Mantené los archivos reales fuera de git.
   - Para secretos usa `ansible-vault` (`ansible-vault create group_vars/prd.vault.yml`).
3. Define un usuario de despliegue y clave privada en `ansible.cfg` (o mediante `ANSIBLE_CONFIG`).
4. Opcional: desmontá/clona el Jenkinsfile en tu pipeline CI y proveé credenciales/secretos mediante el mecanismo seguro de tu plataforma.

## Ejecución
Aplicá la configuración de usuarios:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/users.yml
```

Para auditar o remover cuentas no deseadas:

```bash
MODE=list ansible-playbook -i inventory/hosts.ini playbooks/remove_users.yml
# Cambiá a MODE=remove y define users_to_remove desde extra vars cuando quieras eliminar.
```

## Buenas Prácticas de Seguridad
- No subas inventarios reales ni claves públicas. Usá los archivos `*.example` y el `.gitignore` incluido.
- Usa claves ED25519 con passphrase fuerte; únicamente agrega RSA legado si un sistema lo exige.
- Protegé credenciales y variables sensibles con `ansible-vault` o un gestor de secretos externo.
- Rotá claves periódicamente (`key_rotation_months` en `group_vars/all.yml`).
- Conservá evidencias de cambios en `reports/` sólo de forma local; el repositorio ignora archivos generados.
- Revisa el pipeline CI para que elimine artefactos temporales y no archive claves.

## Estructura del Proyecto
- `ansible.cfg`: configuración por defecto; ajustá `remote_user`, `private_key_file`, etc.
- `inventory/`: inventarios y guías (`README.md`, `hosts.ini.example`).
- `group_vars/`: variables por ambiente y plantillas de políticas.
- `playbooks/`: playbooks de gestión y limpieza.
- `roles/`: roles Ansible (`users`, `ssh_key_manager`).
- `collections/`: carpeta vacía con README; las colecciones se instalan vía `ansible-galaxy`.
- `reports/`: se genera localmente, está ignorado por git.
- `scripts/`: utilidades (`add_user_entry.py`, `validate_pubkey.sh`).

## Contribuciones
1. Crea un branch desde `main`.
2. Ejecuta los playbooks en modo `--check` antes de abrir PR.
3. Incluye ejemplos anonimizados cuando documentes cambios.
4. No adjuntes secretos ni inventarios reales en issues o PRs.

## Licencia
Define la licencia que prefieras para uso público (MIT, Apache-2.0, etc.) antes de publicar.
