#!/usr/bin/env bash

set -xe -o pipefail -o nounset

echo "Remove doc deployment ${DEPLOYMENT_NAME} from the server"

# testing this locally:
# source .env && export $(cut -d= -f1 .env) && ./delete_deployment.sh

curl --fail --show-error -v \
    --data '{"update_key":"'"${TARANTOOL_UPDATE_KEY}"'"}' \
    --header "Content-Type: application/json" \
    --request DELETE "${TARANTOOL_UPDATE_URL}""${DEPLOYMENT_NAME}"/

