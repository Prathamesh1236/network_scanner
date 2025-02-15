  # Intelligent Network Scanner with Automated Deployment

## Overview
**Intelligent Network Scanner with Automated Deployment** is a fully automated network scanning solution that leverages modern DevOps tools to streamline network security assessments. The system dynamically provisions and deploys the network scanner application while providing a Flask-based web interface for real-time scan results and analysis.

## System Requirements and Machine Setup
This project requires three machines (using AWS Free Tier):

- **Developer Machine:**  
  Used for writing, testing, and committing code.

- **Jenkins Machine:**  
  Runs the CI/CD pipeline. It builds Docker images, triggers deployments, and orchestrates the process.

- **Terraform Machine:**  
  (For manual setup, you can opt not to use Terraform and configure AWS instances manually if preferred.)  

For our minimal development setup, we focus on the Developer and Jenkins machines.

## Minimal Security Group Setup (Development Environment)
For ease of use during development, you can create a security group with minimal restrictions. **Note:** This setup is for testing only.

1. **Log in to the AWS Management Console** and navigate to the EC2 Dashboard > Security Groups.
2. **Create a new security group** with the following settings:
   - **Name:** `minimal-dev-sg`
   - **Description:** "Minimal security group for development/testing purposes."
   - **Inbound Rules:**
     - **SSH (Port 22):**  
       - Protocol: TCP  
       - Port Range: 22  
       - Source: `0.0.0.0/0`
     - **Jenkins (Port 8080):**  
       - Protocol: TCP  
       - Port Range: 8080  
       - Source: `0.0.0.0/0`
     - **Flask (Port 5000):**  
       - Protocol: TCP  
       - Port Range: 5000  
       - Source: `0.0.0.0/0`
   - **Outbound Rules:** Allow all traffic (default).
3. **Assign this security group** to your Jenkins and Developer EC2 instances.

## Installation and Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/intelligent-network-scanner.git
cd intelligent-network-scanner
