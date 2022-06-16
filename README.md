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
  axiom/docker-erddap:latest \
  bash -c "cd webapps/erddap/WEB-INF/ && bash GenerateDatasetsXml.sh -verbose"
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

