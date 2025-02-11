pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'network_scanner'
        DOCKER_REGISTRY = 'prathamesh05'
        IMAGE_TAG = 'latest'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'
        TERRAFORM_INSTANCE = 'admin@13.201.101.108'
        TERRAFORM_REPO = 'https://github.com/Prathamesh1236/network_scanner.git'
        WORK_DIR = '/home/admin/network_scanner'
        ANSIBLE_PLAYBOOK = 'ansible/setup_server.yml'
    }

    stages {
        stage('Clean Docker Images') {
            steps {
                script {
                    sh 'docker image prune -af'
                }
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
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -ex
                    [ -d "${WORK_DIR}/.git" ] && (cd ${WORK_DIR} && git reset --hard && git pull origin master) || (rm -rf ${WORK_DIR} && git clone -b master ${TERRAFORM_REPO} ${WORK_DIR})
EOF
                    """
                }
            }
        }

        stage('Terraform Destroy & Apply') {
            steps {
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} <<EOF
                    set -ex
                    cd ${WORK_DIR}/terraform
                    terraform init
                    terraform destroy -auto-approve  # First, destroy existing resources
                    terraform validate
                    terraform plan -out=tfplan
                    terraform apply -auto-approve    # Recreate resources
EOF
                    """
                }
            }
        }

        stage('Fetch Terraform Instance IP') {
            steps {
                script {
                    // Fetch only the raw instance IP from Terraform output
                    env.INSTANCE_IP = sh(script: """
                        ssh -o StrictHostKeyChecking=no ${TERRAFORM_INSTANCE} "cd ${WORK_DIR}/terraform && terraform output -raw instance_ip"
                    """, returnStdout: true).trim()

                    // Debugging: Print the fetched IP
                    echo "Fetched Terraform Instance IP: '${env.INSTANCE_IP}'"

                    // Fail the pipeline if the IP is empty
                    if (!env.INSTANCE_IP?.trim()) {
                        error("Failed to fetch Terraform instance IP. It is empty or undefined.")
                    }
                }
            }
        }

        stage('Generate Ansible Inventory') {
            steps {
                script {
                    // Generate the Ansible inventory file
                    sh """
                        echo "[webserver]" > ansible/inventory.ini
                        echo "${env.INSTANCE_IP} ansible_user=admin" >> ansible/inventory.ini
                    """

                    // Debugging: Print the inventory file content
                    sh "cat ansible/inventory.ini"
                }
            }
        }

        stage('Verify Playbook Exists') {
            steps {
                script {
                    // Verify the Ansible playbook exists
                    sh """
                        if [ ! -f ${ANSIBLE_PLAYBOOK} ]; then
                            echo "ERROR: Playbook ${ANSIBLE_PLAYBOOK} not found!"
                            exit 1
                        fi
                        ls -l ${ANSIBLE_PLAYBOOK}
                    """
                }
            }
        }

        stage('Run Ansible Playbook from Jenkins') {
            steps {
                script {
                    // Run the Ansible playbook
                    sh "ansible-playbook -i ansible/inventory.ini ${ANSIBLE_PLAYBOOK}"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}
