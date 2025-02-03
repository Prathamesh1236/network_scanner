pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner' // Docker image name
        DOCKER_REGISTRY = 'Prathamesh1236' // Docker Hub username
        GIT_REPO_URL = 'https://github.com/Prathamesh1236/network_scanner.git' // GitHub repository URL
        IMAGE_TAG = 'latest' // Image tag for consistency (e.g., 'latest', 'v1.0')
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials' // Jenkins credentials ID for Docker Hub login
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Checkout the code from the GitHub repository
                    echo "Cloning GitHub repository..."
                    git branch: 'master', url: "${GIT_REPO_URL}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image from the Dockerfile in the repository
                    echo "Building Docker image..."
                    docker.build("${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    // Run unit tests on the Docker container to verify the image works
                    echo "Testing Docker image..."
                    docker.image("${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${IMAGE_TAG}").inside {
                        // Run your unit tests here (using unittest as an example)
                        sh 'python3 -m unittest discover' // Replace this command with your actual test command
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Log in to Docker Hub and push the Docker image
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
            // Clean up the workspace after the pipeline run
            echo "Cleaning up workspace..."
            cleanWs()  // Removes all files from the workspace
        }

        success {
            echo "Pipeline completed successfully!"
        }

        failure {
            echo "Pipeline failed."
        }
    }
}

}

