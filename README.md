Popler API
==========

* Base URL: <https://popler.space/>
* API Docs: <https://github.com/AldoCompagnoni/popler_API>

tech:

* language: Ruby
* rest framework: Sinatra
* database: postgres
* server: caddy

**NOTE**: The deployed API doesn't actually use docker as the instance was too small to support Docker. But the Ruby/Sinata/postgres/puma/caddy/etc. setup still applies.

## JSON API examples

```bash
https://popler.space/
https://popler.space/heartbeat/
https://popler.space/summary/
https://popler.space/search?proj_metadata_key=3
https://popler.space/search?proj_metadata_key=3&genus=Strongylocentrotus
https://popler.space/search?proj_metadata_key=3&genus=Strongylocentrotus&species=franciscanus
```

## Local development

skip any steps that you don't need (i.e. you already have the thing installed)

* Install Docker [for Mac](https://docs.docker.com/v17.12/docker-for-mac/install/) or [for Windows](https://docs.docker.com/docker-for-windows/install/) or for a [linux os](https://docs.docker.com/v17.12/install/)
* Install `docker-compose`: <https://docs.docker.com/compose/install/>
* Start Docker
* If you don't already have the popler database, run this from wherver the popler sql dump file is:

```
# get the postgres docker image
docker pull postgres:latest

# start a postgres container
docker run --name some-postgres -v $HOME/data/popler_3:/var/lib/postgresql/data -e POSTGRES_USER=power_user -e POSTGRES_PASSWORD=popler -d postgres:latest

# run psql in the container
docker run -it --link some-postgres:postgres --rm postgres \
    sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U power_user'
# and then paste in 
CREATE USER postgres;
CREATE USER other_user;
ALTER ROLE power_user CREATEDB;
SET ROLE 'power_user';
CREATE database popler_3;
# then exit (ctrl + D)

# load the database
docker run -it --link some-postgres:postgres --rm -v ${PWD}/popler3-2018-10-30.dump:/popler3-2018-10-30.dump postgres sh -c 'exec pg_restore -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U power_user -W -d popler_3 < popler3-2018-10-30.dump'

# kill the container
docker rm -f "container id"
```

* from within the `popler_API` folder run `docker-compose build` - if no errors then next step
* from within the `popler_API` folder run `docker-compose up -d`
* then go to <http://localhost:8834> in your browser
* from within the `popler_API` folder see logs by running `docker-compose logs -f --tail=50`
