#!/bin/bash
set -e

FRONT_DIR="/home/developer/frontend_service/beauty-ai-platform"

if [ ! -d "$FRONT_DIR" ]; then
    mkdir -p "$FRONT_DIR"
fi

if [ ! -d "$FRONT_DIR/.git" ]; then
    cd /home/developer/frontend_service
    git clone -b frontend https://github.com/KLUZOO/beauty-ai-platform
else
    cd "$FRONT_DIR"
    git fetch origin
    git reset --hard origin/frontend
fi

cp /home/developer/.appenv \
   "$FRONT_DIR/beauty-ai-platform/frontend/.env"

cd "$FRONT_DIR/beauty-ai-platform/frontend"

docker build -t beauty-frontend:latest .
docker run -d --name beauty-frontend \
    -p 80:8080 \
    --env-file "$FRONT_DIR/beauty-ai-platform/frontend/.env" \
    beauty-frontend:latest