#!/bin/bash
cd /home/developer
git clone -b develop https://github.com/KLUZOO/beauty-ai-platform
cp /home/developer/startup/.appenv /home/developer/beauty-ai-platform/backend/.env
cd beauty-ai-platform/backend/
docker compose up -d --build