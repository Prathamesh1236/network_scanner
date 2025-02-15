# Intelligent Network Scanner with Automated Deployment

## Overview
**Intelligent Network Scanner with Automated Deployment** is a fully automated network scanning solution that leverages modern DevOps tools to streamline network security assessments. The system dynamically provisions and deploys the network scanner application while providing a Flask-based web interface for real-time scan results and analysis. This project significantly reduces manual intervention and enhances scalability, consistency, and security.

## Developer Machine Setup

### Instance Details
- **Instance Name:** developer  
- **OS Image:** Debian (Free Tier eligible)  
- **Instance Type:** t2.micro  
- **Key Pair:** `developer_key` (generated during instance creation, stored as `.pem` file)

### Security Group Configuration
For minimal but functional security, configure the **"developer"** security group:
- **Inbound Rules:**
  - **SSH (Port 22):** Allow TCP from `0.0.0.0/0` (for easy access via PuTTY or Terminal).
  - **Flask (Port 5000):** Allow TCP from `0.0.0.0/0` (if needed for web access).
- **Outbound Rules:**
  - Allow all outbound traffic (default).

---

### Steps to Set Up the Developer Machine

#### 1. Launch the EC2 Instance
1. Log in to the AWS Management Console and navigate to **EC2 Dashboard**.
2. Click **Launch Instance**.
3. **Select an AMI:** Choose a Debian AMI (Free Tier eligible).
4. **Choose Instance Type:** Select **t2.micro**.
5. **Name the Instance:** Set the instance name to **developer**.
6. **Create Key Pair:**
   - Select **Create new key pair**.
   - Name it `developer_key`.
   - Select **RSA**, `.pem` format, and download it.
   - Store this file in a safe place.
7. **Security Group:** Create a security group named **developer** with:
   - **SSH (22):** Open to `0.0.0.0/0` for connection.
   - **Flask (5000):** Open to `0.0.0.0/0` if web access is needed.
8. Click **Launch Instance**.

### 2. Connect to the Developer Machine

#### **For Linux/Mac Users:**
```bash
ssh -i /path/to/developer_key.pem admin@<EC2_PUBLIC_IP>
```

#### **For Windows Users (PuTTY):**
1. Convert `.pem` to `.ppk` using **PuTTYgen**.
2. Open **PuTTY**, go to **Connection → SSH → Auth**, and load `developer_key.ppk`.
3. Set **Host** to `<EC2_PUBLIC_IP>` and **Port** to `22`.
4. Click **Open** and log in.

### 3. Install Required Packages
```bash
sudo apt update
sudo apt install git -y
```

### 4. Clone the GitHub Repository
```bash
git clone https://github.com/Prathamesh1236/network_scanner.git
cd network_scanner
```

### 5. Generate SSH Key and Add to GitHub
#### **Step 1: Generate SSH Key (if not already done)**
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```
- Press **Enter** to save the key in the default location (`~/.ssh/id_rsa`).
- Enter a secure **passphrase** (optional but recommended).

#### **Step 2: Copy the Public Key**
```bash
cat ~/.ssh/id_rsa.pub
```
Copy the output of this command.

#### **Step 3: Create a New GitHub Repository and Add SSH Key**
1. Log in to GitHub and go to **Repositories → New**.
2. Set a repository name (e.g., `my_network_scanner`).
3. Choose **Private/Public** based on your preference.
4. Click **Create Repository**.
5. Go to **Settings → Security → Deploy Keys**.
6. Click **Add Deploy Key**.
7. Paste the copied key into the **Key** field.
8. Click **Add Key**.

### 6. Configure Local Repository to Push to Your GitHub
```bash
git remote remove origin  # Remove the existing remote repository
```

```bash
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/my_network_scanner.git
```

```bash
git branch -M main
```

```bash
git push -u origin main
```

Now your cloned project is pushed to your **own** GitHub repository! 🎉


