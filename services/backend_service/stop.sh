#!/bin/bash
/bin/docker stop beauty-web celery_worker celery_beat aiassistant
/bin/docker rm beauty-web celery_worker celery_beat aiassistant