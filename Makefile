

TEMPLATE_IMAGES=admin backup daemon gateway metadata monitor client manager
BUILT_IMAGES=base $(TEMPLATE_IMAGES)
BUILD_REGISTRY ?= quay.io/ukhomeofficedigital
BUILD_TAG ?= latest

ADMIN_IMAGE = $(BUILD_REGISTRY)/store-admin:$(BUILD_TAG)
BACKUP_IMAGE = $(BUILD_REGISTRY)/store-backup:$(BUILD_TAG)
CLIENT_IMAGE = $(BUILD_REGISTRY)/store-client:$(BUILD_TAG)
DAEMON_IMAGE = $(BUILD_REGISTRY)/store-daemon:$(BUILD_TAG)
GATEWAY_IMAGE = $(BUILD_REGISTRY)/store-gateway:$(BUILD_TAG)
METADATA_IMAGE = $(BUILD_REGISTRY)/store-metadata:$(BUILD_TAG)
MONITOR_IMAGE = $(BUILD_REGISTRY)/store-monitor:$(BUILD_TAG)
MANAGER_IMAGE = $(BUILD_REGISTRY)/store-manager:$(BUILD_TAG)

default: build

check-docker:
	@if [ -z $$(which docker) ]; then \
		echo "Missing docker client which is required for development"; \
		exit 2; \
	fi

build: check-docker
	docker build -t $(BUILD_REGISTRY)/store-base:$(BUILD_TAG) base/
	$(foreach I, $(TEMPLATE_IMAGES), \
		sed -e "s,#FROM is generated dynamically by the Makefile,FROM $(BUILD_REGISTRY)/store-base:${BUILD_TAG}," $(I)/Dockerfile.template > $(I)/Dockerfile ; \
		sed -i "s,BUILD_TAG,$(BUILD_TAG),g" $(I)/Dockerfile ; \
		sed -i "s,BUILD_REGISTRY,$(BUILD_REGISTRY),g" $(I)/Dockerfile ; \
		docker build -t $(BUILD_REGISTRY)/store-$(I):$(BUILD_TAG) $(I)/ || exit 1; \
		rm $(I)/Dockerfile ; \
	)

clean: check-docker
	$(foreach I, $(BUILT_IMAGES), \
		docker rmi $(BUILD_REGISTRY)/store-$(I):$(BUILD_TAG) ; \
	)

release:
	docker push $(ADMIN_IMAGE)
	docker push $(BACKUP_IMAGE)
	docker push $(DAEMON_IMAGE)
	docker push $(MONITOR_IMAGE)
	docker push $(GATEWAY_IMAGE)
	docker push $(METADATA_IMAGE)
	docker push $(CLIENT_IMAGE)
