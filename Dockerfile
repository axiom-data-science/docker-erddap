ARG ERDDAP_VERSION=v2.29.0
ARG BASE_IMAGE=erddap/erddap:$ERDDAP_VERSION
FROM $BASE_IMAGE

RUN apt-get update && apt-get install -y gettext-base xmlstarlet \
    && rm -rf /var/lib/apt/lists/*

COPY datasets.d.sh /

# advise users to use upstream offical ERDDAP docker image
# if they aren't using experimental features in this image
COPY --chmod=755 <<EOF /init.d/00-advise-upstream.sh
#/bin/sh
cat <<EOF2

███████ ██████  ██████  ██████   █████  ██████  
██      ██   ██ ██   ██ ██   ██ ██   ██ ██   ██ 
█████   ██████  ██   ██ ██   ██ ███████ ██████  
██      ██   ██ ██   ██ ██   ██ ██   ██ ██      
███████ ██   ██ ██████  ██████  ██   ██ ██      

NOTE: As of version v2.27.0 this image (axiom/docker-erddap)
is derived from the official ERDDAP Docker image (erddap/erddap).

If you are not using any experimental functionality offered
by the axiom image (notably datasets.d), you are recommended
to use the official ERDDAP Docker image instead.

See https://hub.docker.com/r/erddap/erddap for more details.                                                

EOF2
EOF

COPY --chmod=755 <<'EOF' /init.d/50-datasets.d.sh
#/bin/sh
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
EOF

ENV ERDDAP_useHeadersForUrl=true \
    ERDDAP_useSaxParser=true
