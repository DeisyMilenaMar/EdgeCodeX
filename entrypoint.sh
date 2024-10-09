#!/bin/sh

# Ejecuta migraciones
python manage.py migrate

# Ejecuta el comando pasado a docker-compose
exec "$@"