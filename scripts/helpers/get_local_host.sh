#!/bin/bash
source=${BASH_SOURCE[0]}
. $(dirname $source)/get_source_data.sh $source

get_local_host(){
    localhost=$(perl $this_dir/regex.pl "$(cat /etc/resolv.conf)")
}
# echo "$(get_local_host)"