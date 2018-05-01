# Setup

[Fabric CA host]

- Start Fabric CA: `make fabric-ca-up`
- Register network participants with CA: `make fabric-ca-register`
- Generage artifacts `make fabric-ca-artifacts-gen`
- Get /data/opet-ca-cert.pem, /data/genesis.block, /data/channel.tx (will be needed by orderer / peer hosts)

[Orderer host]

- Put opet-ca-cert.pem, genesis.block to data/
- Start Orderer: `make orderer-up`
