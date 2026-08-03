#!/bin/bash
set -e

REPO_DIR="/home/developer/beauty-ai-platform"

if [ ! -d "$REPO_DIR/.git" ]; then
    cd /home/developer
    git clone -b develop https://github.com/AndS9/beauty-ai-platform
else
    cd "$REPO_DIR"
    git fetch origin
    git reset --hard origin/develop
fi

cp /home/developer/.appenv \
   "$REPO_DIR/backend/.env"

cd "$REPO_DIR/backend"

docker compose up -d --build