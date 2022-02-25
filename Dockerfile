FROM unidata/tomcat-docker:8.5@sha256:3cf99db8113eeea94a5f27dfa50f843a94ab7eaad373fd92e071e3afd912d44b
LABEL maintainer="Kyle Wilcox <kyle@axiomdatascience.com>"

ENV ERDDAP_VERSION 2.14
ENV ERDDAP_CONTENT_URL https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddapContent.zip
ENV ERDDAP_WAR_URL https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddap.war
ENV ERDDAP_bigParentDirectory /erddapData

RUN \
    curl -fSL "${ERDDAP_CONTENT_URL}" -o /erddapContent.zip && \
    unzip /erddapContent.zip -d ${CATALINA_HOME} && \
    rm /erddapContent.zip && \
    curl -fSL "${ERDDAP_WAR_URL}" -o /erddap.war && \
    unzip /erddap.war -d ${CATALINA_HOME}/webapps/erddap/ && \
    rm /erddap.war && \
    sed -i 's#</Context>#<Resources cachingAllowed="true" cacheMaxSize="100000" />\n&#' ${CATALINA_HOME}/conf/context.xml && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p ${ERDDAP_bigParentDirectory}

# Java options
COPY files/setenv.sh ${CATALINA_HOME}/bin/setenv.sh

# Default configuration
ENV ERDDAP_baseHttpsUrl="https://localhost:8443" \
    ERDDAP_flagKeyKey="73976bb0-9cd4-11e3-a5e2-0800200c9a66" \
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

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
CMD ["catalina.sh", "run"]
