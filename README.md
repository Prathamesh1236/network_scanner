# Intelligent Network Scanner with Automated Deployment

## Overview
**Intelligent Network Scanner with Automated Deployment** is a fully automated network scanning solution that leverages modern DevOps tools to streamline network security assessments. The system dynamically provisions and deploys the network scanner application while providing a Flask-based web interface for real-time scan results and analysis. This project significantly reduces manual intervention while enhancing scalability, consistency, and security.

## System Requirements and Machine Setup
This project requires three machines (using AWS Free Tier):

- **Developer Machine:**  
  Used for writing, testing, and committing code.

- **Jenkins Machine:**  
  Dedicated to running the CI/CD pipeline. This machine builds Docker images, triggers deployments, and orchestrates the overall process.

- **Terraform Machine (Optional):**  
  You can provision AWS infrastructure manually if desired. (In our case, we focus on manual setup for the Developer and Jenkins machines.)

## Security Groups Setup
For simplicity during development, you can use minimal security settings with dedicated security groups named according to their roles:

- **Developer Security Group ("developer"):**
  - **Inbound Rules:**
    - **SSH (Port 22):** Allow from `0.0.0.0/0` (for easy access during development).
    - **Flask (Port 5000):** Allow from `0.0.0.0/0` (to access the web interface).
  - **Outbound Rules:** Allow all traffic (default).

- **Jenkins Security Group ("jenkins"):**
  - **Inbound Rules:**
    - **SSH (Port 22):** Allow from `0.0.0.0/0`.
    - **Jenkins (Port 8080):** Allow from `0.0.0.0/0` (for accessing the Jenkins web interface).
  - **Outbound Rules:** Allow all traffic (default).

*Note: These settings are for development purposes only. For production, restrict inbound access to specific IP addresses.*

## Installation and Setup

### 1. Clone the Repository
Clone the project repository to your local machine:
```bash
git clone https://github.com/yourusername/intelligent-network-scanner.git
cd intelligent-network-scanner
