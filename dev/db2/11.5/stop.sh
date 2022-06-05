#!/usr/bin/env bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" # https://stackoverflow.com/a/17744637

sudo docker stop db2server
docker rm db2server
# docker-compose -p db2server down --remove-orphans

echo "Local DB2 instance stopped (if it was running)."
