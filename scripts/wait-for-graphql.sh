#!/bin/bash

. $(dirname $0)/load_env_vars.sh
load_env_vars

echo "Waiting up to 2 minutes for graphql http port ($HTTP_PORT)"

. $(dirname $0)/helpers/get_local_host.sh
get_local_host
for i in {1..120};
    do
        nc -z $localhost $HTTP_PORT
        is_up=$?
        if [ $is_up -eq 0 ]; then
            echo
            echo "Successfully started, graphql http available on $HTTP_PORT"
            break
        fi
        sleep 1
        echo -n "."
done
echo