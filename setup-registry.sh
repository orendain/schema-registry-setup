#!/bin/bash

# Variables
PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Move to tmp directory
cd /tmp

# Download Schema Registry binaries
wget http://nexus-private.hortonworks.com/nexus/content/groups/public/com/hortonworks/registries/hortonworks-registries-bin/0.0.1.2.2.0.0-19/hortonworks-registries-bin-0.0.1.2.2.0.0-19.tar.gz

tar zxvf hortonworks-registries-bin-0.0.1.2.2.0.0-19.tar.gz
mv hortonworks-registry-0.0.1.2.2.0.0-19/ /usr/hdf/2.1.0.0-165/registry

ln -s /usr/hdf/2.1.0.0-165/registry /usr/hdf/current/registry


echo "create database schema_registry; CREATE USER 'registry_user'@'localhost' IDENTIFIED BY 'R12034ore'; GRANT ALL PRIVILEGES ON schema_registry.* TO 'registry_user'@'localhost' WITH GRANT OPTION;" > tmpp.sql
mysql -u root -phadoop < tmpp.sql


perl -pi -e 's/9090/8090/g' /usr/hdf/current/registry/conf/registry.yaml
perl -pi -e 's/registry_password/R12034ore/g' /usr/hdf/current/registry/conf/registry.yaml


/usr/hdf/current/registry/bootstrap/bootstrap-storage.sh

# Start in daemon mode
/usr/hdf/current/registry/bin/registry start

# Install Schema Registry nar file
cp $PROJ_DIR/nifi-registry-nar-0.0.1-SNAPSHOT.nar /usr/hdf/current/nifi/lib

