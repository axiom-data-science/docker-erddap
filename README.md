# ERDDAP on Docker

A feature full Tomcat (SSL over APR, etc.) running [ERDDAP](http://coastwatch.pfeg.noaa.gov/erddap/index.html)

Available versions:

* `axiom/docker-erddap` (latest stable release)
* `axiom/docker-erddap:1.64`

## tl;dr

**Quickstart**

```bash
$ docker run \
    -d \
    -p 80:8080 \
    -p 443:8443 \
    axiom/docker-erddap
```

**Production**

```bash
$ docker run \
    -d \
    -p 80:8080 \
    -p 443:8443 \
    -v /path/to/your/ssl.crt:/opt/tomcat/conf/ssl.crt \
    -v /path/to/your/ssl.key:/opt/tomcat/conf/ssl.key \
    -v /path/to/your/tomcat-users.xml:/opt/tomcat/conf/tomcat-users.xml \
    -v /path/to/your/erddap/content:/opt/tomcat/content/erddap \
    -v /path/to/your/erddap/bigParentDirectory:/erddapData \
    --name erddap \
    axiom/docker-erddap
```

## Configuration

### Ports

Tomcat runs with two ports open

* 8080 - HTTP
* 8443 - HTTPS

Map the ports to local ports to access outside of the Docker ecosystem:
```bash
$ docker run \
    -p 80:8080 \
    -p 443:8443 \
    ... \
    axiom/docker-erddap
```


### JVM

By default, the JVM is run with the following options:

* `-server` - server optimized jvm
* `-d64` - 64-bit jvm
* `-Xms4G` - reserve 4g of RAM
* `-Xmx4G` - use a max of 4g of RAM
* `-XX:MaxPermSize=256m` - increase perm size
* `-XX:+HeapDumpOnOutOfMemoryError` -  nice log dumps on out of memory errors
* `-Djava.awt.headless=true` - headless (no monitor)

A custom JVM options file may be used but must `export JAVA_OPTS` at the end
and include any already defined `JAVA_OPTS`, like so:

```bash
#!/bin/sh
NORMAL="-server -d64 -Xms16G -Xmx16G"  # More memory
MAX_PERM_GEN="-XX:MaxPermSize=128m"    # Less Perm
HEADLESS="-Djava.awt.headless=true"    # Still headless
JAVA_OPTS="$JAVA_OPTS $NORMAL $MAX_PERM_GEN $HEADLESS"
export JAVA_OPTS
```

Mount your own `javaopts.sh`:

```bash
$ docker run \
    -v /path/to/your/javaopts.sh:/opt/tomcat/bin/javaopts.sh \
    ... \
    axiom/docker-erddap
```


### ERDDAP


Mount your own `content/erddap` directory:

```bash
$ docker run \
    -v /path/to/your/erddap/directory:/opt/tomcat/content/erddap \
    ... \
    axiom/docker-erddap
```

Your content directory should contain all necessary files:
* `setup.xml`
* `datasets.xml`
* `images/erddapAlt.css`
* `images/erddapStart.css`

If you just want to change [setup.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#setup.xml) and [dataset.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html), you can mount them individually:

```bash
$ docker run \
    -v /path/to/your/setup.xml:/opt/tomcat/content/erddap/setup.xml \
    -v /path/to/your/datasets.xml:/opt/tomcat/content/erddap/datasets.xml \
    ... \
    axiom/docker-erddap
```

**Any custom setup.xml needs to specify `<bigParentDirectory>/erddapData/</bigParentDirectory>`**


Mount your own `bigParentDirectory`:

```bash
$ docker run \
    -v /path/to/your/erddap/bigParentDirectory:/erddapData \
    ... \
    axiom/docker-erddap
```

This is **highly** recommended, or nothing will persist across container restarts (logs/cache/etc.)


### Tomcat Users

By default, Tomcat will start a single `admin` user account. The passwords is equal to the user name.

```xml
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">

  <role rolename="admin-gui"/>
  <role rolename="admin-script"/>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="manager-jmx"/>
  <role rolename="manager-status"/>

  <user username="admin"
        password="d033e22ae348aeb5660fc2140aec35850c4da997"
        roles="manager-gui,manager-script,manager-jmx,manager-status,admin-script,admin-gui"/>

</tomcat-users>

```

**You need to mount your own `tomcat-users.xml` file with different SHA1 digested passwords**.
If not, anyone who reads this document and knows your server address will have admin Tomcat privileges.

Mount your own `tomcat-users.xml`:

```bash
$ docker run \
    -v /path/to/your/tomcat-users.xml:/opt/tomcat/conf/tomcat-users.xml \
    ... \
    axiom/docker-erddap
```


### SSL

By default, Tomcat will start with a self-signed certificate valid for 3650 days.
This certificate **does not change on run**, so if you are serious about SSL, you
should mount your own private key and certificate files.

Mount your own `ssl.crt` and `ssl.key`:

```bash
$ docker run \
    -v /path/to/your/ssl.crt:/opt/tomcat/conf/ssl.crt \
    -v /path/to/your/ssl.key:/opt/tomcat/conf/ssl.key \
    ... \
    axiom/docker-erddap
```
