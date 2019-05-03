#!/bin/sh

# Load header
. ./header.inc

# Setup Mail
export GF_SMTP_ENABLED="true"
export GF_SMTP_HOST="$PLATFORM_SMTP_HOST:25"

# HTTP Port
export GF_SERVER_HTTP_PORT=$PORT
export GF_SERVER_HTTP_DOMAIN=$(bin/pathfinder PLATFORM_ROUTES grafana | awk -F / '{print $3}' | uniq)
export GF_SERVER_ROOT_URL=$(bin/pathfinder PLATFORM_ROUTES grafana | head -1)

# Data Directory
export GF_PATHS_DATA="${DATA_PATH}"
export GF_PATHS_LOGS="${DATA_PATH}/logs"
export GF_PATHS_PLUGINS="${DATA_PATH}/plugins"
# Provisioning Directory
export GF_PATHS_PROVISIONING="${CONFIG_PATH}/provisioning"
# LDAP Configuration File (still needs to be enabled in $CONFIG_PATH/grafana.ini)
export GF_AUTH_LDAP_CONFIG_FILE="${CONFIG_PATH}/ldap.toml"

# Extract database configuration from enviroment
export GF_DATABASE_TYPE=mysql
export GF_DATABASE_HOST=$(bin/discovery PLATFORM_RELATIONSHIPS confdb.mysqlconfig.host):$(bin/discovery PLATFORM_RELATIONSHIPS confdb.mysqlconfig.port)
export GF_DATABASE_NAME=$(bin/discovery PLATFORM_RELATIONSHIPS confdb.mysqlconfig.path)
export GF_DATABASE_USER=$(bin/discovery PLATFORM_RELATIONSHIPS confdb.mysqlconfig.username)
export GF_DATABASE_PASSWORD=$(bin/discovery PLATFORM_RELATIONSHIPS confdb.mysqlconfig.password)

# Extract Redis configuration from enviroment
REDIS_HOST=$(bin/discovery PLATFORM_RELATIONSHIPS sessdb.redissession.host)
REDIS_PORT=$(bin/discovery PLATFORM_RELATIONSHIPS sessdb.redissession.port)
REDIS_POOL_SIZE=100

export GF_SESSION_PROVIDOR=redis
export GF_SESSION_PROVIDER_CONFIG="addr=${REDIS_HOST}:${REDIS_PORT},pool_size=${REDIS_POOL_SIZE},db=grafana"

# This ensures that the child process below gets stopped when Platform.sh kills this script.
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Start Grafana
${GRAFANA_HOME}/bin/grafana-server --homepath ${GRAFANA_HOME} --config ${CONFIG_PATH}/grafana.ini

