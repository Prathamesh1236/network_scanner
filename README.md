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
5. Go to **Settings → Deploy Keys** of your newly created repository.
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

---

## 7. Setting Up Jenkins on the Jenkins Instance

### **Step 1: Install Java (Required for Jenkins)**
```bash
sudo apt update
sudo apt install openjdk-11-jdk -y
```
Verify Java installation:
```bash
java -version
```

### **Step 2: Install Jenkins**
```bash
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

```bash
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

```bash
sudo apt update
sudo apt install jenkins -y
```

### **Step 3: Start and Enable Jenkins Service**
```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

### **Step 4: Configure Firewall (If UFW is enabled)**
```bash
sudo ufw allow 8080
sudo ufw reload
```

### **Step 5: Retrieve Initial Jenkins Admin Password**
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Copy the output and save it.

### **Step 6: Access Jenkins Web Interface**
1. Open a browser and go to:
   ```
   http://<JENKINS_INSTANCE_PUBLIC_IP>:8080
   ```
2. Enter the **initial admin password** copied from Step 5.
3. Follow the on-screen instructions to install recommended plugins.
4. Create an **admin user** and finish setup.

Jenkins is now successfully installed and ready to use! ✅

---

## 8. Setting Up a Webhook to Trigger Jenkins on GitHub Push

### **What is a Webhook?**
A **GitHub Webhook** is a way to notify Jenkins when a new commit is pushed to the repository. When a change is made, GitHub sends an HTTP POST request to Jenkins, triggering an automated build.

### **Step 1: Install GitHub Plugin in Jenkins**
1. Log in to **Jenkins**.
2. Go to **Manage Jenkins → Manage Plugins**.
3. In the **Available** tab, search for **GitHub Plugin**.
4. Select it and click **Install Without Restart**.

### **Step 2: Configure Webhook in GitHub**
1. Go to your **GitHub Repository → Settings → Webhooks**.
2. Click **Add Webhook**.
3. In the **Payload URL**, enter:
   ```
   http://<JENKINS_PUBLIC_IP>:8080/github-webhook/
   ```
4. Set **Content Type** to `application/json`.
5. Choose **Just the push event**.
6. Click **Add Webhook**.

### **Step 3: Test the Webhook**
```bash
echo "Test Webhook" >> test.txt
git add test.txt
git commit -m "Testing GitHub Webhook for Jenkins"
git push origin main
```
Now Jenkins should trigger a build automatically! 🚀

