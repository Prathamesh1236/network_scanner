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
        ANSIBLE_PLAYBOOK = 'setup_server.yml'  // Updated Ansible playbook name
    }

    stages {
        stage('Clean Docker Images') {
            steps {
                script {
                    echo "Cleaning up unused Docker images..."
                    sh 'docker image prune -af'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    docker.build("${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub..."
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        docker.image("${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Clone or Update Terraform Repo') {
            steps {
                script {
                    echo "Cloning or updating Terraform repository on remote server..."
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    if [ -d "${WORK_DIR}/.git" ]; then
                        echo "Repository already exists. Pulling latest changes..."
                        cd ${WORK_DIR}
                        git reset --hard
                        git pull origin master
                    else
                        echo "Cloning repository..."
                        rm -rf ${WORK_DIR}
                        git clone -b master ${TERRAFORM_REPO} ${WORK_DIR}
                    fi
EOF
                    """
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                script {
                    echo "Initializing and applying Terraform..."
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    cd ${WORK_DIR}/terraform
                    terraform init
                    terraform validate
                    terraform plan -out=tfplan
                    terraform apply -auto-approve
EOF
                    """
                }
            }
        }

        stage('Fetch Terraform Instance IP') {
            steps {
                script {
                    echo "Fetching the instance IP from Terraform..."
                    def instanceIP = sh(script: """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    cd ${WORK_DIR}/terraform
                    terraform output -raw instance_ip
EOF
                    """, returnStdout: true).trim()

                    echo "Terraform-created instance IP: ${instanceIP}"
                    env.INSTANCE_IP = instanceIP  // Store IP for Ansible use
                }
            }
        }

        stage('Setup Ansible on Terraform Instance') {
            steps {
                script {
                    echo "Installing Ansible on the Terraform instance..."
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    sudo apt update
                    sudo apt install -y ansible
EOF
                    """
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    echo "Running Ansible playbook..."
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -e
                    cd ${WORK_DIR}/ansible
                    ansible-playbook -i inventory ${ANSIBLE_PLAYBOOK}
EOF
                    """
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
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



