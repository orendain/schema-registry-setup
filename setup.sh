#!/bin/bash

# Variables
schemaVer="0.0.1.3.0.0.0-9"
projDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

registryUserName="registry_user"
registryPass="R12034ore"
registryPort=8090

platformDir=$(find / -maxdepth 3 -type d -wholename '/usr/hd*/[0-9]*' -print -quit)
registryDir=$platformDir/registry


# Download binaries and extract to proper location
cd /tmp
echo "Downloading Schema Registry"
wget http://nexus-private.hortonworks.com/nexus/content/groups/public/com/hortonworks/registries/hortonworks-registries-bin/${schemaVer}/hortonworks-registries-bin-${schemaVer}.tar.gz

echo "Extracting and moving Schema Registry to correct location"
tar zxvf hortonworks-registries-bin-${schemaVer}.tar.gz
mv hortonworks-registry-${schemaVer} $registryDir
ln -s $registryDir $(dirname $platformDir)/current

# (Sandbox only, due to default username/pass)
echo "Creating necessary database entries"
echo "create database schema_registry; CREATE USER '$registryUserName'@'localhost' IDENTIFIED BY '$registryPass'; GRANT ALL PRIVILEGES ON schema_registry.* TO '$registryUserName'@'localhost' WITH GRANT OPTION;" > tmpQuery.sql
mysql -u root -phadoop < tmpQuery.sql

# Edit configs with appropriate values
echo "Setting default Schema Registry configuration"
perl -pi -e 's/9090/$registryPort/g' -e 's/registry_password/$registryPass/g' $registryDir/conf/registry.yaml

# Bootstrap storage and follow-up with starting in daemon mode
echo "Bootstrapping and starting Schema Registry"
$registryDir/bootstrap/bootstrap-storage.sh
$registryDir/bin/registry start

# Install Schema Registry nar file
echo "Installing NiFi NAR file for NiFi integration, restart NiFi for change to take effect"
cp $projDir/nifi-registry-nar-0.0.1-SNAPSHOT.nar $platformDir/nifi/lib
