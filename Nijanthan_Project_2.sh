#!/bin/bash

# === STEP 1: Install Git ===
if ! command -v git &>/dev/null; then
  echo "🔧 Installing Git..."
  sudo apt update
  sudo apt install -y git
else
  echo "✅ Git is already installed."
fi

# === STEP 2: Configure Git Identity ===
GIT_NAME="YourName"
GIT_EMAIL="your.email@example.com"
echo "🔐 Setting global Git username and email..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# === STEP 3: Create Sample HTML Project ===
PROJECT_DIR="versioned-html"
echo "📁 Creating project: $PROJECT_DIR"
mkdir -p $PROJECT_DIR && cd $PROJECT_DIR

cat <<EOF > index.html
<!DOCTYPE html>
<html>
<head><title>Hello Git</title></head>
<body>
  <h1>🚀 Hello from Git versioned project!</h1>
</body>
</html>
EOF

# === STEP 4: Initialize Git Repository ===
git init
git add .
git commit -m "Initial commit - simple HTML page"

# === STEP 5: Connect to GitHub Remote ===
REMOTE_URL="https://github.com/your-username/your-repo.git"  # Replace this with your repo URL
echo "🌐 Connecting to remote: $REMOTE_URL"
git branch -M main
git remote add origin $REMOTE_URL

# === STEP 6: Push to GitHub ===
echo "📤 Pushing code to GitHub..."
git push -u origin main
