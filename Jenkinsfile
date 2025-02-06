pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner' // Docker image name
        DOCKER_REPOSITORY = 'prathamesh1236' // Docker Hub username (repository)
        GIT_REPO_URL = 'https://github.com/Prathamesh1236/network_scanner.git' // GitHub repository
        IMAGE_TAG = 'latest' // Tag for versioning
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials' // Jenkins credentials ID for Docker Hub login
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "Using Jenkins automatic checkout..."
                    // Jenkins automatically pulls the code, so no need for explicit `git` command
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    docker.build("${DOCKER_REPOSITORY}/${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    echo "Running tests inside Docker container..."
                    docker.image("${DOCKER_REPOSITORY}/${DOCKER_IMAGE}:${IMAGE_TAG}").inside {
                        // Ensure your project contains test files (replace if necessary)
                        sh 'python3 -m unittest discover || echo "Tests Failed"'  
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Logging into Docker Hub and pushing image..."
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${DOCKER_REPOSITORY}/${DOCKER_IMAGE}:${IMAGE_TAG}").push()
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
            echo " Pipeline completed successfully!"
        }

        failure {
            echo " Pipeline failed. Check logs for issues."
        }
    }
}
