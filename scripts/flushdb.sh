#!/bin/bash

cd /home/developer/Infra4BeautyAI/backend_service
docker compose down
rm -rf /beautyDB/*
cd /home/developer/Infra4BeautyAI/backend_service
docker compose up -d