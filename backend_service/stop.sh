#!/bin/bash
/bin/docker stop backend celery_worker celery_beat
/bin/docker rm backend celery_worker celery_beat