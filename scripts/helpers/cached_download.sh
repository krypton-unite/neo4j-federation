#!/bin/bash

this_path=$(dirname  $0)/helpers
. $this_path/cache.sh
. $this_path/download_files.sh
. $this_path/delete_duplicates.sh

cached_download(){
    # $1 download_info
    # $2 cache_folder
    local cache="$1"   # Save first argument in a variable
    shift            # Shift all arguments to the left (original $1 gets lost)
    local files_info=("$@") # Rebuild the array with rest of arguments
    get_list_of_files_to_download $cache "${files_info[@]}"
    download_files $cache "${files_to_download[@]}"
    delete_duplicates $cache # just in case
    cached_downloads=()
    local pattern='(.*):+(.*)'
    for file_info in ${files_info[@]}
    do
        [[ $file_info =~ $pattern ]]
        local file_name=${BASH_REMATCH[2]}
        get_latest_download $cache $file_name
        cached_downloads+=($cache/$latest_download)
    done
}