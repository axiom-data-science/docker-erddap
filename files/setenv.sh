#!/bin/sh

# JAVA_OPTS
MEMORY="4G"
NORMAL="-server -d64 -Xms$MEMORY -Xmx$MEMORY"
HEAP_DUMP="-XX:+HeapDumpOnOutOfMemoryError"
HEADLESS="-Djava.awt.headless=true"
EXTRAS="-XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled"
CONTENT_ROOT="-DerddapContentDirectory=$CATALINA_HOME/content/erddap"

JAVA_OPTS="$JAVA_OPTS $NORMAL $HEAP_DUMP $HEADLESS $EXTRAS $CONTENT_ROOT/"
echo "ERDDAP Running with: $JAVA_OPTS"
