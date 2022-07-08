# ERDDAP on Docker

A feature full Tomcat (SSL over APR, etc.) running [ERDDAP](http://coastwatch.pfeg.noaa.gov/erddap/index.html)

Available versions:

* `axiom/docker-erddap:latest`
* `axiom/docker-erddap:2.18`
* `axiom/docker-erddap:2.14`
* `axiom/docker-erddap:2.11`
* `axiom/docker-erddap:2.10`
* `axiom/docker-erddap:2.02`
* `axiom/docker-erddap:1.82`
* `axiom/docker-erddap:1.80`

See all versions available [here](https://hub.docker.com/r/axiom/docker-erddap/tags). As always, consult the [ERDDAP Changes](https://coastwatch.pfeg.noaa.gov/erddap/download/changes.html) documentation before upgrading your sever.

The [upstream image](https://github.com/Unidata/tomcat-docker) this project uses replaces tagged images with new images periodically. Even for release tags.
This repository will **not** back-port changes from the upstream image to existing tags and overwrite them. If you require features from a newer upstream image
(for example - SHA512 password hashes) you will have to wait for the next ERDDAP release which will be built with the newest upstream image.
You can also build this image yourself.

Use `latest` image with caution as it follows the upstream image, and is not as thoroughly tested as tagged images.

[Dependabot](https://docs.github.com/en/free-pro-team@latest/github/administering-a-repository/keeping-your-dependencies-updated-automatically) is used to automatically make PRs to update the upstream image ([`.github/dependabot.yml`](.github/dependabot.yml)).

## Quickstart

```bash
$ docker run -d -p 8080:8080 axiom/docker-erddap
```

## Running ERDDAP CLI Tools

**GenerateDatasetsXml**

```bash
$ docker run --rm -it \
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

See [these instructions for configuring Tomcat](https://github.com/unidata/tomcat-docker) from the Tomcat image this is built from (`unidata/tomcat-docker`).


### ERDDAP

Any number of these options can be taken to configure your ERDDAP container instance to your liking.

1.  Mount your own `content/erddap` directory:

    ```bash
    $ docker run \
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
    ERDDAP_emailDailyReportsTo="nobody@example.com"
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

4.  Mount your own `bigParentDirectory`:

    ```bash
    $ docker run \
        -p 8080:8080 \
        -v /path/to/your/erddap/bigParentDirectory:/erddapData \
        ... \
        axiom/docker-erddap
    ```

    This is **highly** recommended, or nothing will persist across container restarts (logs/cache/etc.)


5.  Specify the amount of memory to be allocated:

   ``` bash
    $ docker run \
        -p 8080:8080 \
        --env ERDDAP_MIN_MEMORY=4G --env ERDDAP_MAX_MEMORY=8G
        ... \
        axiom/docker-erddap
   ```

   Note that both environment variables will fall back to a single ERDDAP_MEMORY variable, which in turn falls back to 4G by default.

#### datasets.d mode - EXPERIMENTAL

Typically ERDDAP is configured with a single `datasets.xml` configuration file
describing all datasets to be served by ERDDAP, plus some global configuration options.
This file is [described in detail in the official ERDDAP documentation](https://coastwatch.pfeg.noaa.gov/erddap/download/setupDatasetsXml.html).

`docker-erddap` provides an alternative `datasets.d` mode, where `datasets.xml`
`dataset` elements can be stored in separate files inside a `datasets.d` directory.
At startup time, the `/datasets.d` directory is scanned for any files ending in `.xml`,
and matching files are concatenated (sorted by file path inside `/datasets.d`) into a
generated `datasets.xml` file (specifically, an empty `<erddapDatasets />` element).

In this mode, top level `datasets.xml` elements like `<cacheMinutes>`,
`<standardLicense>`, etc can be configured using `ERDDAP_DATASET_*`
environment variables. These behave much like the `ERDDAP_*` environment
variables which affect `setup.xml` values (see the
[ERDDAP docs](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html#setupEnvironmentVariables)
for more details), but affect top level `datasets.xml` values instead. For example, to set
the `standardLicense`:

```bash
docker run -d -v $(pwd)/datasets.d:/datasets.d:ro \
  -e ERDDAP_DATASETS_standardLicense="<h1>Use as you wish</h1>" \
  --name erddap
  axiom/docker-erddap
```

Note that in this mode, the `datasets.xml` file in the ERDDAP content directory
(`/usr/local/tomcat/content/erddap`) is replaced by the generated `datasets.xml`.
A backup of the original `datasets.xml` is created if one doesn't already exist.

Consequently, when using `datasets.d` mode it is not necessary to mount the
ERDDAP content directory at all. The contents of `datasets.d` provide all of the
dataset configuration, and any top level `datasets.xml` configuration is performed
through `ERDDAP_DATASETS_* env vars.

For an example of running with `datasets.d` mode, see the docker-compose
example in [examples](./examples).

Generation of `datasets.xml` is handled in a script (`datasets.d.sh`)  which prints
to stdout and can be tested outside of `docker-erddap` initialization.

Example:

```
ERDDAP_DATASETS_cacheMinutes=20 ./datasets.d.sh examples/datasets.d
```


#### Log Consolidation - EXPERIMENTAL

ERDDAP writes logs to a `logs/log.txt` file relative to ERDDAP's `bigParentDirectory`.
The log format doesn't adhere to a standard logging format and isn't easily parsable. The logs also
don't provide timestamps for when the logs messages were written. To enhance the logging
experience when using this docker image you can run a sidecar `rsyslog` container that will:

* Consolidate the log files from ERDDAP and Tomcat (both application and access)
* Add a timestamp to the ERDDAP logs
* Filter out some ERDDAP log "noise" (opinionated)
* Send the consolidated and filtered log messages to `stdout`

For an example of running with a sidecar `rsyslog` container, see the docker-compose
example in [examples](./examples). The supporting `rsyslog` configuration files are located in
[rsyslog](./examples/rsyslog). Please note that this requires both the ERDDAP `bigParentDirectory`
and Tomcat's log directory to be bind mounted to the host from the ERDDAP container.

Example consolidated log:

```
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
