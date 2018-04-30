DOCKER_COMPOSE_FABRIC_CA=ENV_FILE=./.env docker-compose -f docker-compose-fabric-ca.yaml

.PHONY:  fabric-ca-up fabric-ca-down fabric-ca-ps fabric-ca-logs

fabric-ca-up:
	@$(DOCKER_COMPOSE_FABRIC_CA) up -d

fabric-ca-up-test:
	# Start in non-daemon mode
	@$(DOCKER_COMPOSE_FABRIC_CA) up

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
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com /scripts/register-orderer.sh

fabric-ca-bash:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com bash

# Alternative: keytool -printcert -file /path/to/cert/client.crt
fabric-ca-show-cert:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com openssl x509 -in /etc/hyperledger/fabric-ca/ca-cert.pem -text

fabric-ca-show-config:
	@$(DOCKER_COMPOSE_FABRIC_CA) exec ca.fabric.opetbot.com cat /etc/hyperledger/fabric-ca/fabric-ca-server-config.yaml
