#!/bin/bash
set +x

export USE_LOCAL_AMS=true
export REGISTRY_ENABLE_MULTITENANCY=true

# Delete repos if they exists
rm -rf apicurio-registry
rm -rf srs-fleet-manager

# Clone the repos
git clone https://github.com/Apicurio/apicurio-registry.git --depth 1 --single-branch --branch feat/hackathon
git clone https://github.com/bf2fc6cc711aee1a0c2a/srs-fleet-manager.git --depth 1 --single-branch --branch feat/hackathon

# Build the repos locally
(
  cd apicurio-registry && \
  mvn clean install -DskipTests
)
(
  cd srs-fleet-manager && \
  mvn clean install -DskipTests
)

yarn --cwd apicurio-registry/ui install

# Run the 3 services
mvn compile exec:java -Dexec.mainClass="io.apicurio.registry.RegistryQuarkusMain" -f apicurio-registry/app/pom.xml &

mvn compile exec:java -Dexec.mainClass="io.apicurio.multitenant.api.TenantManagerQuarkusMain" -f apicurio-registry/multitenancy/tenant-manager-api/pom.xml &

mvn compile exec:java -Dexec.mainClass="org.bf2.srs.fleetmanager.FleetManagerQuarkusMain" -f srs-fleet-manager/core/pom.xml &

yarn --cwd apicurio-registry/ui start &
