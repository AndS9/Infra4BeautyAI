#!/bin/bash
set -e

FRONT_DIR="/home/developer/frontend_service/beauty-ai-platform"

if [ ! -d "$FRONT_DIR/.git" ]; then
    mkdir -p /home/developer/frontend_service
    cd /home/developer/frontend_service
    git clone -b frontend https://github.com/AndS9/beauty-ai-platform
else
    cd "$FRONT_DIR"
    git fetch origin
    git reset --hard origin/frontend
fi

cp /home/developer/.appenv \
   "$FRONT_DIR/frontend/.env"

cd "$FRONT_DIR/frontend"

docker build -t beauty-frontend:latest .
docker run -d --name beauty-frontend \
    -p 80:8080 \
    --env-file "$FRONT_DIR/frontend/.env" \
    beauty-frontend:latest