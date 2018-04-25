DOCKER_COMPOSE=ENV_FILE=./.env docker-compose -f docker-compose-fabric-ca.yaml

.PHONY:  up down ps logs

up:
	@$(DOCKER_COMPOSE) up -d

down:
	@$(DOCKER_COMPOSE) down

ps:
	@$(DOCKER_COMPOSE) ps

# If the first argument is "logs"...
ifeq (logs,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "logs"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif
logs:
	@$(DOCKER_COMPOSE) logs -f $(RUN_ARGS)
