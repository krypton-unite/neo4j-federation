#!/bin/bash

source=${BASH_SOURCE[0]}
. $(dirname $source)/helpers/get_source_data.sh $source

. $this_dir/load_env_vars.sh
load_env_vars

echo "Waiting up to 2 minutes for graphql http port ($HTTP_PORT)"

. $this_dir/helpers/get_local_host.sh
for i in {1..120};
    do
        nc -z "$(get_local_host)" $HTTP_PORT
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