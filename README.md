# ERDDAP on Docker

A feature full Tomcat (SSL over APR, etc.) running [ERDDAP](http://coastwatch.pfeg.noaa.gov/erddap/index.html)

Available versions:

* `axiom/docker-erddap` - `1.72`
* `axiom/docker-erddap:1.72`
* `axiom/docker-erddap:1.68`
* `axiom/docker-erddap:1.66`
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

### Tomcat

See [these instructions](https://github.com/axiom-data-science/docker-tomcat) for configuring Tomcat


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
