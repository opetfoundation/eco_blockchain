DOCKER_COMPOSE_FABRIC_CA=ENV_FILE=./.env.ca docker-compose -f docker-compose-fabric-ca.yaml
DOCKER_COMPOSE_ORDERER=ENV_FILE=./.env.orderer docker-compose -f docker-compose-orderer.yaml
DOCKER_COMPOSE_PEER0=ENV_FILE=./.env.peer0 docker-compose -f docker-compose-peer0.yaml
DOCKER_COMPOSE_API=ENV_FILE=./.env.api docker-compose -f docker-compose-api.yaml

fabric-ca-up:
	@$(DOCKER_COMPOSE_FABRIC_CA) up -d

fabric-ca-up-test:
	# Start in non-daemon mode
	@$(DOCKER_COMPOSE_FABRIC_CA) up --build

fabric-ca-down:
	@$(DOCKER_COMPOSE_FABRIC_CA) down

fabric-ca-ps:
	@$(DOCKER_COMPOSE_FABRIC_CA) ps

# If the first argument is "logs"...
ifeq (logs,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "logs"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif
fabric-ca-logs:
	@$(DOCKER_COMPOSE_FABRIC_CA) logs -f $(RUN_ARGS)

fabric-ca-register:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com /scripts/register-ca-identities.sh

fabric-ca-bash:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com bash

# Alternative: keytool -printcert -file /path/to/cert/client.crt
fabric-ca-show-cert:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com openssl x509 -in /etc/hyperledger/fabric-ca/ca-cert.pem -text

fabric-ca-show-config:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com cat /etc/hyperledger/fabric-ca/fabric-ca-server-config.yaml

fabric-ca-artifacts-gen:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec artifacts_gen /scripts/artifacts-gen.sh

orderer-up:
	@$(DOCKER_COMPOSE_ORDERER) up -d

orderer-up-test:
	# Start in non-daemon mode
	@$(DOCKER_COMPOSE_ORDERER) up

orderer-down:
	@$(DOCKER_COMPOSE_ORDERER) down

orderer-ps:
	@$(DOCKER_COMPOSE_ORDERER) ps

orderer-bash:
	@$(DOCKER_COMPOSE_ORDERER) exec orderer.fabric.opetbot.com bash

peer0-up:
	@$(DOCKER_COMPOSE_PEER0) up -d

peer0-up-test:
	# Start in non-daemon mode
	@$(DOCKER_COMPOSE_PEER0) up

peer0-down:
	@$(DOCKER_COMPOSE_PEER0) down

peer0-bash:
	@$(DOCKER_COMPOSE_PEER0) exec peer0.fabric.opetbot.com bash

peer0-channel-create:
	@$(DOCKER_COMPOSE_PEER0) exec peer0_tools /scripts/channel-create.sh

peer0-chaincode-upgrade:
	@$(DOCKER_COMPOSE_PEER0) exec peer0_tools /scripts/chaincode-upgrade.sh

peer0-tools-bash:
	@$(DOCKER_COMPOSE_PEER0) exec peer0_tools bash

api-up:
	@$(DOCKER_COMPOSE_API) up -d

api-up-test:
	@$(DOCKER_COMPOSE_API) up --build

api-bash:
	@$(DOCKER_COMPOSE_API) exec api bash

clean:
	sudo rm -rf data_ca/
	sudo rm -rf data_orderer/
	sudo rm -rf data_peer0/
	sudo rm -rf data_api/
	docker container rm $$(docker container ps -aq)

artifacts-copy:
	mkdir -p data_peer0
	mkdir -p data_orderer
	cp data_ca/opet-ca-cert.pem data_orderer/opet-ca-cert.pem
	cp data_ca/genesis.block data_orderer/genesis.block
	cp data_ca/opet-ca-cert.pem data_peer0/opet-ca-cert.pem
	cp data_ca/channel.tx data_peer0/channel.tx
	# See scripts/start-peer.sh
	# Without this, the channel creation fails
	# Note: copy from orderer also doesn't work
	sudo cp -r data_ca/fabric.opetbot.com/ data_peer0/
	sudo chown $(USER):$(USER) data_peer0/fabric.opetbot.com/

api-artifacts-copy:
	mkdir -p data_api
	sudo cp data_ca/fabric-ca-server/tls-cert.pem data_api/ca.fabric.opetbot.com-tls-ca.crt
	sudo cp data_peer0/msp/tlscacerts/ca-fabric-opetbot-com-7054.pem data_api/peer0.fabric.opetbot.com-tls-ca.crt
	sudo cp data_orderer/msp/tlscacerts/ca-fabric-opetbot-com-7054.pem data_api/orderer.fabric.opetbot.com-tls-ca.crt

view-genesis-block:
	# View genesis.block content as json
	cd ./scripts && ../fabric-samples/bin/configtxgen -inspectBlock ../data_orderer/genesis.block > block.json 
