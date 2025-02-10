pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner'
        DOCKER_REGISTRY = 'prathamesh05'
        IMAGE_TAG = 'latest'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        AWS_CREDENTIALS_ID = 'aws-credentials'
        TERRAFORM_INSTANCE = 'admin@13.235.77.188'  // Terraform instance
    }

    stages {
        stage('Clean Docker Images') {
            steps {
                script {
                    echo "Cleaning up unused Docker images..."
                    sh 'docker image prune -f'
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
                    echo "Connecting to Terraform instance and setting up environment..."
                    sh '''
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                        sudo apt-get update
                        sudo apt-get install -y gnupg
                        wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                        sudo apt-get update
                        sudo apt-get install -y terraform
                    EOF
                    '''
                }
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                script {
                    echo "Cloning Terraform repository..."
                    sh '''
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                        if [ -d "~/network_scanner" ]; then
                            cd ~/network_scanner && git pull
                        else
                            git clone https://github.com/Prathamesh1236/network_scanner.git ~/network_scanner
                        fi
                    EOF
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                script {
                    echo "Initializing and applying Terraform..."
                    sh '''
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                        cd ~/network_scanner/terraform
                        terraform init
                        terraform validate
                        terraform plan -out=tfplan
                        terraform apply -auto-approve tfplan
                    EOF
                    '''
                }
            }
        }

        stage('Fetch EC2 IP') {
            steps {
                script {
                    echo "Fetching EC2 public IP..."
                    EC2_IP = sh(script: '''
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} "terraform output -raw instance_ip"
                    ''', returnStdout: true).trim()
                    echo "EC2 Public IP: ${EC2_IP}"
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

