# Description

The Hyperledger Fabric main network consists of following components:

- Fabric CA server, ca.fabric.opetbot.com (represented by docker-compose-fabric-ca.yaml) using PostgreSQL datbase as backend
- Solo orderer, orderer.fabric.opetbot.com (docker-compose-orderer.yaml)
- Peers, peer0.opetbot.com (docker-compose-peer0.yaml) using CouchDB as blockchain data storage

Each component is meant to be run on a separate host and be avaiable via DNS name.
The setup procedure is described below.

The setup is based on the [fabric-ca example](https://github.com/hyperledger/fabric-samples/tree/release-1.1/fabric-ca),
tweaking the parameters we need for the chosen network setup.
Also the monolith docker compose config was split to separate setups for CA, orderer and peer hosts to make sure they don't use the common filesystem and we can actually run them separately on different hosts.

# Setup Process

[Fabric CA host]

- Edit the `.env.ca` file, set passwords for CA
- Start Fabric CA: `make fabric-ca-up`
- Register network participants with CA: `make fabric-ca-register`
- Generage artifacts `make fabric-ca-artifacts-gen`
- Get /data/opet-ca-cert.pem, /data/genesis.block, /data/channel.tx (will be needed by orderer / peer hosts)
- Get /data/fabric.opetbot.com (organization MSP, will be needed for channel setup)

[Orderer host]

- Edit the `.env.orderer` file, set passwords for Orderer
- Put opet-ca-cert.pem, genesis.block (copied from CA instance) to data/
  - Note: in local setup (single machine tests), run `make artifacts-copy` instead of manual copying
- Start the orderer: `make orderer-up`

[Peer 0 host]

- Edit the `.env.peer0` file, set passwords for Orderer
- Put opet-ca-cert.pem, channel.tx (copied from CA instance) to data/
- Copy fabric.opetbot.com (organization MSP) from the fabric CA host and put under data/
  - Note: in local setup (single machine tests), run `make artifacts-copy` instead of manual copying
- Start the peer: `make peer0-up`
- Init the channel and join peers: `make peer0-channel-create`.

[API host]
- Edit the `.env.api` file, set passwords
- Copy tls certificates:
 - From CA: `data_ca/fabric-ca-server/tls-cert.pem` to `data_api/ca.fabric.opetbot.com-tls-ca.crt`
 - From Peer0: `data_peer0/msp/tlscacerts/ca-fabric-opetbot-com-7054.pem` to `data_api/peer0.fabric.opetbot.com-tls-ca.crt`
 - From Orderer: `data_orderer/msp/tlscacerts/ca-fabric-opetbot-com-7054.pem` to `data_api/orderer.fabric.opetbot.com-tls-ca.crt`
 - Note: locally, copying can be done with `make api-artifacts-copy`
- Start the API: `make api-up`

# Data folders

The data folders (data_ca, data_orderer, data_peer0, ...) on each instance contains the MSP configuration and data used by network nodes.
The nodes and related services are running in Docker containers and the permanent data is mapped to the host through docker volumes.

The approximate structure of the data folders is this:

```
data_ca
├── channel.tx
├── fabric-ca-postgresql                                 # Fabric CA PostgreSQL data
│   ├── base
│   └── ...
├── fabric-ca-server                                     # Fabric CA server data
│   ├── ca-cert.pem
│   ├── fabric-ca-server-config.yaml
│   ├── gen.config.sh
│   ├── msp
│   │   ├── cacerts
│   │   ├── keystore
│   │   │   ├── 15252...
│   │   │   ├── 17894...
│   │   │   ├── 23312...
│   │   │   └── ce711...
│   │   └── signcerts
│   └── tls-cert.pem
├── fabric.opetbot.com                                   # Organization data
│   ├── admin                                            # Organization Admin MSP
│   │   ├── fabric-ca-client-config.yaml
│   │   └── msp
│   │       ├── admincerts
│   │       │   └── cert.pem
│   │       ├── cacerts
│   │       │   └── ca-fabric-opetbot-com-7054.pem
│   │       ├── intermediatecerts
│   │       │   └── ca-fabric-opetbot-com-7054.pem
│   │       ├── keystore
│   │       │   └── 523d...
│   │       └── signcerts
│   │           └── cert.pem
│   ├── anchors.tx
│   ├── configtx.yaml
│   └── msp                                              # Organization MSP
│       ├── admincerts
│       │   └── cert.pem
│       ├── cacerts
│       │   └── ca-fabric-opetbot-com-7054.pem
│       ├── intermediatecerts
│       │   └── ca-fabric-opetbot-com-7054.pem
│       ├── keystore
│       ├── signcerts
│       ├── tlscacerts
│       │   └── ca-fabric-opetbot-com-7054.pem
│       └── tlsintermediatecerts
│           └── ca-fabric-opetbot-com-7054.pem
├── genesis.block
└── opet-ca-cert.pem

data_orderer
├── fabric-ca-client-config.yaml
├── fabric.opetbot.com                              # Copy of organization MSP
│   ├── admin
│   │   └── ...
│   └── msp
│       └── ...
├── genesis.block
├── msp                                             # Orderer MSP
│   ├── admincerts
│   │   └── cert.pem
│   ├── cacerts
│   │   └── ca-fabric-opetbot-com-7054.pem
│   ├── keystore
│   │   └── 678b...
│   └── ...
├── opet-ca-cert.pem                                # Root CA certificate
├── setup.done                                      # Marker of the finished orderer setup
├── tls                                             # Certificates for TLS communication in the network
│    ├── server.crt
│    └── server.key
└── orderer_production                              # Data from /var/hyperledger/production/orderer
    └── orderer
        ├── chains
        │   └── ...
        └── index
            └── ...

data_peer0                                          # Peer0 data
├── fabric-ca-client-config.yaml
├── fabric.opetbot.com                              # Copy of organization MSP
│   ├── admin
│   │   └── ...
│   └── msp
│       └── ...
├── msp                                             # Peer MSP
│   ├── admincerts
│   │   └── cert.pem
│   └── ...
├── opet-ca-cert.pem                                # Root CA certificate
├── setup.done                                      # Marker of the finished orderer setup
├── tls
│    ├── peer0-opet-cli-client.crt
│    ├── peer0-opet-cli-client.key
│    ├── peer0-opet-client.crt
│    ├── peer0-opet-client.key
│    ├── server.crt
│    └── server.key
└── peer0_production                                    # Data from /var/hyperledger/production
    ├── chaincodes
    ├── ledgersData
    │   └── ...
    └── peer.pid
```
