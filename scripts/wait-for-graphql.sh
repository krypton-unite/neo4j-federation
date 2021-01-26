#!/usr/bin/env bash

. $(dirname $0)/load_env_vars.sh
load_env_vars

echo "Waiting up to 2 minutes for graphql http port ($HTTP_PORT)"

for i in {1..120};
    do
        nc -z $(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}') $HTTP_PORT
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