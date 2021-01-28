#!/bin/bash

source=${BASH_SOURCE[0]}
. $(dirname $source)/get_source_data.sh $source
echo $this_source
echo $this_dir