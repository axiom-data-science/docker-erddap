# ERDDAP on Docker

A feature full Tomcat (SSL over APR, etc.) running [ERDDAP](http://coastwatch.pfeg.noaa.gov/erddap/index.html)

Available versions:

* `axiom/docker-erddap:latest`
* `axiom/docker-erddap:2.10`
* `axiom/docker-erddap:2.02`
* `axiom/docker-erddap:1.82`
* `axiom/docker-erddap:1.80`

See all versions available [here](https://hub.docker.com/r/axiom/docker-erddap/tags). As always, consult the [ERDDAP Changes](https://coastwatch.pfeg.noaa.gov/erddap/download/changes.html) documentation before upgrading your sever.

The [upstream image](https://github.com/Unidata/tomcat-docker) this project uses replaces tagged images with new images periodcally. Even for release tags.
This makes it impossible for a downsteam project like this to maintain a reliable build process. At any point the upstream image may overwrite the base image
this repository uses with one that does not. It has happened at least 3 times so far. If you find a bug in any of the versions above please
[report it as an issue](https://github.com/axiom-data-science/docker-erddap/issues).
This repository will **not** back-port changes from the upstream image to existing tags and overwrite them. If you require features from a newer upstream image
(for example - SHA512 password hashes) you will have to wait for the next ERDDAP release which will be built with the newest upstream image.
You can also build this image yourself.

## Quickstart

```bash
$ docker run -d -p 8080:8080 axiom/docker-erddap
```

## Running ERDDAP CLI Tools

**GenerateDatasetsXml**

```bash
$ docker run --rm -it \
  -v $(pwd)/logs:/erddapData/logs \
  axiom/docker-erddap:latest \
  bash -c "cd webapps/erddap/WEB-INF/ && bash GenerateDatasetsXml.sh -verbose"
```


## Configuration

### Tomcat

See [these instructions for configuring Tomcat](https://github.com/unidata/tomcat-docker) from the Tomcat image this is built from (`unidata/tomcat-docker`).


### ERDDAP

1.  Mount your own `content/erddap` directory:

    ```bash
    $ docker run \
        -v /path/to/your/erddap/directory:/usr/local/tomcat/content/erddap \
        ... \
        axiom/docker-erddap
    ```

    Your content directory should contain a [setup.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#setup.xml) and [dataset.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html) file. It can also include CSS assets that you reference in your custom `setup.xml` file.

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
