#!/bin/sh

# Load header
. ./header.inc

# Extract database configuration from enviroment
INFLUXDB_USER=admin
INFLUXDB_PASS=admin
INFLUXDB_HOST=$(bin/discovery PLATFORM_RELATIONSHIPS datadb.influxdata.host)
INFLUXDB_PORT=$(bin/discovery PLATFORM_RELATIONSHIPS datadb.influxdata.port)
INFLUXDB_SCHEME=$(bin/discovery PLATFORM_RELATIONSHIPS datadb.influxdata.scheme)

echo "Auto provisioning default datasource..."

# Generate a datasource configuration for InfluxDB
cat << EOF > ${AUTO_PROVISION_PATH}/default_datadb_influxdata.yaml
apiVersion: 1

datasources:
  - name: Default
    type: influxdb
    access: proxy
    database: default
    user: ${INFLUXDB_USER}
    secureJsonData:
      password: ${INFLUXDB_PASS}
    url: ${INFLUXDB_SCHEME}://${INFLUXDB_HOST}:${INFLUXDB_PORT}
EOF

# Setup Mail
export GF_SMTP_ENABLED="true"
export GF_SMTP_HOST="$PLATFORM_SMTP_HOST:25"

# HTTP Port
export GF_SERVER_HTTP_PORT=$PORT
export GF_SERVER_HTTP_DOMAIN=$(bin/pathfinder PLATFORM_ROUTES $PLATFORM_APPLICATION_NAME | awk -F / '{print $3}' | uniq)
export GF_SERVER_ROOT_URL=$(bin/pathfinder PLATFORM_ROUTES $PLATFORM_APPLICATION_NAME | head -1)

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

# Start Grafana
exec ${GRAFANA_HOME}/bin/grafana-server --homepath ${GRAFANA_HOME} --config ${CONFIG_PATH}/grafana.ini
