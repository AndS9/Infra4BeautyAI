#!/bin/bash
set -e

REPO_DIR="/home/developer/beauty-ai-platform"

if [ ! -d "$REPO_DIR/.git" ]; then
    cd /home/developer
    git clone -b develop https://github.com/KLUZOO/beauty-ai-platform
else
    cd "$REPO_DIR"
    git fetch origin
    git reset --hard origin/develop
fi

cd $REPO_DIR/backend

/bin/docker build -t backend .

systemctl start db.service