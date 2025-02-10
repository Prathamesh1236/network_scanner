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
        INVENTORY_FILE = 'ansible/inventory.ini'
    }

    stages {
        stage('Clean Docker Images') {
            steps {
                sh 'docker image prune -af'
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
                sh """
                ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                set -e
                [ -d "${WORK_DIR}/.git" ] && (cd ${WORK_DIR} && git reset --hard && git pull origin master) || git clone -b master ${TERRAFORM_REPO} ${WORK_DIR}
EOF
                """
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    def terraformChanges = sh(script: """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    cd ${WORK_DIR}/terraform
                    terraform init
                    terraform validate
                    terraform plan -detailed-exitcode -out=tfplan || [ $? -eq 2 ]
EOF
                    """, returnStatus: true)

                    if (terraformChanges == 2) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                        set -e
                        cd ${WORK_DIR}/terraform
                        terraform apply -auto-approve
EOF
                        """
                    } else {
                        echo "No Terraform changes detected, skipping apply."
                    }
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

        stage('Setup Ansible on Terraform Instance') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                set -e
                sudo apt update && sudo apt install -y ansible
EOF
                """
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    writeFile file: "${INVENTORY_FILE}", text: """
                    [servers]
                    terraform_instance ansible_host=${env.INSTANCE_IP} ansible_user=admin ansible_ssh_private_key_file=~/.ssh/id_rsa
                    """
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh "ansible-playbook -i ${INVENTORY_FILE} ${ANSIBLE_PLAYBOOK}"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}


