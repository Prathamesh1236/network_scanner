pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner'
        DOCKER_REGISTRY = 'prathamesh05'
        IMAGE_TAG = 'latest'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        AWS_CREDENTIALS_ID = 'aws-credentials'
        TERRAFORM_INSTANCE = 'admin@13.235.77.188'  // Terraform server
        TERRAFORM_REPO = 'https://github.com/Prathamesh1236/network_scanner.git'
        WORK_DIR = '~/network_scanner'
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
                    docker.withRegistry('', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Setup Terraform Instance') {
            steps {
                script {
                    echo "Setting up Terraform on remote instance..."
                    sh """
                    ssh -o StrictHostKeyChecking=no \${TERRAFORM_INSTANCE} <<'EOF'
                        set -e
                        sudo apt-get update
                        sudo apt-get install -y gnupg software-properties-common curl
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                        sudo apt-get update
                        sudo apt-get install -y terraform
                    EOF
                    """
                }
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                script {
                    echo "Cloning Terraform repository..."
                    sh """
                    ssh -o StrictHostKeyChecking=no \${TERRAFORM_INSTANCE} <<'EOF'
                        set -e
                        if [ -d "\${WORK_DIR}" ]; then
                            cd \${WORK_DIR} && git reset --hard && git pull
                        else
                            git clone \${TERRAFORM_REPO} \${WORK_DIR}
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
                    ssh -o StrictHostKeyChecking=no \${TERRAFORM_INSTANCE} <<'EOF'
                        set -e
                        cd \${WORK_DIR}/terraform
                        terraform init
                        terraform validate
                        terraform plan -out=tfplan
                        terraform apply -auto-approve
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


