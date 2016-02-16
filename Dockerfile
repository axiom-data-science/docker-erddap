FROM axiom/docker-tomcat:8.0
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>

RUN \
    apt-get update && \
    apt-get install -y unzip

# Install BitstreamVeraSans font
RUN curl -fSL "http://coastwatch.pfeg.noaa.gov/erddap/download/BitstreamVeraSans.zip" -o BitstreamVeraSans.zip
RUN unzip BitstreamVeraSans.zip -d /usr/lib/jvm/java-8-oracle/jre/lib/fonts/

ENV ERDDAP_VERSION 1.68

# Install ERDDAP content zip
ENV ERDDAP_CONTENT_URL http://coastwatch.pfeg.noaa.gov/erddap/download/erddapContent.zip
#ENV ERDDAP_CONTENT_URL http://coastwatch.pfeg.noaa.gov/erddap/download/erddapContent$ERDDAP_VERSION.zip
RUN curl -fSL "$ERDDAP_CONTENT_URL" -o erddapContent.zip
RUN unzip erddapContent.zip -d $CATALINA_HOME

# Install ERDDAP WAR
ENV ERDDAP_WAR_URL http://coastwatch.pfeg.noaa.gov/erddap/download/erddap.war
#ENV ERDDAP_WAR_URL http://coastwatch.pfeg.noaa.gov/erddap/download/erddap$ERDDAP_VERSION.war
RUN curl -fSL "$ERDDAP_WAR_URL" -o $CATALINA_HOME/webapps/erddap-$ERDDAP_VERSION.war
RUN mv $CATALINA_HOME/webapps/erddap-$ERDDAP_VERSION.war $CATALINA_HOME/webapps/erddap.war

# Java options
COPY files/javaopts.sh $CATALINA_HOME/bin/javaopts.sh
# ERDDAP setup.xml
COPY files/setup.xml $CATALINA_HOME/content/erddap/setup.xml

ENV ERDDAP_DATA /erddapData
RUN mkdir -p $ERDDAP_DATA
RUN chown -R tomcat:tomcat "$ERDDAP_DATA"
RUN chown -R tomcat:tomcat "$CATALINA_HOME"

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080 8443
CMD ["catalina.sh", "run"]
