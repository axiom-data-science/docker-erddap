#!/bin/bash
set -e

# preferable to fire up Tomcat via start-tomcat.sh which will start Tomcat with
# security manager, but inheriting containers can also start Tomcat via
# catalina.sh

if [ "$1" = 'start-tomcat.sh' ] || [ "$1" = 'catalina.sh' ]; then

    USER_ID=${TOMCAT_USER_ID:-1000}
    GROUP_ID=${TOMCAT_GROUP_ID:-1000}

    ###
    # Tomcat user
    ###
    getent group tomcat | groupadd -r tomcat -g ${GROUP_ID} && \
    id -u ${USER_ID} &> /dev/null || useradd -u ${USER_ID} -g tomcat \
        -d ${CATALINA_HOME} -s /sbin/nologin -c "Tomcat user" tomcat

    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    # Restrict permissions on conf
    ###

    chown -R tomcat:tomcat ${CATALINA_HOME} && chmod 400 ${CATALINA_HOME}/conf/*
    chown -R tomcat:tomcat /erddapData
    sync

    ###
    # Add datasets in /datasets.d to datasets.xml
    ###
    ERDDAP_CONTENT_DIR="/usr/local/tomcat/content/erddap"
    DATASETS_XML="${ERDDAP_CONTENT_DIR}/datasets.xml"
    if [ -d "/datasets.d" ]; then
      if [ -f "$DATASETS_XML" ]; then
        #datasets.xml exists, make sure we have a backup of it
        DATASETS_XML_MD5SUM=$(md5sum "$DATASETS_XML" | awk '{print $1}')
        if ! md5sum "${ERDDAP_CONTENT_DIR}/datasets.xml.*.bak" 2>/dev/null | grep -q "$DATASETS_XML_MD5SUM"; then
          #we don't have a backup of this version of datasets.xml yet, make one
          DATASETS_XML_BACKUP="${ERDDAP_CONTENT_DIR}"/datasets.xml.$(date -u +"%Y%m%dT%H%M%SZ").bak
          echo "Backing up "${DATASETS_XML}" to ${DATASETS_XML_BACKUP}"
          cp "$DATASETS_XML" "${DATASETS_XML_BACKUP}"
        fi
      fi
      echo "Creating ""$DATASETS_XML"" from /datasets.d"
      echo "<erddapDatasets>$(find /datasets.d -name '*.xml' -type f -print0 | sort -z | xargs -0 cat)</erddapDatasets>" \
        > "${DATASETS_XML}"

      #set top level datasets.xml config with ERDDAP_DATASETS_* env vars
      env | grep -oP '(?<=^ERDDAP_DATASETS_).*' | while read -r e; do
        k=$(echo "$e" | cut -d= -f1);
        v=$(echo "$e" | cut -d= -f2-);
        xmlstarlet edit --inplace --subnode /erddapDatasets --type elem --name "$k" --value "$v" "${DATASETS_XML}"
      done

      #empty edit for formatting
      xmlstarlet edit --inplace "${DATASETS_XML}"
    fi

    exec gosu tomcat "$@"
fi

exec "$@"
