#!/bin/sh

if [ -f "${CATALINA_HOME}/bin/config.sh" ];
then
    set -o allexport
    source "${CATALINA_HOME}/bin/config.sh"
    set +o allexport
fi

ERDDAP_CONFIG=$(env | grep --regexp "^ERDDAP_.*$" | sort)
if [ -n "$ERDDAP_CONFIG" ]; then
    echo -e "ERDDAP configured with:\n$ERDDAP_CONFIG"
fi

JAVA_MAJOR_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)

# JAVA_OPTS
MEMORY="${ERDDAP_MEMORY:-4G}"
NORMAL="-server -Xms${ERDDAP_MIN_MEMORY:-${MEMORY}} -Xmx${ERDDAP_MAX_MEMORY:-${MEMORY}}"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"

EXTRAS=${JAVA_EXTRAS:-}
if [ $JAVA_MAJOR_VERSION -lt 9 ]; then
  #these options are deprecated in java 9 and illegal in java 14+
  EXTRAS="$EXTRAS -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled"
fi

CONTENT_ROOT="-DerddapContentDirectory=$CATALINA_HOME/content/erddap"
JNA_DIR="-Djna.tmpdir=/tmp/"
FASTBOOT="-Djava.security.egd=file:/dev/./urandom"

JAVA_OPTS="$JAVA_OPTS $NORMAL $HEAP_DUMP $HEADLESS $EXTRAS $CONTENT_ROOT/ $JNA_DIR $FASTBOOT"
echo "ERDDAP Running with: $JAVA_OPTS"
