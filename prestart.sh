#!/bin/sh

# Load header
. ./header.inc

# Extract database configuration from enviroment
INFLUXDB_USER=admin
INFLUXDB_PASS=admin
INFLUXDB_HOST=$(bin/json_env PLATFORM_RELATIONSHIPS datadb.influxdata.host)
INFLUXDB_PORT=$(bin/json_env PLATFORM_RELATIONSHIPS datadb.influxdata.port)
INFLUXDB_SCHEME=$(bin/json_env PLATFORM_RELATIONSHIPS datadb.influxdata.scheme)

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
    password: ${INFLUXDB_PASS}
    url: ${INFLUXDB_SCHEME}://${INFLUXDB_HOST}:${INFLUXDB_PORT}
EOF

