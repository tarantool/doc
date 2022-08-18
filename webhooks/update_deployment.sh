#!/usr/bin/env bash

set -xe -o pipefail -o nounset

echo "Deploy version ${DEPLOYMENT_NAME} on the server"

# testing this locally:
# source .env && export $(cut -d= -f1 .env) && ./update_deployment.sh

curl --fail --show-error -v \
    --data '{"update_key":"'"${TARANTOOL_UPDATE_KEY}"'"}' \
    --header "Content-Type: application/json" \
    --request POST "${TARANTOOL_UPDATE_URL}""${DEPLOYMENT_NAME}"/
