#!/bin/bash

#update Tomcat's server.xml with configuration required to serve ERDDAP
#this is typically run in the Dockerfile to ensure that the upstream
#server.xml meets our needs regardless of the Tomcat base image

SERVER_XML=${SERVER_XML:-/usr/local/tomcat/conf/server.xml}

if [ ! -f "$SERVER_XML" ]; then
  echo "$SERVER_XML doesn't exist" >&2
  exit 1
fi

RELAXED_PATH_CHARS="[]|"
RELAXED_QUERY_CHARS="[]:|{}^&#x5c;&#x60;&quot;&lt;&gt;"

function set_attribute {
  ELEM="$1"
  ATTR="$2"
  VAL="$3"
  if [ -z "$(xmlstarlet sel -t -c "${ELEM}[@${ATTR}='${VAL}']" $SERVER_XML)" ]; then
    #xmlstarlet escapes special characters like & when writing values, and we
    #want the attributes to be exactly as we define them. insert replacement
    #target tokens instead, and then replace with sed.
    #ampersands are also special characters in sed, so replace with ~ first
    #and then replace again back to &
    TOKEN="__${ATTR}__"
    xmlstarlet edit --inplace -P -u "${ELEM}/@${ATTR}" -v "${TOKEN}" \
      -i "${ELEM}[not(@${ATTR})]" -t attr -n "${ATTR}" -v "${TOKEN}" \
      $SERVER_XML
    sed -i -e "s/${TOKEN}/$( echo $VAL | tr '&' '~')/" -e "s/~/\&/g" $SERVER_XML
  fi
}

#set Connector relaxedPathChars and relaxedQueryChars to allow DAP queries
set_attribute /Server/Service/Connector relaxedPathChars "$RELAXED_PATH_CHARS"
set_attribute /Server/Service/Connector relaxedQueryChars "$RELAXED_QUERY_CHARS"

#create RemoteIpValve if missing. this is needed so ERDDAP knows when its responding to https requests
#end result should look like:
#<Valve className="org.apache.catalina.valves.RemoteIpValve"
#  remoteIpHeader="X-Forwarded-For"
#  protocolHeader="X-Forwarded-Proto"
#  protocolHeaderHttpsValue="https" />
#https://stackoverflow.com/a/9172796/193435
if [ -z "$(xmlstarlet sel -t -c "/Server/Service/Engine/Host/Valve[@className='org.apache.catalina.valves.RemoteIpValve']" $SERVER_XML)" ]; then
  xmlstarlet edit --inplace -P -s /Server/Service/Engine/Host -t elem -n RemoteIpValve -v "" \
    -i //RemoteIpValve -t attr -n "className" -v "org.apache.catalina.valves.RemoteIpValve" \
    -i //RemoteIpValve -t attr -n "remoteIpHeader" -v "X-Forwarded-For" \
    -i //RemoteIpValve -t attr -n "protocolHeader" -v "X-Forwarded-Proto" \
    -i //RemoteIpValve -t attr -n "protocolHeaderHttpsValue" -v "https" \
    -r //RemoteIpValve -v Valve \
    $SERVER_XML
fi
