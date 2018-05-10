# Run the API in dev mode

To run the API in a development mode use following commands:

```
docker-compose -f artifacts/docker-compose.yaml up
```

```
# This is needed when API is run for the second time
# To cleanup from pervious run
sudo rm -rf ./fabric-client-kv-org1/

# On start, the start_chaincodes.js script is also invoked
# So on start the channel is created, peer is joined to the
# channel, etc
docker-compose -f artifacts/docker-compose-api.yaml up
```

Note: to cleanup containers from previous runs, also the `docker container rm $(docker container ps -aq)` command may be useful.
