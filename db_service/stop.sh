#!/bin/bash
cd /home/developer/Infra4BeautyAI/db_service
/bin/docker stop backend celery_worker celery_beat
/bin/docker rm backend celery_worker celery_beat