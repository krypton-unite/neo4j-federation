#!/bin/bash

source=${BASH_SOURCE[0]}
. $(dirname $source)/helpers/get_source_data.sh $source

. $this_dir/load_env_vars.sh
load_env_vars

./neo4j/bin/neo4j stop
rm -r neo4j/data/databases/graph.db
./neo4j/bin/neo4j start

echo "Waiting up to 2 minutes for neo4j bolt port ($BOLT_PORT)"

. $(dirname $0)/helpers/get_local_host.sh
for i in {1..120};
    do
        nc -z "$(get_local_host)" $BOLT_PORT
        is_up=$?
        if [ $is_up -eq 0 ]; then
            echo
            echo "Successfully started, neo4j bolt available on $BOLT_PORT"
            break
        fi
        sleep 1
        echo -n "."
done
echo
# Wait a further 5 seconds after the port is available
sleep 5