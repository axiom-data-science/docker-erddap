#!/bin/bash
set -e

if [ "$1" = 'catalina.sh' ]; then
    chown -R tomcat:tomcat .
    chown -R tomcat:tomcat /erddapData
    sync
    exec gosu tomcat "$@"
fi

exec "$@"
