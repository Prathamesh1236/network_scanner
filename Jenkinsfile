pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner'
        DOCKER_REGISTRY = 'prathamesh05'
        IMAGE_TAG = 'latest'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        AWS_CREDENTIALS_ID = 'aws-credentials'
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

        stage('Terraform Init & Apply with Debugging') {
            steps {
                script {
                    echo "Initializing and applying Terraform with debugging..."
                    sh '''
                    set -e  # Stop execution if any command fails
                    export TF_LOG=DEBUG  # Enable detailed logging
                    cd terraform
                    echo "Initializing Terraform..."
                    terraform init 2>&1 | tee terraform-init.log
                    
                    echo "Validating Terraform configuration..."
                    terraform validate 2>&1 | tee terraform-validate.log

                    echo "Planning Terraform changes..."
                    terraform plan -out=tfplan 2>&1 | tee terraform-plan.log

                    echo "Applying Terraform changes..."
                    terraform apply -auto-approve -input=false tfplan 2>&1 | tee terraform-apply.log

                    echo "Displaying Terraform state..."
                    terraform show 2>&1 | tee terraform-show.log

                    echo "Checking Terraform output values..."
                    terraform output 2>&1 | tee terraform-output.log
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

