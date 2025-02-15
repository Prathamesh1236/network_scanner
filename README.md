# Intelligent Network Scanner with Automated Deployment

## Overview
**Intelligent Network Scanner with Automated Deployment** is a fully automated network scanning solution that leverages modern DevOps tools to streamline network security assessments. The system dynamically provisions and deploys the network scanner application while providing a Flask-based web interface for real-time scan results and analysis. This approach significantly reduces manual intervention and enhances scalability, consistency, and security.

## System Requirements and Machine Setup
This project requires three distinct machines (using AWS Free Tier):

- **Developer Machine:**  
  Used for writing, testing, and committing code. This machine will primarily be used to push changes to GitHub.
  
- **Jenkins Machine:**  
  Dedicated to running the CI/CD pipeline. This machine builds Docker images, triggers deployments, and orchestrates the overall automation process.
  
- **Terraform Machine:**  
  (Optional for manual setups) Typically used for provisioning and managing AWS infrastructure. In this guide, the focus is on manually setting up the Developer and Jenkins machines.

## Security Groups Setup

For ease of development, we use minimal security settings. **Note:** This configuration is intended for development/testing only. In production, you should restrict inbound traffic to known IP ranges.

### Developer Security Group ("developer")
- **Inbound Rules:**
  - **SSH (Port 22):** Allow TCP from `0.0.0.0/0` (to connect using PuTTY or another SSH client).
  - **Flask (Port 5000):** Allow TCP from `0.0.0.0/0` (to access the web interface).
- **Outbound Rules:**
  - Allow all outbound traffic (default).

### Jenkins Security Group ("jenkins")
- **Inbound Rules:**
  - **SSH (Port 22):** Allow TCP from `0.0.0.0/0` (or restrict to your IP range for increased security).
  - **Jenkins (Port 8080):** Allow TCP from `0.0.0.0/0` (to access the Jenkins web interface).
- **Outbound Rules:**
  - Allow all outbound traffic (default).

## Installation and Setup

### 1. Clone the Repository
Clone the project repository to your local machine:
```bash
git clone https://github.com/yourusername/intelligent-network-scanner.git
cd intelligent-network-scanner

