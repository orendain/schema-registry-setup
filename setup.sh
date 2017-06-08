#!/bin/bash

# Variables
schemaVer="0.0.1.2.1.3.0-6"
projDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

registryDB="registry_db"
registryUserName="registry_user"
registryPass="registry_pass"
registryPort=15105

mysqlUserName="root"
mysqlPass="hadoop"

platformDir=$(find / -maxdepth 3 -type d -wholename '/usr/hd*/[0-9]*' -print -quit 2> /dev/null)
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
echo "create database $registryDB; CREATE USER '$registryUserName'@'localhost' IDENTIFIED BY '$registryPass'; GRANT ALL PRIVILEGES ON $registryDB.* TO '$registryUserName'@'localhost' WITH GRANT OPTION;" > tmpQuery.sql
mysql -u $mysqlUserName -p$mysqlPass < tmpQuery.sql

# Edit configs with appropriate values
echo "Setting default Schema Registry configuration"
cp $registryDir/conf/registry.yaml.mysql.example $registryDir/conf/registry.yaml
perl -pi -e "s/9090/$registryPort/g" $registryDir/conf/registry.yaml
perl -pi -e "s/schema_registry/$registryDB/g" $registryDir/conf/registry.yaml
perl -pi -e "s/registry_password/$registryPass/g" $registryDir/conf/registry.yaml

# Bootstrap storage and follow-up with starting in daemon mode
echo "Bootstrapping and starting Schema Registry"
$registryDir/bootstrap/bootstrap-storage.sh
$registryDir/bin/registry start

# Install Schema Registry nar file
echo "Installing NiFi NAR file for NiFi integration, restart NiFi for change to take effect"
cp $projDir/nifi-registry-nar-0.0.1-SNAPSHOT.nar $platformDir/nifi/lib
