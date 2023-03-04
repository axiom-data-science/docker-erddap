ARG BASE_IMAGE=unidata/tomcat-docker:10.1.0-jdk17-temurin-focal@sha256:99c083fd17d1f8d6c85a0f771039ffb4d2430ff7fd6dabea8eb50f2731328af8
FROM ${BASE_IMAGE}
LABEL maintainer="Kyle Wilcox <kyle@axiomdatascience.com>"

ARG ERDDAP_VERSION=2.23
ARG ERDDAP_CONTENT_URL=https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddapContent.zip
ARG ERDDAP_WAR_URL=https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddap.war
ENV ERDDAP_bigParentDirectory /erddapData

RUN apt-get update && apt-get install -y unzip xmlstarlet \
    && if ! command -v gosu &> /dev/null; then apt-get install -y gosu; fi \
    && rm -rf /var/lib/apt/lists/*

ARG BUST_CACHE=1
RUN \
    curl -fSL "${ERDDAP_CONTENT_URL}" -o /erddapContent.zip && \
    unzip /erddapContent.zip -d ${CATALINA_HOME} && \
    rm /erddapContent.zip && \
    curl -fSL "${ERDDAP_WAR_URL}" -o /erddap.war && \
    unzip /erddap.war -d ${CATALINA_HOME}/webapps/erddap/ && \
    rm /erddap.war && \
    sed -i 's#</Context>#<Resources cachingAllowed="true" cacheMaxSize="100000" />\n&#' ${CATALINA_HOME}/conf/context.xml && \
    rm -rf /tmp/* /var/tmp/* && \
    mkdir -p ${ERDDAP_bigParentDirectory}

# Java options
COPY files/setenv.sh ${CATALINA_HOME}/bin/setenv.sh

# server.xml fixup
COPY update-server-xml.sh /opt/update-server-xml.sh
RUN /opt/update-server-xml.sh

# Default configuration
# Note: Make sure ERDDAP_flagKeyKey is set either in a runtime environment variable or in setup.xml
#       If a value is not set, a random value for ERDDAP_flagKeyKey will be generated at runtime.
ENV ERDDAP_baseHttpsUrl="https://localhost:8443" \
    ERDDAP_emailEverythingTo="nobody@example.com" \
    ERDDAP_emailDailyReportsTo="nobody@example.com" \
    ERDDAP_emailFromAddress="nothing@example.com" \
    ERDDAP_emailUserName="" \
    ERDDAP_emailPassword="" \
    ERDDAP_emailProperties="" \
    ERDDAP_emailSmtpHost="" \
    ERDDAP_emailSmtpPort="" \
    ERDDAP_adminInstitution="Axiom Docker Install" \
    ERDDAP_adminInstitutionUrl="https://github.com/axiom-data-science/docker-erddap" \
    ERDDAP_adminIndividualName="Axiom Docker Install" \
    ERDDAP_adminPosition="Software Engineer" \
    ERDDAP_adminPhone="555-555-5555" \
    ERDDAP_adminAddress="123 Irrelevant St." \
    ERDDAP_adminCity="Nowhere" \
    ERDDAP_adminStateOrProvince="AK" \
    ERDDAP_adminPostalCode="99504" \
    ERDDAP_adminCountry="USA" \
    ERDDAP_adminEmail="nobody@example.com"

COPY entrypoint.sh datasets.d.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
CMD ["catalina.sh", "run"]
