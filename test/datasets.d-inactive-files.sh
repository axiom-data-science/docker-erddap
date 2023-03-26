#!/bin/bash

# Check to make sure that datasets.d.sh elegantly removes datasets when they are removed from
# datasets.d (i.e. marks them as inactive). The expectation is that this script is run against
# a clean checkout of the codebase.

DIR="$( dirname -- "$BASH_SOURCE"; )";
cd "$DIR/.."

function wait_for_http_result() {
  DATASET_ID=$1
  RESULT=$2

  echo "Waiting for request for dataset ${DATASET_ID} to return ${RESULT}"
  while [ "$RESULT" != "$(docker compose exec erddap curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/erddap/info/$DATASET_ID/index.json")" ]; do
    sleep 2
  done
}

function reload_erddap_config() {
  FLAG_DATASET="${1:-trees}"
  #regenerate datasets.xml
  docker compose exec erddap /datasets.d.sh -w
  #reload a dataset
  docker compose exec erddap touch /erddapData/flag/${FLAG_DATASET}
}

export COMPOSE_FILE="$(pwd)/examples/docker-compose.yml"

echo "Removing old compose stack if present"
docker compose down -v
echo "Building erddap-docker and starting compose stack"
docker compose up --build -d
docker compose ps -a

#verify that initial erddap config contains trees dataset
echo "Verifying initial dataset (trees)"
wait_for_http_result trees 200

#copy trees dataset config to trees2 and verify it gets added
echo "Creating duplicate dataset (trees2)"
cp "$(pwd)/examples/datasets.d/trees.csv.xml" "$(pwd)/examples/datasets.d/trees2.csv.xml"
xmlstarlet edit --inplace --update "/dataset/@datasetID" --value "trees2" "$(pwd)/examples/datasets.d/trees2.csv.xml"
reload_erddap_config trees2
wait_for_http_result trees2 200

#delete trees2 dataset config and verify that it gets removed
echo "Removing duplicate dataset (trees2)"
rm "$(pwd)/examples/datasets.d/trees2.csv.xml"
reload_erddap_config trees2
wait_for_http_result trees2 404
wait_for_http_result trees 200

#verify that there are no orphan datasets
if docker compose exec erddap curl -sS "http://localhost:8080/erddap/status.html" | grep Orphan; then
  echo "🚫 orphan dataset(s) detected, something went wrong"
  exit 1
else
  echo "✅ no orphan datasets(s) detected, all good!"
  exit 0
fi
