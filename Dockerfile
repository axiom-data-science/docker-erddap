FROM unidata/tomcat-docker:8.5@sha256:7f49c2631469dc4f7f4c9c4847ebcec03c8db41e9ef5f9028296f6391ff8dc0c
LABEL maintainer="Kyle Wilcox <kyle@axiomdatascience.com>"

ENV ERDDAP_VERSION 2.10
ENV ERDDAP_CONTENT_URL https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddapContent.zip
ENV ERDDAP_WAR_URL https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddap.war
ENV ERDDAP_DATA /erddapData

RUN \
    curl -fSL "${ERDDAP_CONTENT_URL}" -o /erddapContent.zip && \
    unzip /erddapContent.zip -d ${CATALINA_HOME} && \
    rm /erddapContent.zip && \
    curl -fSL "${ERDDAP_WAR_URL}" -o /erddap.war && \
    unzip /erddap.war -d ${CATALINA_HOME}/webapps/erddap/ && \
    rm /erddap.war && \
    sed -i 's#</Context>#<Resources cachingAllowed="true" cacheMaxSize="100000" />\n&#' ${CATALINA_HOME}/conf/context.xml && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p ${ERDDAP_DATA}

# Java options
COPY files/setenv.sh ${CATALINA_HOME}/bin/setenv.sh

# ERDDAP setup.xml
COPY files/setup.xml ${CATALINA_HOME}/content/erddap/setup.xml

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
CMD ["catalina.sh", "run"]
