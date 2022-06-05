#!/usr/bin/env bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" # https://stackoverflow.com/a/17744637

export DIALECT=db2

# This is local for the online workflow
mkdir -p Docker

if [ ! "$(sudo docker ps -q -f name=db2server)" ]; then
    if [ "$(sudo docker ps -aq -f status=exited -f name=db2server)" ]; 
	then
    # cleanup
    sudo docker rm -f db2server
		sudo rm -rf Docker
	fi
	# NOTE: consider adding --cpus and --memory options to improve performance
	sudo docker run -h db2server --name db2server --restart=always --detach --privileged=true -p 50000:50000 --env-file .env_list -v /Docker:/database ibmcom/db2-amd64:11.5.6.0a
	count=1
	while true
	do
	  if (sudo docker logs db2server | grep 'Setup has completed')
	  then	  
		sudo docker exec db2server bash -c "su db2inst1 & disown"
		break
	  fi
	  if ($count -gt 30); then
		echo "Error: Db2 docker setup has not completed in 10 minutes."
		break
	  fi
	  sleep 20
	  let "count=count+1"
	done

  DIALECT=db2 node ../../db-connection-check.js
  
  echo "Local DB2-11.5 instance is ready for Sequelize tests."
fi
