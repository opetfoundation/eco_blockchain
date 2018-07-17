# Run the API in dev mode

The development mode API setup is based on the [balance transfer hyperledger example](https://github.com/hyperledger/fabric-samples/tree/release-1.1/balance-transfer), refer to it to find out more about the setup.

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

There are some API call examples in the [api_call_samples_curl.sh](./api_call_samples_curl.sh) script.

Note: if you get the `Failed to load user "user1" from local key value store. Error: Private key missing from key store. Can not establish the signing identity for user user1` error, execute the `sudo rm -rf ./fabric-client-kv-org1/` command to cleanup from the previous run.
