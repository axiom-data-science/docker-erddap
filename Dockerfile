FROM unidata/tomcat-docker:8
MAINTAINER Kyle Wilcox <kyle@axiomdatascience.com>

RUN \
    apt-get update && \
    apt-get install -y unzip

# Install BitstreamVeraSans font
RUN curl -fSL "http://coastwatch.pfeg.noaa.gov/erddap/download/BitstreamVeraSans.zip" -o BitstreamVeraSans.zip
RUN unzip BitstreamVeraSans.zip -d $JRE_HOME/lib/fonts/

ENV ERDDAP_VERSION 1.74

# Install ERDDAP content zip
ENV ERDDAP_CONTENT_URL http://coastwatch.pfeg.noaa.gov/erddap/download/erddapContent.zip
#ENV ERDDAP_CONTENT_URL http://coastwatch.pfeg.noaa.gov/erddap/download/erddapContent$ERDDAP_VERSION.zip
RUN curl -fSL "$ERDDAP_CONTENT_URL" -o erddapContent.zip
RUN unzip erddapContent.zip -d $CATALINA_HOME

# Install ERDDAP WAR
ENV ERDDAP_WAR_URL https://github.com/BobSimons/erddap/releases/download/v$ERDDAP_VERSION/erddap.war
#ENV ERDDAP_WAR_URL http://coastwatch.pfeg.noaa.gov/erddap/download/erddap$ERDDAP_VERSION.war
RUN curl -fSL "$ERDDAP_WAR_URL" -o /erddap.war
RUN unzip /erddap.war -d $CATALINA_HOME/webapps/erddap/


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
