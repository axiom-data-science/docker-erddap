#!/bin/bash
#datasets.d datasets.xml generator
#If /datasets.d exists, concatenate all *.xml files found in the
#hierarchy into a generated datasets.xml file. Scan for environment
#variables prefixed with ERDDAP_DATASETS_ and use the values to set
#top level datasets.xml elements (e.g. cacheMinutes)
#See ERDDAP docs at https://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html
#for a thorough description of the datasets.xml format.

DATASETSD_DIR="${DATASETSD_DIR:-/datasets.d}"
DATASETSD_OUTPUT_PATH="${DATASETSD_OUTPUT_PATH:-/usr/local/tomcat/content/erddap/datasets.xml}"
DATASETSD_MARK_REMOVED_DATASETS_INACTIVE="${DATASETSD_MARK_REMOVED_DATASETS_INACTIVE:-0}"
DATASETSD_WRITE_TO_OUTPUT_PATH="${DATASETSD_WRITE_TO_OUTPUT_PATH:-0}"
DATASETSD_REFRESH_MISSING_DATASETS="${DATASETSD_REFRESH_MISSING_DATASETS:-0}"
while getopts ":d:io:rw" opt; do
  case ${opt} in
    d )
      DATASETSD_DIR="$OPTARG"
      ;;
    i )
      DATASETSD_MARK_REMOVED_DATASETS_INACTIVE=1
      ;;
    o )
      DATASETSD_OUTPUT_PATH="$OPTARG"
      ;;
    r )
      DATASETSD_REFRESH_MISSING_DATASETS=1
      ;;
    w )
      DATASETSD_WRITE_TO_OUTPUT_PATH=1
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

if [ ! -d "${DATASETSD_DIR}" ]; then
  echo "${DATASETSD_DIR} doesn't exist or isn't a directory, exiting" >&2
  exit 1
fi

#generate datasets.xml content from constituent datasets fragments in datasets.d directory
#run dataset fragments through xmlstarlet to remove xml declarations and catch other problems
DXML=$(echo "<erddapDatasets>$(find ""${DATASETSD_DIR}"" -name '*.xml' -type f -print0 | sort -z | xargs -0 xmlstarlet edit --omit-decl)</erddapDatasets>")

#set top level datasets.xml config with ERDDAP_DATASETS_* env vars
while read -r e; do
  k=$(echo "$e" | cut -d= -f1);
  v=$(echo "$e" | cut -d= -f2-);
  DXML=$(echo "$DXML" | xmlstarlet edit --inplace --subnode /erddapDatasets --type elem --name "$k" --value "$v")
done < <(env | grep -oP '(?<=^ERDDAP_DATASETS_).*')

#mark removed datasets as inactive
if [ "$DATASETSD_MARK_REMOVED_DATASETS_INACTIVE" == "1" ] && [ -n "$DATASETSD_OUTPUT_PATH" ] && [ -f "$DATASETSD_OUTPUT_PATH" ]; then
  #previous version of the target datasets.xml file exists,
  #if any datasets there not marked inactive are missing from our generated file
  #add them as inactive datasets so ERDDAP can cleanly make them inactive
  #https://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html#active
  while read -r inactive_dataset; do
    DXML=$(echo "$DXML" | xmlstarlet edit -P -s /erddapDatasets --type elem --name inactiveDataset -v "" \
      -i //inactiveDataset -t attr -n "datasetID" -v "${inactive_dataset}" \
      -i //inactiveDataset -t attr -n "active" -v "false" \
      -r //inactiveDataset -v dataset)
  done < <(comm -13 <(echo "$DXML" | xmlstarlet select -t -v "//erddapDatasets/dataset/@datasetID" | sort) \
    <(<"$DATASETSD_OUTPUT_PATH" xmlstarlet select -t -v "//erddapDatasets/dataset[not(@active='false')]/@datasetID" | sort))
  true
fi

#empty edit for formatting
DXML=$(echo "$DXML" | xmlstarlet edit --inplace)

#write output to target file if one was provided and write to stdout flag was not provided
if [ -n "$DATASETSD_OUTPUT_PATH" ] && [ "$DATASETSD_WRITE_TO_OUTPUT_PATH" == "1" ]; then
  echo "$DXML" > "$DATASETSD_OUTPUT_PATH"
  #set refresh flags for any datasetIDs in datasets.xml that are not in the running ERDDAP config if the refresh option was set
  if [ -n "$DATASETSD_REFRESH_MISSING_DATASETS" ] && [ "$DATASETSD_REFRESH_MISSING_DATASETS" == "1" ]; then
    comm -23 \
      <(xmlstarlet select -t -v "/erddapDatasets/dataset/@datasetID" "$DATASETSD_OUTPUT_PATH" | sort) \
      <(curl -sS "http://localhost:8080/erddap/tabledap/allDatasets.csv0?datasetID" | grep -v "^allDatasets$" | sort) \
      | xargs -I{} touch /erddapData/flag/{}
  fi
else
  echo "$DXML"
fi
