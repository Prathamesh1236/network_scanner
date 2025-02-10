pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner'
        DOCKER_REGISTRY = 'prathamesh05'
        IMAGE_TAG = 'latest'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        TERRAFORM_INSTANCE = 'admin@3.110.183.212'
        TERRAFORM_REPO = 'https://github.com/Prathamesh1236/network_scanner.git'
        WORK_DIR = '/home/admin/network_scanner'
        ANSIBLE_PLAYBOOK = 'setup_server.yml'
    }

    stages {
        stage('Clean Docker Images') {
            steps {
                script {
                    sh 'docker image prune -af'
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}")
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        image.push()
                    }
                }
            }
        }

        stage('Clone or Update Terraform Repo') {
            steps {
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    [ -d "${WORK_DIR}/.git" ] && (cd ${WORK_DIR} && git reset --hard && git pull origin master) || (rm -rf ${WORK_DIR} && git clone -b master ${TERRAFORM_REPO} ${WORK_DIR})
EOF
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    cd ${WORK_DIR}/terraform
                    terraform init && terraform validate && terraform plan -out=tfplan && terraform apply -auto-approve
EOF
                    """
                }
            }
        }

        stage('Fetch Terraform Instance IP') {
            steps {
                script {
                    env.INSTANCE_IP = sh(script: """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    cd ${WORK_DIR}/terraform
                    terraform output -raw instance_ip
EOF
                    """, returnStdout: true).trim()
                    echo "Terraform-created instance IP: ${env.INSTANCE_IP}"
                }
            }
        }

        stage('Setup Ansible on Jenkins') {
            steps {
                script {
                    sh """
                    sudo apt update && sudo apt install -y ansible
                    """
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    sh """
                    mkdir -p ansible
                    echo "[servers]
                    terraform_instance ansible_host=${env.INSTANCE_IP} ansible_user=admin ansible_ssh_private_key_file=~/.ssh/id_rsa" > ansible/inventory.ini
                    """
                }
            }
        }

        stage('Run Ansible Playbook from Jenkins') {
            steps {
                script {
                    sh """
                    ansible-playbook -i ansible/inventory.ini ${ANSIBLE_PLAYBOOK}
                    """
                }
            }
        }
    }

    post {
        /* always {
             cleanWs()  // Disabled for debugging, uncomment if needed
        }
        */
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}


