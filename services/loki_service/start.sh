#!/bin/bash
set -e

cd /home/developer/Infra4BeautyAI/services/loki_service
docker compose -f docker-compose.yaml up -d