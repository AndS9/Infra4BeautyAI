#!/bin/bash

docker exec beauty-web sh -c "python manage.py loaddata initial_seed/db_data.json"
docker exec beauty-web sh -c "python manage.py createsuperuser --noinput"