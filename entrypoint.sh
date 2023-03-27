#!/bin/bash
set -e

# preferable to fire up Tomcat via start-tomcat.sh which will start Tomcat with
# security manager, but inheriting containers can also start Tomcat via
# catalina.sh

if [ "$1" = 'start-tomcat.sh' ] || [ "$1" = 'catalina.sh' ]; then
    # generate random flagKeyKey if not set
    if [ -z "$ERDDAP_flagKeyKey" ] && grep "<flagKeyKey>CHANGE THIS TO YOUR FAVORITE QUOTE</flagKeyKey>" \
        "${CATALINA_HOME}/content/erddap/setup.xml" &> /dev/null; then
      echo "flagKeyKey isn't properly set. Generating a random value." >&2
      export ERDDAP_flagKeyKey=$(cat /proc/sys/kernel/random/uuid)
    fi

    USER_ID=${TOMCAT_USER_ID:-1000}
    GROUP_ID=${TOMCAT_GROUP_ID:-1000}

    ###
    # Tomcat user
    ###
    groupadd -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat \
        -d ${CATALINA_HOME} -s /sbin/nologin -c "Tomcat user" tomcat

    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    # Restrict permissions on conf
    ###

    chown -R tomcat:tomcat ${CATALINA_HOME} && chmod 400 ${CATALINA_HOME}/conf/*
    chown -R tomcat:tomcat /erddapData
    sync

    ###
    # Deactivate CORS filter in web.xml if DISABLE_CORS=1
    # Useful if CORS is handled outside of Tomcat (e.g. in a proxying webserver like nginx)
    ###
    if [ "$DISABLE_CORS" == "1" ]; then
      echo "Deactivating Tomcat CORS filter"
      xmlstarlet edit --inplace --delete '//_:filter[./_:filter-name = "CorsFilter"]' \
        --delete '//_:filter-mapping[./_:filter-name = "CorsFilter"]' "${CATALINA_HOME}/conf/web.xml"
    fi

    ###
    # Add datasets in /datasets.d to datasets.xml
    ###
    if [ -d "/datasets.d" ]; then
      echo "Creating datasets.xml from /datasets.d"
      ERDDAP_CONTENT_DIR="/usr/local/tomcat/content/erddap"
      DATASETS_XML="${ERDDAP_CONTENT_DIR}/datasets.xml"
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
      /datasets.d.sh -o "$DATASETS_XML" -w
    fi

    ###
    # Run executables/shell scripts in /init.d on each container startup
    # Inspired by postgres' /docker-entrypoint-initdb.d
    # https://github.com/docker-library/docs/blob/master/postgres/README.md#initialization-scripts
    # https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh#L156
    ###
    if [ -d "/init.d" ]; then
      for f in /init.d/*; do
        if [ -x "$f" ]; then
          echo "Executing $f"
          "$f"
        elif [[ $f == *.sh ]]; then
          echo "Sourcing $f (not executable)"
          . "$f"
        fi
      done
    fi

    exec gosu tomcat "$@"
fi

exec "$@"
