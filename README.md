# ERDDAP on Docker

A feature full Tomcat (SSL over APR, etc.) running [ERDDAP](http://coastwatch.pfeg.noaa.gov/erddap/index.html)

Most recent versions:

* `axiom/docker-erddap:latest-jdk21-openjdk` (2.25)
* `axiom/docker-erddap:2.25-jdk21-openjdk`
* `axiom/docker-erddap:2.24-jdk21-openjdk`
* `axiom/docker-erddap:2.23-jdk17-openjdk`

See all versions available [here](https://hub.docker.com/r/axiom/docker-erddap/tags). As always, consult the [ERDDAP Changes](https://coastwatch.pfeg.noaa.gov/erddap/download/changes.html) documentation before upgrading your server.

Use any of the `latest-*` images with caution as they follow the upstream image, and is not as thoroughly tested as tagged images.

[Dependabot](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/keeping-your-dependencies-updated-automatically) is used to automatically make PRs to update the upstream image ([`.github/dependabot.yml`](.github/dependabot.yml)).

## Quickstart

```bash
docker run -d -p 8080:8080 axiom/docker-erddap:latest-jdk21-openjdk
```

## Running ERDDAP CLI Tools

### GenerateDatasetsXml

```bash
docker run --rm -it \
  -v $(pwd)/logs:/erddapData/logs \
  --workdir /usr/local/tomcat/webapps/erddap/WEB-INF \
  axiom/docker-erddap:latest \
  bash GenerateDatasetsXml.sh -verbose
```

or, generate a basic dataset configuration without input for
later customization

```bash
./make-dataset.xml /path/to/your.csv EDDTableFromAsciiFiles > /path/to/your-dataset.xml
```

## Configuration

### Tomcat

See [these instructions for configuring Tomcat](https://github.com/unidata/tomcat-docker) from the Tomcat image this image borrows from (`unidata/tomcat-docker`).

### CORS

The [Tomcat configuration](https://github.com/unidata/tomcat-docker) used by this image enables the
[Apache Tomcat CORS filter](https://tomcat.apache.org/tomcat-8.5-doc/config/filter.html#CORS_Filter) by
default. To disable it (maybe you want to handle CORS uniformly in a proxying webserver?), set environment
variable `DISABLE_CORS` to `1`.

### ERDDAP

Any number of these options can be taken to configure your ERDDAP container instance to your liking.

1. Mount your own `content/erddap` directory:

    ```bash
    docker run \
        -p 8080:8080 \
        -v /path/to/your/erddap/directory:/usr/local/tomcat/content/erddap \
        ... \
        axiom/docker-erddap
    ```

    Your content directory should contain a [setup.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#setup.xml) and [dataset.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html) file. It can also include CSS assets that you reference in your custom `setup.xml` file.

    If you just want to change [setup.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#setup.xml) and [dataset.xml](http://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html), you can mount them individually:

    ```bash
    $ docker run \
        -p 8080:8080 \
        -v /path/to/your/setup.xml:/usr/local/tomcat/content/erddap/setup.xml \
        -v /path/to/your/datasets.xml:/usr/local/tomcat/content/erddap/datasets.xml \
        ... \
        axiom/docker-erddap
    ```

    **If you mount setup.xml file make sure to set `<bigParentDirectory>/erddapData/</bigParentDirectory>`**

2. Configure using environmental variables

    You can set environmental variables to configure ERDDAP's `setup.xml` since version 2.14. See the [ERDDAP documentation](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#setupEnvironmentVariables) for details. This can be very useful so you don't need to mount a custom `setup.xml` file into your container. If taking this approach you should look into setting the following ERDDAP config options:

    * `ERDDAP_baseUrl`
    * `ERDDAP_baseHttpsUrl`
    * `ERDDAP_flagKeyKey`
    * `ERDDAP_emailEverythingTo`
    * `ERDDAP_emailFromAddress`
    * `ERDDAP_emailUserName`
    * `ERDDAP_emailPassword`
    * `ERDDAP_emailSmtpHost`
    * `ERDDAP_emailSmtpPort`
    * `ERDDAP_adminInstitution`
    * `ERDDAP_adminInstitutionUrl`
    * `ERDDAP_adminIndividualName`
    * `ERDDAP_adminPosition`
    * `ERDDAP_adminPhone`
    * `ERDDAP_adminAddress`
    * `ERDDAP_adminCity`
    * `ERDDAP_adminStateOrProvince`
    * `ERDDAP_adminPostalCode`
    * `ERDDAP_adminCountry`
    * `ERDDAP_adminEmail`

    For example:

    ```bash
    docker run \
        -p 8080:8080 \
        -e ERDDAP_baseURL="http://localhost:8080" \
        -e ERDDAP_adminEmail="set_via_container_env@example.com" \
        axiom/docker-erddap
    ```

    **Depending on your container environment, it may pass in it's own environment variables relating to your resources. Potentially there could be a collision with the `ERDDAP_*` config variables if any of your resources start with ERDDAP.**

3. Configure using a shell script

    You can mount a file called `config.sh` to `${CATALINA_HOME}/bin/config.sh` that sets any ERDDAP configuration environmental variables you want to use. This is sourced in the container-provided `setenv.sh` file and and all variables will be exported to be used by ERDDAP for configuration. These will take precedence over environmental variable specified when running the container (see above).

    ```bash
    $ docker run \
        -p 8080:8080 \
        -e ERDDAP_adminEmail="overridden_by_config_file@example.com" \
        -v /path/to/your/config.sh:/usr/local/tomcat/bin/config.sh \
        ... \
        axiom/docker-erddap
    ```

    where `config.sh` contains any of the ERDDAP environmental configuration variables:

    ```sh
    ERDDAP_adminEmail="this_is_used@example.com"
    ```

    You can set any number of configuration variables in the config.sh.

    ```bash
    ERDDAP_bigParentDirectory="/erddapData/"
    ERDDAP_baseUrl="http://localhost:8080"
    ERDDAP_baseHttpsUrl="https://localhost:8443"
    ERDDAP_flagKeyKey="73976bb0-9cd4-11e3-a5e2-0800200c9a66"

    ERDDAP_emailEverythingTo="nobody@example.com"
    ERDDAP_emailDailyReportTo="nobody@example.com"
    ERDDAP_emailFromAddress="nothing@example.com"
    ERDDAP_emailUserName=""
    ERDDAP_emailPassword=""
    ERDDAP_emailProperties=""
    ERDDAP_emailSmtpHost=""
    ERDDAP_emailSmtpPort=""

    ERDDAP_adminInstitution="Axiom Docker Install"
    ERDDAP_adminInstitutionUrl="https://github.com/axiom-data-science/docker-erddap"
    ERDDAP_adminIndividualName="Axiom Docker Install"
    ERDDAP_adminPosition="Software Engineer"
    ERDDAP_adminPhone="555-555-5555"
    ERDDAP_adminAddress="123 Irrelevant St."
    ERDDAP_adminCity="Nowhere"
    ERDDAP_adminStateOrProvince="AK"
    ERDDAP_adminPostalCode="99504"
    ERDDAP_adminCountry="USA"
    ERDDAP_adminEmail="nobody@example.com"
    ```

4. Mount your own `bigParentDirectory`:

    ```bash
    docker run \
        -p 8080:8080 \
        -v /path/to/your/erddap/bigParentDirectory:/erddapData \
        ... \
        axiom/docker-erddap
    ```

    This is **highly** recommended, or nothing will persist across container restarts (logs/cache/etc.)

5. Specify the amount of heap memory (using Java's `Xms` and `Xmx`) to be allocated:

    ``` bash
    docker run \
        -p 8080:8080 \
        --env ERDDAP_MEMORY=10G
        ... \
        axiom/docker-erddap
    ```

    You may also explicity set `ERDDAP_MIN_MEMORY` and `ERDDAP_MAX_MEMORY` value (these map to `Xms` and `Xmx` respectively),
    but generally the best practice is to set these to the same value to prevent costly heap resizing at runtime.

    ``` bash
    docker run \
        -p 8080:8080 \
        --env ERDDAP_MIN_MEMORY=8G --env ERDDAP_MAX_MEMORY=8G
        ... \
        axiom/docker-erddap
    ```

    Alternatively, you can set `ERDDAP_MAX_RAM_PERCENTAGE` set the maximum Java heap size to a percentage of the memory available to the container. This option sets the JVM option `-XX:MaxRAMPercentage`. For example, to limit the container's memory to 10GB and allow the Java heap size to use 90% of that amount:

    ``` bash
    docker run \
        -p 8080:8080 \
        --memory 10g \
        --env ERDDAP_MAX_RAM_PERCENTAGE=90 \
        ... \
        axiom/docker-erddap
    ```

#### datasets.d mode - EXPERIMENTAL

Typically ERDDAP is configured with a single `datasets.xml` configuration file describing all datasets to be served by ERDDAP, plus some global configuration options. This file is [described in detail in the official ERDDAP documentation](https://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html).

`docker-erddap` provides an alternative `datasets.d` mode, where `datasets.xml` `dataset` elements can be stored in separate files inside a `datasets.d` directory. At startup time, the `/datasets.d` directory is scanned for any files ending in `.xml`, and matching files are concatenated (sorted by file path inside `/datasets.d`) into a generated `datasets.xml` file (specifically, an empty `<erddapDatasets />` element).

In this mode, top level `datasets.xml` elements like `<cacheMinutes>`, `<standardLicense>`, etc can be configured using `ERDDAP_DATASET_*` environment variables. These behave much like the `ERDDAP_*` environment variables which affect `setup.xml` values (see the [ERDDAP docs](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#setupEnvironmentVariables) for more details), but affect top level `datasets.xml` values instead. For example, to set the `standardLicense`:

```bash
docker run -d -v $(pwd)/datasets.d:/datasets.d:ro \
  -e ERDDAP_DATASETS_standardLicense="<h1>Use as you wish</h1>" \
  --name erddap
  axiom/docker-erddap
```

Note that in this mode, the `datasets.xml` file in the ERDDAP content directory (`/usr/local/tomcat/content/erddap`) is replaced by the generated `datasets.xml`. A backup of the original `datasets.xml` is created if one doesn't already exist.

Consequently, when using `datasets.d` mode it is not necessary to mount the ERDDAP content directory at all. The contents of `datasets.d` provide all of the dataset configuration, and any top level `datasets.xml` configuration is performed through `ERDDAP_DATASETS_* env vars.

For an example of running with `datasets.d` mode, see the docker-compose example in [examples](./examples).

Generation of `datasets.xml` is handled in a script (`datasets.d.sh`)  which prints to stdout and can be tested outside of `docker-erddap` initialization.

Example:

```shell
ERDDAP_DATASETS_cacheMinutes=20 ./datasets.d.sh -d examples/datasets.d
```

##### Elegantly removing datasets in datasets.d mode

ERDDAP has a [specific process](https://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html#active)
to remove a previously served dataset:

* Edit the dataset's `datasets.xml` element and set the `active` attribute to `false`.
* Allow ERDDAP to detect the inactive dataset on the next update (or set a reload flag detect the change immediately)
* Once ERDDAP has removed the dataset, remove the dataset's `datasets.xml` element (or leave as-is with `active="false"`)

Failure to follow this process will result in "orphan" datasets in the ERDDAP configuration.

To allow `datasets.d` mode to automatically detect removed datasets (dataset ids in the running ERDDAP configuration but
not present in the newly generated `datasets.xml`), you can set environment variable `DATASETSD_MARK_REMOVED_DATASETS_INACTIVE=1`
or pass the `-i` flag to `./datasets.d.sh` when running manually. This behavior may become the default in the future.

#### Initialization scripts (/init.d) - EXPERIMENTAL

Additional configuration can be performed by placing executable files and/or shell scripts in `/init.d`. These executables will be run on every container start up, so they **must be idempotent**. This functionality is inspired by the postgres Docker image's [`/docker-entrypoint-initdb.d`](https://github.com/docker-library/docs/blob/master/postgres/README.md#initialization-scripts).

Example:

```shell
#remove .hdf and .nc files from range request exclusion
mkdir -p init.d
cat << 'EOF' > init.d/10-remove-hdf-nc-range-request-exclusion.sh
sed -i 's/.hdf, .nc, //g' ${CATALINA_HOME}/webapps/erddap/WEB-INF/classes/gov/noaa/pfel/erddap/util/messages.xml
EOF

chmod +x init.d/10-remove-hdf-nc-range-request-exclusion.sh

docker run -d -p 8080:8080 -v $(pwd)/init.d:/init.d:ro --name erddap axiom/docker-erddap
```

#### Log Consolidation - EXPERIMENTAL

ERDDAP writes logs to a `logs/log.txt` file relative to ERDDAP's `bigParentDirectory`. The log format doesn't adhere to a standard logging format and isn't easily parsable. The logs also don't provide timestamps for when the logs messages were written. To enhance the logging experience when using this docker image you can run a sidecar `rsyslog` container that will:

* Consolidate the log files from ERDDAP and Tomcat (both application and access)
* Add a timestamp to the ERDDAP logs
* Filter out some ERDDAP log "noise" (opinionated)
* Send the consolidated and filtered log messages to `stdout`

For an example of running with a sidecar `rsyslog` container, see the docker-compose example in [examples](./examples). The supporting `rsyslog` configuration files are located in [rsyslog](./examples/rsyslog). Please note that this requires both the ERDDAP `bigParentDirectory` and Tomcat's log directory to be bind mounted to the host from the ERDDAP container or managed in Docker named volumes mounted to both the ERDDAP and rsyslog containers.

Example consolidated log:

```log
erddap-rsyslogd_1  | [TOMCAT] 08-Jul-2022 04:44:14.004 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-nio-8080"]
erddap-rsyslogd_1  | [TOMCAT] 08-Jul-2022 04:44:14.011 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in 3582 ms
...
erddap-rsyslogd_1  | [ERDDAP] 2022-07-08T04:44:19Z Major LoadDatasets Time Series: MLD    Datasets Loaded            Requests (median times in ms)              Number of Threads      MB    Open
erddap-rsyslogd_1  |   timestamp                    time   nTry nFail nTotal  nSuccess (median) nFail (median) memFail tooMany  tomWait inotify other  inUse  Files
erddap-rsyslogd_1  | ----------------------------  -----   -----------------  ------------------------------------------------  ---------------------  -----  -----
erddap-rsyslogd_1  |   2022-07-08T04:44:18+00:00      1s      1     0      2         1 (     8)     0 (     0)       0       0       10       1    17     44     0%
...
erddap-rsyslogd_1  | [ACCESS] 127.0.0.1 - - [08/Jul/2022:04:44:17 +0000] "GET /erddap/index.html HTTP/1.1" 200 25268
erddap-rsyslogd_1  | [ACCESS] 127.0.0.1 - - [08/Jul/2022:04:44:27 +0000] "GET /erddap/index.html HTTP/1.1" 200 25268
```
