#!/bin/bash

#Used to non-interactively generate a datasets.xml dataset configuration for ERDDAP
#using GenerateDatasetsXml.sh using all default values. The output
#of this script should be used as a starting point and must be populated
#with the correct values for the dataset
#
#Example usage:
#./make-datasets-xml.sh /path/to/my.csv EDDTableFromAsciiFiles

TARGET_FILE="$1"

if [ ! -f "$TARGET_FILE" ]; then
  echo "File ""$TARGET_FILE"" doesn't exist" >&2
  exit 1
fi

DATASET_TYPE=${2:-"EDDTableFromAsciiFiles"}

TARGET_FILENAME="$(basename ""$TARGET_FILE"")"

docker run --rm -v $(realpath "$TARGET_FILE"):/data_directory/data_file \
  --workdir /usr/local/tomcat/webapps/erddap/WEB-INF axiom/docker-erddap \
    bash ./GenerateDatasetsXml.sh ${DATASET_TYPE} /data_directory data_file $(yes '""' | head -n 18) \
  | sed -n '/^<dataset/,${p;/^<\/dataset/q}' \
  | xmlstarlet edit --omit-decl \
      --update "/dataset/fileNameRegex" --value "$TARGET_FILENAME" \
      --update "/dataset/@datasetID" --value "${TARGET_FILENAME%.*}" \
      --update "/dataset/recursive" --value "false" \
      --update "/dataset/addAttributes/att[@name='title']" --value "${TARGET_FILENAME}" \
      --update "/dataset/addAttributes/att[@name='summary']" --value "Generated dataset for ${TARGET_FILENAME}"
