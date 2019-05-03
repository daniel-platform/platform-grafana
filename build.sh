#!/bin/bash

# Load header
. ./header.inc

# Desired version can be set by means of an enviromental variable
if [ -z "$GRAFANA_VERSION" ]; then 
	# Default to Grafana 6.1.6
	GRAFANA_VERSION=6.1.6; 
fi

GRAFANA_DOWNLOAD_URI="https://s3-us-west-2.amazonaws.com/grafana-releases/release"
GRAFANA_DL_ARCHIVE="grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz"

# Make directories
mkdir -p $GRAFANA_HOME;
mkdir -p ${CONFIG_PATH}/provisioning/datasources

# Download and Extract Grafana
echo "Downloading ${GRAFANA_DOWNLOAD_URI}/${GRAFANA_DL_ARCHIVE}"
tar xzv -C $GRAFANA_HOME --strip 1 < <(wget --no-cookies --no-check-certificate -q -O - ${GRAFANA_DOWNLOAD_URI}/${GRAFANA_DL_ARCHIVE})

# Symlink the default (later to be) dynamicly provisioned datasource
ln -s ${AUTO_PROVISION_PATH}/default_datadb_influxdata.yaml ${CONFIG_PATH}/provisioning/datasources/default_datadb_influxdata.yaml

