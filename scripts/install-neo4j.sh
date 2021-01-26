#!/usr/bin/env bash

yes | sudo apt-get install fdupes unzip

cache=.download_cache

get_latest_download() {
  cd $cache
  latest_download="$(ls -r $1 | head -1)"
  echo "THERE: $latest_download :THERE"
  cd ..
}

download_and_get_latest() {
  get_latest_download $2*

  echo "HERE: $latest_download :HERE"
  if [ ! "$latest_download" ]; then
    wget $1/$2 -P $cache
    get_latest_download $2*
  fi
}

delete_cache_duplicates(){
  fdupes -rdN $cache
}

if [ ! -f ../.env ]
then
  export $(cat .env | xargs)
fi

set -xe

if [ ! -d "neo4j/data/databases/graph.db" ]; then
    if [ ! -L neo4j ]; then
      mkdir -p -- neo4j
      mkdir -p -- $cache
    fi
    neo4j=neo4j-$NEO4J_DIST-$NEO4J_VERSION-unix.tar.gz 
    download_and_get_latest dist.neo4j.org $neo4j

    sudo tar -xzf $cache/$latest_download -C neo4j --strip-components 1

    neo4j/bin/neo4j-admin set-default-admin $NEO4J_USER
    neo4j/bin/neo4j-admin set-initial-password $NEO4J_PASSWORD

    apoc=apoc-$APOC_VERSION-all.jar
    download_and_get_latest https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/$APOC_VERSION $apoc
    cp $cache/$apoc ./neo4j/plugins/$apoc
    
    recommendations=recommendations.db.zip
    download_and_get_latest https://datastores.s3.amazonaws.com/recommendations/v$DATASTORE_VERSION $recommendations

    unzip -o $cache/$latest_download
    delete_cache_duplicates
    mv recommendations.db neo4j/data/databases/graph.db
    rm __MACOSX* -r
else
    echo "Database is already installed, skipping"
fi