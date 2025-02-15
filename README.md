# Intelligent Network Scanner with Automated Deployment

## Overview
**Intelligent Network Scanner with Automated Deployment** is a fully automated network scanning solution that leverages modern DevOps tools to streamline network security assessments. This document details the setup of the Developer machine—the platform where developers write, test, and commit code to the repository.

## Developer Machine Setup
The Developer machine is intended solely for code development and version control. Its primary purpose is to allow developers to work on the project and push changes to GitHub.

### Prerequisites
- A machine (local or cloud-based) with a stable Internet connection.
- Git installed (version 2.0 or above).
- SSH keys generated using `ssh-keygen` for secure, passwordless authentication with GitHub.

### EC2 Instance Details for Developer Machine
For this project, the Developer machine is configured as follows:
- **Instance Name:** developer
- **OS Image:** Debian
- **Instance Type:** t2.micro (AWS Free Tier eligible)
- **Key Pair:** Generate an RSA key pair named `developer_key` (stored as a .ppk file for Windows users or as the default PEM file for Linux/Mac). **Be sure to store the key in a safe place.**

### Security Group Configuration for Developer Machine
Since the Developer machine is used solely for code commits (and not for remote SSH administration), minimal security settings are applied:
- **Inbound Rules:**  
  - No inbound rules are required.
- **Outbound Rules:**  
  - Allow all outbound traffic (default).

### Steps to Set Up Your Developer Machine

