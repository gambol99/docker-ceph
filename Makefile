

TEMPLATE_IMAGES=admin backup daemon gateway metadata monitor client manager
BUILT_IMAGES=base $(TEMPLATE_IMAGES)
BUILD_TAG=v9.2.0
SUDO=${SUDO:-"sudo"}

[[ "${REQUIRE_SUDO}" == "False" ]] && SUDO=""

IMAGE_PREFIX=${IMAGE_PREFIX:-"docker.io/gambol99/"
ADMIN_IMAGE = $(IMAGE_PREFIX)store-admin:$(BUILD_TAG)
ADMIN_DEV_IMAGE = $(REGISTRY)$(ADMIN_IMAGE)
BACKUP_IMAGE = $(IMAGE_PREFIX)store-backup:$(BUILD_TAG)
BACKUP_DEV_IMAGE = $(REGISTRY)$(BACKUP_IMAGE)
CLIENT_IMAGE = $(IMAGE_PREFIX)store-client:$(BUILD_TAG)
CLIENT_DEV_IMAGE = $(REGISTRY)$(CLIENT_IMAGE)
DAEMON_IMAGE = $(IMAGE_PREFIX)store-daemon:$(BUILD_TAG)
DAEMON_DEV_IMAGE = $(REGISTRY)$(DAEMON_IMAGE)
GATEWAY_IMAGE = $(IMAGE_PREFIX)store-gateway:$(BUILD_TAG)
GATEWAY_DEV_IMAGE = $(REGISTRY)$(GATEWAY_IMAGE)
METADATA_IMAGE = $(IMAGE_PREFIX)store-metadata:$(BUILD_TAG)
METADATA_DEV_IMAGE = $(REGISTRY)$(METADATA_IMAGE)
MONITOR_IMAGE = $(IMAGE_PREFIX)store-monitor:$(BUILD_TAG)
MONITOR_DEV_IMAGE = $(REGISTRY)$(MONITOR_IMAGE)
MANAGER_IMAGE = $(IMAGE_PREFIX)store-manager:$(BUILD_TAG)
MANAGER_DEV_IMAGE = $(REGISTRY)$(MANAGER_IMAGE)

default: build

check-docker:
	@if [ -z $$(which docker) ]; then \
    echo "Missing \`docker\` client which is required for development"; \
    exit 2; \
  fi

build: check-docker
	@# Build base as normal
	sudo docker build -t $(IMAGE_PREFIX)store-base:$(BUILD_TAG) base/
	$(foreach I, $(TEMPLATE_IMAGES), \
		sed -e "s,#FROM is generated dynamically by the Makefile,FROM $(IMAGE_PREFIX)store-base:${BUILD_TAG}," $(I)/Dockerfile.template > $(I)/Dockerfile ; \
		$SUDO docker build -t $(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) $(I)/ || exit 1; \
		rm $(I)/Dockerfile ; \
	)

clean: check-docker
	$(foreach I, $(BUILT_IMAGES), \
		$SUDO docker rmi $(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) ; \
		$SUDO docker rmi $(REGISTRY)/$(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) ; \
	)

full-clean: check-docker
	$(foreach I, $(BUILT_IMAGES), \
		$SUDO docker images -q $(IMAGE_PREFIX)store-$(I) | xargs docker rmi -f ; \
		$SUDO docker images -q $(REGISTRY)/$(IMAGE_PREFIX)store-$(I) | xargs docker rmi -f ; \
	)

release-client:
	$SUDO docker tag -f $(CLIENT_IMAGE) $(CLIENT_DEV_IMAGE)
	$SUDO docker push $(CLIENT_IMAGE)

release:
	$SUDO docker tag -f $(DAEMON_IMAGE) $(DAEMON_DEV_IMAGE)
	$SUDO docker push $(DAEMON_DEV_IMAGE)
	$SUDO docker tag -f $(MONITOR_IMAGE) $(MONITOR_DEV_IMAGE)
	$SUDO docker push $(MONITOR_DEV_IMAGE)
	make release-client

full-release: release
	$SUDO docker tag -f $(ADMIN_IMAGE) $(ADMIN_DEV_IMAGE)
	$SUDO docker push $(ADMIN_DEV_IMAGE)
	$SUDO docker tag -f $(BACKUP_IMAGE) $(BACKUP_DEV_IMAGE)
	$SUDO docker push $(BACKUP_DEV_IMAGE)
	$SUDO docker tag -f $(CONFIG_IMAGE) $(CONFIG_DEV_IMAGE)
	$SUDO docker push $(CONFIG_DEV_IMAGE)
	$SUDO docker tag -f $(GATEWAY_IMAGE) $(GATEWAY_DEV_IMAGE)
	$SUDO docker push $(GATEWAY_DEV_IMAGE)
	$SUDO docker tag -f $(METADATA_IMAGE) $(METADATA_DEV_IMAGE)
	$SUDO docker push $(METADATA_DEV_IMAGE)
