#!/bin/bash

# Variables
schemaVer="0.0.1.3.0.0.0-9"
projDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

registryArr=($(find / -type f -name "registry"))
registry=${registryArr[-1]}
registryUserName="registry_user"
registryPass="R12034ore"

platformDir=$(dirname $(find / -path "*/kafka/bin"))
nifiLibs=($(find / -path "/usr/*/nifi/lib"))

# Move to tmp directory
cd /tmp

# Download binaries and extract to proper location
wget http://nexus-private.hortonworks.com/nexus/content/groups/public/com/hortonworks/registries/hortonworks-registries-bin/${schemaVer}/hortonworks-registries-bin-${schemaVer}.tar.gz
tar zxvf hortonworks-registries-bin-${schemaVer}.tar.gz
mv hortonworks-registry-${schemaVer} $platformDir/registry

# Create symlink in current directory
ln -s $platformDir/registry $(dirname $platformDir)/current

# (Sandbox only, due to default username/pass)
echo "create database schema_registry; CREATE USER '$registryUserName'@'localhost' IDENTIFIED BY '$registryPass'; GRANT ALL PRIVILEGES ON schema_registry.* TO '$registryUserName'@'localhost' WITH GRANT OPTION;" > tmpQuery.sql
mysql -u root -phadoop < tmpQuery.sql

# Replace configs with appropriate values
perl -pi -e 's/9090/8090/g' $platformDir/registry/conf/registry.yaml
perl -pi -e 's/registry_password/$registryPass/g' $platformDir/registry/conf/registry.yaml

# Bootstrap storage and follow-up with starting in daemon mode
$platformDir/registry/bootstrap/bootstrap-storage.sh
$platformDir/registry/bin/registry start

# Install Schema Registry nar file
cp $projDir/nifi-registry-nar-0.0.1-SNAPSHOT.nar ${nifiLibs[0]}
