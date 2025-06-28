#!/bin/bash

# === CONFIGURATION ===
JENKINS_PORT=8080
PROJECT_DIR="jenkins_python_project"
PY_FILE="hello.py"
PIPELINE_FILE="Jenkinsfile"

# === STEP 1: Install Jenkins & Docker ===
if ! command -v docker &>/dev/null; then
  echo "🐳 Installing Docker..."
  sudo apt update
  sudo apt install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER
fi

echo "📦 Running Jenkins in Docker..."
docker run -d --name jenkins_ai \
  -p $JENKINS_PORT:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# === STEP 2: Create Sample Python Project ===
echo "📁 Creating sample Python project..."
mkdir -p $PROJECT_DIR && cd $PROJECT_DIR

cat <<EOF > $PY_FILE
def greet():
    return "Hello from Jenkins CI"

if __name__ == "__main__":
    print(greet())
EOF

cat <<EOF > test_greet.py
from hello import greet

def test_output():
    assert greet() == "Hello from Jenkins CI"
EOF

# === STEP 3: Define Jenkins Pipeline ===
echo "🧪 Creating Jenkinsfile..."
cat <<EOF > $PIPELINE_FILE
pipeline {
    agent any
    stages {
        stage('Install') {
            steps {
                sh 'pip install pytest'
            }
        }
        stage('Test') {
            steps {
                sh 'pytest test_greet.py'
            }
        }
    }
}
EOF

cd ..

# === STEP 4: Final Tips for Jenkins ===
echo "🎯 FINAL SETUP INSTRUCTIONS"
echo "1. Open Jenkins in your browser: http://localhost:$JENKINS_PORT"
echo "2. Unlock using the password from:"
echo "   docker exec jenkins_ai cat /var/jenkins_home/secrets/initialAdminPassword"
echo "3. Install 'Pipeline' plugin and create a new pipeline project."
echo "4. Link it to: $(pwd)/$PROJECT_DIR"
echo "5. On SCM setup, use local Git or GitHub to enable commit-triggered builds."
