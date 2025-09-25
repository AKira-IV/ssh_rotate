// Jenkinsfile — Pipeline from SCM 
pipeline {
  agent { label 'ansible-node' }
  options { timestamps() }

  /************ PARÁMETROS ************/
  parameters {
    string(name: 'USERNAME',  description: 'usuario unix (p.e. usuario.demo)')
    string(name: 'FULLNAME',  description: 'Nombre y Apellido (Mayus Iniciales)')

    // "Checklist" de ambientes con booleans
    booleanParam(name: 'ENV_DEV', defaultValue: false, description: 'Deploy a DEV')
    booleanParam(name: 'ENV_QA',  defaultValue: false, description: 'Deploy a QA')
    booleanParam(name: 'ENV_HML', defaultValue: true,  description: 'Deploy a HML')
    booleanParam(name: 'ENV_PRD', defaultValue: false, description: 'Deploy a PRD')

    booleanParam(name: 'LEGACY_RSA', defaultValue: false, description: '¿Agregar RSA (legacy)?')

    // Subida de archivos .pub (necesita plugin File Parameter)
    file(name: 'PUB_ED25519_FILE', description: 'Subir archivo .pub ED25519 (opcional)')
    file(name: 'PUB_RSA_FILE',     description: 'Subir archivo .pub RSA (opcional, si LEGACY)')

    // Fallback pegando el contenido .pub
    text(name: 'PUB_ED25519', defaultValue: '', description: 'Pegar .pub ED25519 si no subís archivo')
    text(name: 'PUB_RSA',     defaultValue: '', description: 'Pegar .pub RSA si no subís archivo')

    // Seguridad de ejecución
    booleanParam(name: 'PLAN_ONLY', defaultValue: true,  description: 'Solo plan (check+diff), no aplica cambios')
    booleanParam(name: 'APPLY_NOW', defaultValue: false, description: 'Aplicar cambios (post-merge, en main)')
  }

  /************ VARIABLES ************/
  environment {
    GIT_EMAIL      = 'cicd@example.org'
    GIT_NAME       = 'CI Jenkins'
    ANSIBLE_CONFIG = "${WORKSPACE}/ansible.cfg"
    PUBKEY_DIR     = "roles/users/files/public_keys"
    INVENTORY_PATH = "inventory/hosts.ini"   // <-- ajusta si tu inventario está en otro path
  }

  /************ STAGES ************/
  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Resolver ambientes') {
      steps {
        script {
          def envs = []
          if (params.ENV_DEV) envs << 'dev'
          if (params.ENV_QA)  envs << 'qa'
          if (params.ENV_HML) envs << 'hml'
          if (params.ENV_PRD) envs << 'prd'
          if (envs.isEmpty()) error('Debes seleccionar al menos un ambiente.')
          env.ENVIRONMENTS = envs.join(',')
          echo "Ambientes seleccionados: ${env.ENVIRONMENTS}"
        }
      }
    }

    stage('Preparar claves') {
      steps {
        sh '''#!/usr/bin/env bash
set -euo pipefail
mkdir -p "$PUBKEY_DIR"

have_file()   { [[ -n "${1:-}" && -f "$1" ]]; }
sanitize()    { tr -d '\\r' | sed -E 's/[[:space:]]+$//' ; }
oneline()     { [[ $(wc -l < "$1") -eq 1 ]]; }

ED_DST="$PUBKEY_DIR/${USERNAME}.ed25519.pub"
RSA_DST="$PUBKEY_DIR/${USERNAME}.rsa.pub"

# --- ED25519 (obligatoria) ---
if have_file "${PUB_ED25519_FILE:-}"; then
  cp -f "${PUB_ED25519_FILE}" "$ED_DST"
elif [[ -n "${PUB_ED25519:-}" ]]; then
  printf "%s\\n" "$PUB_ED25519" | sanitize > "$ED_DST"
else
  echo "ERROR: Debes proporcionar ED25519 por archivo o texto." >&2
  exit 1
fi
[[ -s "$ED_DST" ]] || { echo "ED25519 vacía"; exit 1; }
oneline "$ED_DST" || { echo "ED25519 debe ser una sola línea"; exit 1; }
grep -q '^ssh-ed25519 ' "$ED_DST" || { echo "ED25519 inválida (falta prefijo ssh-ed25519)"; exit 1; }
./scripts/validate_pubkey.sh "$ED_DST"

# --- RSA (opcional si LEGACY) ---
if [[ "${LEGACY_RSA}" == "true" ]]; then
  if have_file "${PUB_RSA_FILE:-}"; then
    cp -f "${PUB_RSA_FILE}" "$RSA_DST"
  elif [[ -n "${PUB_RSA:-}" ]]; then
    printf "%s\\n" "$PUB_RSA"_
