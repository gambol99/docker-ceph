

TEMPLATE_IMAGES=admin daemon gateway metadata monitor client
BUILT_IMAGES=base $(TEMPLATE_IMAGES)
BUILD_TAG=0.0.1
IMAGE_PREFIX=gambol99/

REGISTRY=docker.io/
ADMIN_IMAGE = $(IMAGE_PREFIX)store-admin:$(BUILD_TAG)
ADMIN_DEV_IMAGE = $(REGISTRY)$(ADMIN_IMAGE)
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
		sudo docker build -t $(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) $(I)/ || exit 1; \
		rm $(I)/Dockerfile ; \
	)

clean: check-docker
	$(foreach I, $(BUILT_IMAGES), \
		sudo docker rmi $(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) ; \
		sudo docker rmi $(REGISTRY)/$(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) ; \
	)

full-clean: check-docker
	$(foreach I, $(BUILT_IMAGES), \
		sudo docker images -q $(IMAGE_PREFIX)store-$(I) | xargs docker rmi -f ; \
		sudo docker images -q $(REGISTRY)/$(IMAGE_PREFIX)store-$(I) | xargs docker rmi -f ; \
	)

release-client:
	sudo docker tag -f $(CLIENT_IMAGE) $(CLIENT_DEV_IMAGE)
	sudo docker push $(CLIENT_IMAGE)

release:
	sudo docker tag -f $(DAEMON_IMAGE) $(DAEMON_DEV_IMAGE)
	sudo docker push $(DAEMON_DEV_IMAGE)
	sudo docker tag -f $(MONITOR_IMAGE) $(MONITOR_DEV_IMAGE)
	sudo docker push $(MONITOR_DEV_IMAGE)
	make release-client

full-release: release
	sudo docker tag -f $(ADMIN_IMAGE) $(ADMIN_DEV_IMAGE)
	sudo docker push $(ADMIN_DEV_IMAGE)
	sudo docker tag -f $(GATEWAY_IMAGE) $(GATEWAY_DEV_IMAGE)
	sudo docker push $(GATEWAY_DEV_IMAGE)
	sudo docker tag -f $(METADATA_IMAGE) $(METADATA_DEV_IMAGE)
	sudo docker push $(METADATA_DEV_IMAGE)
	