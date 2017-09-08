# ERDDAP on Docker

A feature full Tomcat (SSL over APR, etc.) running [ERDDAP](http://coastwatch.pfeg.noaa.gov/erddap/index.html)

Available versions:

* `axiom/docker-erddap:1.80`
* `axiom/docker-erddap:1.78`
* `axiom/docker-erddap:1.74` - first release based on `unidata/tomcat-docker`
* `axiom/docker-erddap:1.72`
* `axiom/docker-erddap:1.68`
* `axiom/docker-erddap:1.66`
* `axiom/docker-erddap:1.64`

## Quickstart

```bash
$ docker run -d -p 8080:8080 axiom/docker-erddap
```


## Configuration

### Tomcat

See [these instructions for configuring Tomcat](https://github.com/unidata/tomcat-docker).


### ERDDAP

1.  Mount your own `content/erddap` directory:

    ```bash
    $ docker run \
        -v /path/to/your/erddap/directory:/usr/local/tomcat/content/erddap \
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
        -v /path/to/your/setup.xml:/usr/local/tomcat/content/erddap/setup.xml \
        -v /path/to/your/datasets.xml:/usr/local/tomcat/content/erddap/datasets.xml \
        ... \
        axiom/docker-erddap
    ```

    **Any custom setup.xml needs to specify `<bigParentDirectory>/erddapData/</bigParentDirectory>`**


2.  Mount your own `bigParentDirectory`:

    ```bash
    $ docker run \
        -v /path/to/your/erddap/bigParentDirectory:/erddapData \
        ... \
        axiom/docker-erddap
    ```

    This is **highly** recommended, or nothing will persist across container restarts (logs/cache/etc.)
