pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
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
                    docker.build("prathamesh05/network_scanner:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Pushing Docker image to Docker Hub..."
                    docker.withRegistry('', DOCKER_CREDENTIALS_ID) {
                        docker.image("prathamesh05/network_scanner:latest").push()
                    }
                }
            }
        }

        stage('Clone Terraform Repo') {
            steps {
                script {
                    echo "Cloning Terraform repository..."
                    sh """
                    ssh -o StrictHostKeyChecking=no admin@13.235.77.188 <<'EOF'
                        if [ -d "~/network_scanner" ]; then
                            cd ~/network_scanner && git pull
                        else
                            git clone https://github.com/Prathamesh1236/network_scanner.git ~/network_scanner
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
                    ssh -o StrictHostKeyChecking=no admin@13.235.77.188 <<'EOF'
                        cd ~/network_scanner/terraform
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


