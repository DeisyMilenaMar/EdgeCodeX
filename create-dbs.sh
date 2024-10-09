#!/bin/bash
set -ex

# Comando base para conectarse a Postgres
POSTGRES="psql -U postgres"

# Definir variables para el usuario y la base de datos
POSTGRES_USER="miusuario"
POSTGRES_PASSWORD="mipassword"
POSTGRES_DB="midatabase"

# Crear el usuario solo si no existe
if ! $POSTGRES -c "\du" | grep -q "${POSTGRES_USER}"; then
  $POSTGRES <<EOSQL
CREATE USER "${POSTGRES_USER}" WITH PASSWORD '${POSTGRES_PASSWORD}' SUPERUSER;
EOSQL
fi

# Crear la base de datos solo si no existe
if ! $POSTGRES -lqt | cut -d \| -f 1 | grep -qw "${POSTGRES_DB}"; then
  $POSTGRES <<EOSQL
CREATE DATABASE ${POSTGRES_DB};
GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO "${POSTGRES_USER}";
EOSQL
fi
