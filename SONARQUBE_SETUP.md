# 🔍 SonarQube Configuration Guide

## 📋 Step-by-Step Configuration

### 1️⃣ **Initial Login**
1. Open your browser and go to: **http://localhost:9000**
2. Login with default credentials:
   - **Username**: `admin`
   - **Password**: `admin`
3. You'll be prompted to change the password
   - Enter a new password (remember it!)
   - Confirm the new password

---

### 2️⃣ **Create Authentication Token for Jenkins**

1. After logging in, click on your profile icon (top-right)
2. Go to: **My Account** → **Security** tab
3. In the "Generate Tokens" section:
   - **Name**: `jenkins-token` (or any name you prefer)
   - **Type**: Select "User Token"
   - **Expires in**: Select "No expiration" or set your preference
4. Click **Generate**
5. **IMPORTANT**: Copy the token immediately! It looks like:
   ```
   squ_1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0
   ```
   ⚠️ **You won't be able to see it again!**

---

### 3️⃣ **Create Project in SonarQube**

1. Click **"Create Project"** on the dashboard
2. Choose **"Manually"**
3. Enter project details:
   - **Project key**: `food-delivery`
   - **Display name**: `Food Delivery App`
4. Click **"Set Up"**
5. Choose **"With Jenkins"** (or "Locally" if you prefer)
6. Note the project key for later use

---

### 4️⃣ **Configure Jenkins with SonarQube Token**

#### Option A: Via Jenkins UI (Recommended)

1. Open Jenkins: **http://localhost:8080**
2. Go to: **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
3. Click **"Add Credentials"**
4. Fill in:
   - **Kind**: Secret text
   - **Secret**: Paste your SonarQube token
   - **ID**: `sonarqube-token`
   - **Description**: `SonarQube Authentication Token`
5. Click **"Create"**

#### Option B: Via CLI (Automated)

Run this command (replace YOUR_TOKEN with your actual token):

```bash
# Inside Jenkins container
docker exec -it jenkins bash -c "
cat > /tmp/sonar-cred.xml << 'EOF'
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>sonarqube-token</id>
  <description>SonarQube Authentication Token</description>
  <secret>YOUR_TOKEN_HERE</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF
"
```

---

### 5️⃣ **Configure SonarQube Server in Jenkins**

1. In Jenkins, go to: **Manage Jenkins** → **Configure System**
2. Scroll to **SonarQube servers** section
3. Click **"Add SonarQube"**
4. Configure:
   - **Name**: `sonarqube`
   - **Server URL**: `http://sonarqube:9000`
   - **Server authentication token**: Select `sonarqube-token` (from credentials)
5. Click **"Save"**

---

### 6️⃣ **Test the Configuration**

Run your Jenkins pipeline to test SonarQube integration:

```bash
# From your project directory
cd /Users/mac/Mouadh/DEVGIT/miniProjetDocker/Food-Delivery

# If using git, commit and push to trigger pipeline
# Or manually trigger in Jenkins UI
```

---

## 🔧 Quick Configuration Script

Save your SonarQube token here for reference:

```bash
# File: .sonarqube-config
SONARQUBE_URL=http://localhost:9000
SONARQUBE_TOKEN=your_token_here
PROJECT_KEY=food-delivery
```

---

## 📊 Verify Configuration

### Check SonarQube is running:
```bash
curl http://localhost:9000/api/system/status
```

### Check Jenkins can reach SonarQube:
```bash
docker exec jenkins curl -s http://sonarqube:9000/api/system/status
```

---

## 🚨 Troubleshooting

### Issue: "401 Unauthorized" in Jenkins
- ✅ Verify token is correct in Jenkins credentials
- ✅ Token hasn't expired
- ✅ Token has proper permissions

### Issue: "Connection refused"
- ✅ Check SonarQube is running: `docker ps | grep sonarqube`
- ✅ Verify network: `docker network inspect food-delivery-network`
- ✅ Check Jenkins can reach SonarQube: `docker exec jenkins ping sonarqube`

### Issue: Quality Gate fails
- ✅ Check SonarQube dashboard for actual issues
- ✅ Review code quality metrics
- ✅ Adjust Quality Gate settings if needed

---

## 📝 Important Notes

1. **Save your SonarQube token securely** - you can't retrieve it later
2. **Default credentials**: Change them immediately after first login
3. **Network**: Both containers must be on `food-delivery-network`
4. **URL in Jenkins**: Use `http://sonarqube:9000` (container name, not localhost)
5. **Quality Gate**: May fail initially - this is normal for new projects

---

## 🎯 Next Steps After Configuration

1. Run a test build in Jenkins
2. Check SonarQube dashboard for analysis results
3. Review code quality metrics
4. Set up Quality Gate rules (optional)
5. Configure webhooks for automatic updates (optional)

---

## 🔗 Useful Links

- SonarQube Dashboard: http://localhost:9000
- Jenkins: http://localhost:8080
- SonarQube API: http://localhost:9000/api
- Documentation: https://docs.sonarqube.org/latest/

---

**Ready to configure? Open http://localhost:9000 and start with Step 1!** 🚀
