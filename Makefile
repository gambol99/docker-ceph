

TEMPLATE_IMAGES=admin backup daemon gateway metadata monitor client manager
BUILT_IMAGES=base $(TEMPLATE_IMAGES)
BUILD_TAG=v9.2.0
IMAGE_PREFIX ?= quay.io/ukhomeofficedigital/

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
	docker build -t $(IMAGE_PREFIX)store-base:$(BUILD_TAG) base/
	$(foreach I, $(TEMPLATE_IMAGES), \
		sed -e "s,#FROM is generated dynamically by the Makefile,FROM $(IMAGE_PREFIX)store-base:${BUILD_TAG}," $(I)/Dockerfile.template > $(I)/Dockerfile ; \
		docker build -t $(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) $(I)/ || exit 1; \
		rm $(I)/Dockerfile ; \
	)

clean: check-docker
	$(foreach I, $(BUILT_IMAGES), \
		docker rmi $(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) ; \
		docker rmi $(REGISTRY)/$(IMAGE_PREFIX)store-$(I):$(BUILD_TAG) ; \
	)

full-clean: check-docker
	$(foreach I, $(BUILT_IMAGES), \
		docker images -q $(IMAGE_PREFIX)store-$(I) | xargs docker rmi -f ; \
		docker images -q $(REGISTRY)/$(IMAGE_PREFIX)store-$(I) | xargs docker rmi -f ; \
	)

release: 
	docker tag -f $(ADMIN_IMAGE) $(ADMIN_DEV_IMAGE)
	docker push $(ADMIN_DEV_IMAGE)
	docker tag -f $(BACKUP_IMAGE) $(BACKUP_DEV_IMAGE)
	docker push $(BACKUP_DEV_IMAGE)
	docker tag -f $(DAEMON_IMAGE) $(DAEMON_DEV_IMAGE)
	docker push $(DAEMON_DEV_IMAGE)
	docker tag -f $(MONITOR_IMAGE) $(MONITOR_DEV_IMAGE)
	docker push $(MONITOR_DEV_IMAGE)
	docker tag -f $(GATEWAY_IMAGE) $(GATEWAY_DEV_IMAGE)
	docker push $(GATEWAY_DEV_IMAGE)
	docker tag -f $(METADATA_IMAGE) $(METADATA_DEV_IMAGE)
	docker push $(METADATA_DEV_IMAGE)
	docker tag -f $(CLIENT_IMAGE) $(CLIENT_DEV_IMAGE)
	docker push $(CLIENT_IMAGE)
