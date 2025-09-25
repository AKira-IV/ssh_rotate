# Collections Directory

Este repositorio no incluye colecciones de Ansible vendorizadas.
Instalá las dependencias ejecutando:

```bash
ansible-galaxy collection install -p collections -r requirements.yml
```

Las colecciones instaladas quedarán bajo `collections/ansible_collections/`, el cual está excluido por `.gitignore`.
