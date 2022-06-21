#!/bin/bash
#datasets.d datasets.xml generator
#If /datasets.d exists, concatenate all *.xml files found in the
#hierarchy into a generated datasets.xml file. Scan for environment
#variables prefixed with ERDDAP_DATASETS_ and use the values to set
#top level datasets.xml elements (e.g. cacheMinutes)
#See ERDDAP docs at https://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html
#for a thorough description of the datasets.xml format.

DATASETS_DIR=${1:-/datasets.d}

if [ ! -d "${DATASETS_DIR}" ]; then
  echo "${DATASETS_DIR} doesn't exist or isn't a directory, exiting" >&2
  exit 1
fi

DXML=$(echo "<erddapDatasets>$(find ""${DATASETS_DIR}"" -name '*.xml' -type f -print0 | sort -z | xargs -0 cat)</erddapDatasets>")
#set top level datasets.xml config with ERDDAP_DATASETS_* env vars
#env | grep -oP '(?<=^ERDDAP_DATASETS_).*' | while read -r e; do
#  k=$(echo "$e" | cut -d= -f1);
#  v=$(echo "$e" | cut -d= -f2-);
#  DXML=$(echo "$DXML" | xmlstarlet edit --inplace --subnode /erddapDatasets --type elem --name "$k" --value "$v")
#done
while read -r e; do
  k=$(echo "$e" | cut -d= -f1);
  v=$(echo "$e" | cut -d= -f2-);
  DXML=$(echo "$DXML" | xmlstarlet edit --inplace --subnode /erddapDatasets --type elem --name "$k" --value "$v")
done < <(env | grep -oP '(?<=^ERDDAP_DATASETS_).*')

#empty edit for formatting
echo "$DXML" | xmlstarlet edit --inplace
