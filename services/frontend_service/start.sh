#!/bin/bash
set -e

FRONT_DIR="/home/developer/frontend_service/beauty-ai-platform"

if [ ! -d "$FRONT_DIR/.git" ]; then
    mkdir -p /home/developer/frontend_service
    cd /home/developer/frontend_service
    git clone -b frontend https://github.com/KLUZOO/beauty-ai-platform
else
    cd "$FRONT_DIR"
    git fetch origin
    git reset --hard origin/frontend
fi

cd "$FRONT_DIR/frontend"

docker build -t beauty-frontend:latest .
docker run -d --name beauty-frontend \
    --network=host \
    --user 0 \
    --env-file /home/developer/Infra4BeautyAI/environments/frontend.env \
    -v /home/developer/Infra4BeautyAI/services/frontend_service/default.conf:/etc/nginx/conf.d/default.conf \
    -v /etc/nginx/ssl/server.crt:/etc/nginx/ssl/server.crt \
    -v /etc/nginx/ssl/server.key:/etc/nginx/ssl/server.key \
    beauty-frontend:latest