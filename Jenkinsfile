pipeline {
  agent any
  options { timestamps(); ansiColor('xterm'); buildDiscarder(logRotator(numToKeepStr: '30')) }
  parameters {
    string(name: 'LIMIT', defaultValue: 'asi_hml_docker', description: 'Patrón de inventario (canary por defecto)')
    string(name: 'SERIAL', defaultValue: '1', description: 'Hosts en paralelo')
    booleanParam(name: 'CHECK_MODE', defaultValue: false, description: 'Ansible --check')
    booleanParam(name: 'USE_CA', defaultValue: false, description: 'Distribuir CA SSH')
    text(name: 'EMERGENCY_KEYS', defaultValue: '', description: 'break-glass (.pub, una por línea)')
  }
  environment {
    ROTATION_ID = "${new Date().format('yyyyMMddHHmmss')}"
  }
  stages {
    stage('Prep') {
      steps {
        sh 'ansible --version || true'
        sh 'mkdir -p artifacts'
        writeFile file: 'artifacts/emergency.txt', text: params.EMERGENCY_KEYS
      }
    }
    stage('Rotate + Validate') {
      steps {
        sh """
          ansible-playbook -i inventories/hosts playbooks/site_ssh.yml \
            -l '${params.LIMIT}' ${params.CHECK_MODE ? '--check' : ''} \
            --extra-vars "rotation_id=${env.ROTATION_ID} rotation_serial=${params.SERIAL} emergency_keys='$(tr '\\n' '|' < artifacts/emergency.txt)'" \
          | tee artifacts/rotation_${env.ROTATION_ID}.log
        """
      }
    }
    stage('CA (opcional)') {
      when { expression { return params.USE_CA } }
      steps {
        sh """
          ansible-playbook -i inventories/hosts playbooks/site_ssh.yml \
            -l '${params.LIMIT}' --extra-vars "use_ca=true"
        """
      }
    }
    stage('Reports') {
      steps {
        sh 'cp -a /tmp/ssh_validation_*_$(date +%F).json artifacts/ 2>/dev/null || true'
        archiveArtifacts artifacts: 'artifacts/**', fingerprint: true
      }
    }
  }
  post {
    unsuccessful {
      sh """
        test -f failed_hosts_${env.ROTATION_ID}.txt && \
        ansible-playbook -i inventories/hosts playbooks/ssh_key_rollback.yml \
          --extra-vars "rollback_rotation_id=${env.ROTATION_ID}" -l '${params.LIMIT}' || true
      """
      archiveArtifacts artifacts: "failed_hosts_${env.ROTATION_ID}.txt", fingerprint: true, onlyIfSuccessful: false
    }
  }
}
