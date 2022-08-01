#!/bin/bash

curl --location --request POST 'http://localhost:8081/api/serviceregistry_mgmt/v1/admin/registryDeployments' \
--header 'Content-Type: application/json' \
--data-raw '{"registryDeploymentUrl":"http://localhost:8080",
"tenantManagerUrl": "http://localhost:8585",
"name": "Testing local application"
}'
