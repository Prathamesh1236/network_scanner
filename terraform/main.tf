pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner'  // Docker image name
        DOCKER_REGISTRY = 'prathamesh05'  // Docker Hub username
        IMAGE_TAG = 'latest'              // Image tag
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'  // Jenkins credentials ID for Docker Hub login
        AWS_CREDENTIALS_ID = 'aws-credentials'  // Jenkins AWS credentials ID
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

        stage('Terraform Init & Apply') {
            steps {
                script {
                    echo "Initializing and applying Terraform..."
                    sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Fetch EC2 IP') {
            steps {
                script {
                    echo "Fetching EC2 public IP..."
                    EC2_IP = sh(script: "terraform output -raw instance_ip", returnStdout: true).trim()
                    echo "EC2 Public IP: ${EC2_IP}"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                script {
                    echo "Executing Ansible Playbook..."
                    sh '''
                    cd ansible
                    ansible-playbook -i "${EC2_IP}," --private-key ~/webserver1_key.pem playbook.yml
                    '''
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

