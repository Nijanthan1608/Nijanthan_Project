#!/bin/bash

# === CONFIGURATION ===
APP_NAME="elk-demo-app"
APP_PORT=5000
ELK_COMPOSE_FILE="elk-docker-compose.yml"

# === STEP 1: Install Docker & Docker Compose ===
if ! command -v docker &>/dev/null; then
  echo "🐳 Installing Docker..."
  sudo apt update && sudo apt install -y docker.io
  sudo systemctl start docker && sudo systemctl enable docker
fi

if ! command -v docker-compose &>/dev/null; then
  echo "📦 Installing Docker Compose..."
  sudo apt install -y docker-compose
fi

# === STEP 2: Create ELK Stack with Docker Compose ===
mkdir -p elk_setup && cd elk_setup
echo "🛠️ Writing Docker Compose for ELK..."

cat <<EOF > $ELK_COMPOSE_FILE
version: "3.7"

services:

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.18
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.18
    container_name: logstash
    ports:
      - "5000:5000"
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.18
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
EOF

# === STEP 3: Create Logstash Config to Accept JSON Logs ===
cat <<EOF > logstash.conf
input {
  tcp {
    port => 5000
    codec => json_lines
  }
}
output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "app-logs"
  }
}
EOF

# === STEP 4: Spin Up ELK Stack ===
echo "🚀 Starting ELK stack..."
docker-compose -f $ELK_COMPOSE_FILE up -d
sleep 20

# === STEP 5: Create a Demo Python App that Sends Logs ===
mkdir -p ../$APP_NAME && cd ../$APP_NAME

cat <<EOF > app.py
import logging
import socket
import json
from flask import Flask
app = Flask(__name__)

logger = logging.getLogger()
logger.setLevel(logging.INFO)
log_handler = logging.handlers.SocketHandler("localhost", 5000)
logger.addHandler(log_handler)

@app.route("/")
def home():
    log_data = json.dumps({"message": "Home page visited"})
    logger.info(log_data)
    return "📈 Logging from Flask to ELK stack!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=$APP_PORT)
EOF

cat <<EOF > requirements.txt
flask
EOF

echo "🐍 Installing dependencies and running app..."
pip install -r requirements.txt
python3 app.py &
sleep 5

# === STEP 6: View Kibana Dashboard ===
echo "🌐 Visit Kibana at: http://localhost:5601"
echo "📊 Go to 'Discover' → create index pattern as: app-logs*"
echo "📡 Then trigger: curl http://localhost:$APP_PORT"
