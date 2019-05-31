Popler API
==========

* Base URL: <https://popler.space/>
* API Docs: <https://github.com/AldoCompagnoni/popler_API>

tech:

* language: Ruby
* rest framework: Sinatra
* API server: puma
* database: postgres
* server: caddy

**NOTE**: The deployed API doesn't actually use docker as the instance was too small to support Docker. But the Ruby/Sinata/postgres/puma/caddy/etc. setup still applies.

## Puma

Within popler_API on the server there is a `puma.rb` file. 

As you can see in the `puma.rb` file, the API runs on port 8834. To see if puma is running, execute `lsof -i :8834 -t`. If nothing is found, then it's not running. If it gives back any output, those are the PID's for the processes, and it is running.

To start puma run `bundle exec puma -C puma.rb`

To stop puma run `kill $(lsof -i :8834 -t)`

## Caddy

Puma is what runs the API locally on the server, but to serve the API to the world/public, we use the Caddy server. 

To start Caddy run `sudo caddy -port 443 -agree -email=myrmecocystus@gmail.com &` (and ctrl + ^c afterwards as it will just hang)

To stop Caddy run `sudo pkill caddy`

You can see that Caddy is running when you do a request, e.g.:

```bash
curl -v https://popler.space/heartbeat
```

```bash
> GET /heartbeat HTTP/2
> Host: popler.space
> User-Agent: curl/7.54.0
> Accept: */*
>
* Connection state changed (MAX_CONCURRENT_STREAMS updated)!
< HTTP/2 200
< access-control-allow-methods: HEAD, GET
...
< server: Caddy <------- LOOK HERE 
...
```

## JSON API examples

```bash
https://popler.space/
https://popler.space/heartbeat/
https://popler.space/summary/
https://popler.space/search?proj_metadata_key=3
https://popler.space/search?proj_metadata_key=3&genus=Strongylocentrotus
https://popler.space/search?proj_metadata_key=3&genus=Strongylocentrotus&species=franciscanus
```
