# Intelligent Network Scanner with Automated Deployment

## Developer Machine Setup

**Overview:**  
The Developer machine is used solely for code development, testing, and committing changes to the project repository. This machine is provisioned on AWS as a Free Tier t2.micro instance running Debian. It is configured with a dedicated security group (named "developer") that allows inbound SSH (for remote access via PuTTY) and, if necessary, Flask (port 5000) for accessing the web interface.

### Instance Details
- **Instance Name:** developer
- **OS Image:** Debian (Free Tier eligible)
- **Instance Type:** t2.micro
- **Key Pair:** `developer_key` (RSA key generated using `ssh-keygen`; store as a PEM file or convert to .ppk for PuTTY)

### Security Group Configuration for Developer Machine ("developer")
Since the Developer machine is used for code commits and remote management, the following minimal security settings are recommended for development purposes:
- **Inbound Rules:**
  - **SSH (Port 22):** Allow TCP from `0.0.0.0/0` (for ease of access via PuTTY; for enhanced security, restrict to your IP range).
  - **Flask (Port 5000):** Allow TCP from `0.0.0.0/0` if you need external access to the web interface.
- **Outbound Rules:**
  - Allow all outbound traffic (default).

### Steps to Set Up Your Developer Machine

#### 1. Launch the EC2 Instance
- **Log in to the AWS Management Console** and navigate to the **EC2 Dashboard**.
- Click **Launch Instance**.
- **Select the AMI:** Choose a Debian AMI (ensuring Free Tier eligibility).
- **Choose Instance Type:** Select **t2.micro**.
- **Name Your Instance:** Set the name to **developer**.
- **Key Pair:** Create or select a key pair named `developer_key`. Download and store the private key securely.
- **Assign Security Group:** Associate this instance with your "developer" security group.
- Click **Launch**.

#### 2. Generate SSH Keys (if not already done)
If you haven't generated your RSA key pair:
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"


