#!/usr/local/bin/bash

yes | sudo apt-get install fdupes unzip

cache=.download_cache

get_latest_download() {
  cd $cache
  { # try
      latest_download="$(ls -r $1 | head -1)"
      #save your output
  } || { # catch
      # save log for exception
      latest_download=()
  }
  cd ..
}

download_and_get_latest() {
  get_latest_download $2*

  file_to_download=()
  if [ ! "$latest_download" ]; then
    file_to_download=($1/$2)
  fi
}

delete_cache_duplicates(){
  fdupes -rdN $cache
}

. $(dirname $0)/load_env_vars.sh
load_env_vars

set -xe

if [ ! -d "neo4j/data/databases/graph.db" ]; then
    if [ ! -L neo4j ]; then
      mkdir -p -- neo4j
      mkdir -p -- $cache
    fi
    neo4j=neo4j-$NEO4J_DIST-$NEO4J_VERSION-unix.tar.gz 
    download_and_get_latest dist.neo4j.org $neo4j
    files_to_download=($file_to_download)

    apoc=apoc-$APOC_VERSION-all.jar
    download_and_get_latest https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/$APOC_VERSION $apoc
    files_to_download+=($file_to_download)

    recommendations=recommendations.db.zip
    download_and_get_latest https://datastores.s3.amazonaws.com/recommendations/v$DATASTORE_VERSION $recommendations
    files_to_download+=($file_to_download)

    if [ ${#files_to_download[@]} -gt 0 ]; then
      cd $cache
      echo ${files_to_download[@]} | xargs -n 1 -P 8 wget -q --show-progress
      cd ..
    fi

    delete_cache_duplicates # just in case

    get_latest_download $neo4j
    tar -xzf $cache/$latest_download -C neo4j --strip-components 1

    neo4j/bin/neo4j-admin set-default-admin $NEO4J_USER
    neo4j/bin/neo4j-admin set-initial-password $NEO4J_PASSWORD

    get_latest_download $apoc
    cp $cache/$latest_download ./neo4j/plugins/$apoc
    
    get_latest_download $recommendations
    unzip -o $cache/$latest_download
    mv recommendations.db neo4j/data/databases/graph.db
    rm __MACOSX* -r
else
    echo "Database is already installed, skipping"
fi