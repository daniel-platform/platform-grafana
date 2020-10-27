#!/bin/bash

# Load header
. ./header.inc

# Desired version can be set by means of an enviromental variable
if [ -z "$GRAFANA_VERSION" ]; then
	# Default to Grafana 7.2.1
	GRAFANA_VERSION=7.2.1;
fi

GRAFANA_DOWNLOAD_URI="https://dl.grafana.com/oss/release"
GRAFANA_DL_ARCHIVE="grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz"

# Make directories
mkdir -p $GRAFANA_HOME;
mkdir -p ${CONFIG_PATH}/provisioning/datasources
mkdir -p ${CONFIG_PATH}/provisioning/plugins
mkdir -p ${CONFIG_PATH}/provisioning/notifiers
mkdir -p ${CONFIG_PATH}/provisioning/dashboards
mkdir -p bin

# Download and Extract Grafana
echo "Downloading ${GRAFANA_DOWNLOAD_URI}/${GRAFANA_DL_ARCHIVE}"
tar xzv -C $GRAFANA_HOME --strip 1 < <(wget --no-cookies --no-check-certificate -q -O - ${GRAFANA_DOWNLOAD_URI}/${GRAFANA_DL_ARCHIVE})

# Symlink the default (later to be) dynamicly provisioned datasource
ln -s ${AUTO_PROVISION_PATH}/default_datadb_influxdata.yaml ${CONFIG_PATH}/provisioning/datasources/default_datadb_influxdata.yaml

# discovery & pathfinder are helpful little utilities
DISCOVERY_DOWNLOAD_URI="https://github.com/daniel-platform/discovery/releases/download/v0.1-alpha/discovery-debian-stretch"
PATHFINDER_DOWNLOAD_URI="https://github.com/daniel-platform/pathfinder/releases/download/v0.1-alpha/pathfinder-debian-stretch"

# Download and put it in the bin folder
echo "Downloading ${DISCOVERY_DOWNLOAD_URI}"
wget --no-cookies --no-check-certificate -q -O bin/discovery ${DISCOVERY_DOWNLOAD_URI}
echo "Downloading ${PATHFINDER_DOWNLOAD_URI}"
wget --no-cookies --no-check-certificate -q -O bin/pathfinder ${PATHFINDER_DOWNLOAD_URI}
chmod +x bin/pathfinder bin/discovery
