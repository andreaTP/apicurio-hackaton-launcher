#!/bin/bash
set +x

export USE_LOCAL_AMS=true
export REGISTRY_ENABLE_MULTITENANCY=true


export AUTH_ENABLED=true
export KEYCLOAK_URL='https://auth.apicur.io/auth'
export KEYCLOAK_REALM='operate-first-apicurio'
export TENANT_MANAGER_AUTH_ENABLED='true'
export TENANT_MANAGER_AUTH_SERVER_URL='https://auth.apicur.io/auth'
export TENANT_MANAGER_AUTH_SERVER_REALM='operate-first-apicurio'
export TENANT_MANAGER_AUTH_CLIENT_ID='sr-tenant-manager'
export TENANT_MANAGER_AUTH_SECRET="${TENANT_MANAGER_CLIENT_SECRET}"
export ORGANIZATION_ID_CLAIM="organization_id"

export REGISTRY_QUOTA_PLANS_CONFIG_FILE="${PWD}/srs-fleet-manager/dist/docker-compose/config/quota-plans.yaml"
export REGISTRY_DEPLOYMENTS_CONFIG_FILE="${PWD}/registry-deployments.yaml"


# # Delete repos if they exists
rm -rf apicurio-registry
rm -rf srs-fleet-manager

# # Clone the repos
git clone https://github.com/Apicurio/apicurio-registry.git --depth 1 --single-branch --branch feat/hackathon
git clone https://github.com/bf2fc6cc711aee1a0c2a/srs-fleet-manager.git --depth 1 --single-branch --branch feat/hackathon

# # Build the repos locally
(
  cd apicurio-registry && \
  mvn clean install -DskipTests
)
(
  cd srs-fleet-manager && \
  mvn clean install -DskipTests
)
(
  cd apicurio-registry/ui && \
  ./init-dev.sh && \
  yarn install
)

# Run the 3 services
export KEYCLOAK_API_CLIENT_ID='sr-api'
mvn compile exec:java -Dexec.mainClass="io.apicurio.registry.RegistryQuarkusMain" -f apicurio-registry/app/pom.xml &

export KEYCLOAK_API_CLIENT_ID='sr-tenant-manager'
mvn compile exec:java -Dexec.mainClass="io.apicurio.multitenant.api.TenantManagerQuarkusMain" -f apicurio-registry/multitenancy/tenant-manager-api/pom.xml &

export KEYCLOAK_API_CLIENT_ID='sr-fleet-manager'
mvn compile exec:java -Dexec.mainClass="org.bf2.srs.fleetmanager.FleetManagerQuarkusMain" -f srs-fleet-manager/core/pom.xml &

yarn --cwd apicurio-registry/ui start &
