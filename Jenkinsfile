pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner' // Docker image name
        DOCKER_REGISTRY = 'Prathamesh1236' // Docker Hub username
        GIT_REPO_URL = 'https://github.com/Prathamesh1236/network_scanner.git' // GitHub repository URL
        IMAGE_TAG = 'latest' // Image tag for consistency
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials' // Jenkins credentials ID for Docker Hub login
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "Cloning GitHub repository..."
                    git branch: 'master', url: "${GIT_REPO_URL}"
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
            echo "Pipeline failed."
        }
    }
}

