#!/bin/bash
/bin/docker stop beauty-web celery_worker celery_beat
/bin/docker rm beauty-web celery_worker celery_beat