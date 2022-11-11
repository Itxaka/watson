GIT_COMMIT ?= $(shell git rev-parse HEAD)
GIT_COMMIT_SHORT ?= $(shell git rev-parse --short HEAD)
GIT_TAG ?= $(shell git describe --abbrev=0 --tags 2>/dev/null || echo "v0.0.0" )
TAG ?= ${GIT_TAG}-${GIT_COMMIT_SHORT}
REPO?=ttl.sh/watson-ci
IMAGE=${REPO}:${GIT_TAG}
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SUDO?=sudo
FRAMEWORK_PACKAGES?=meta/cos-light
CLOUD_CONFIG_FILE?="iso/user-config.yaml"
MANIFEST_FILE?="iso/manifest.yaml"
# This are the default images already in the dockerfile but we want to be able to override them
TOOL_IMAGE?=quay.io/costoolkit/elemental-cli-ci:latest
# Used to know if this is a release or just a normal dev build
RELEASE_TAG?=false

# Set tag based on release status for ease of use
ifeq ($(RELEASE_TAG), "true")
FINAL_TAG=$(GIT_TAG)
else
FINAL_TAG=$(TAG)
endif

.PHONY: clean
clean:
	rm -rf build

# Build elemental docker images
.PHONY: build
build:
	@DOCKER_BUILDKIT=1 docker build -f Dockerfile.image \
		--target default \
		--build-arg IMAGE_TAG=${FINAL_TAG} \
		--build-arg IMAGE_COMMIT=${GIT_COMMIT} \
		--build-arg IMAGE_REPO=${REPO} \
		--build-arg TOOL_IMAGE=${TOOL_IMAGE} \
		-t ${REPO}:${FINAL_TAG} \
		.
	#@DOCKER_BUILDKIT=1 docker push ${REPO}:${FINAL_TAG}

.PHONY: dump_image
dump_image:
	@mkdir -p build
	@docker save ${REPO}:${FINAL_TAG} -o build/elemental_${FINAL_TAG}.tar

# Build iso with the elemental image as base
.PHONY: build iso
iso:
ifeq ($(MANIFEST_FILE),"iso/manifest.yaml")
	@echo "No MANIFEST_FILE set, using the default one at ${MANIFEST_FILE}"
else
	@cp ${MANIFEST_FILE} iso/config
endif
	@mkdir -p build
	@DOCKER_BUILDKIT=1 docker build -f Dockerfile.iso \
		--target default \
		--build-arg OS_IMAGE=${REPO}:${FINAL_TAG} \
		--build-arg TOOL_IMAGE=${TOOL_IMAGE} \
		--build-arg ELEMENTAL_VERSION=${FINAL_TAG} \
		--build-arg CLOUD_CONFIG_FILE=${CLOUD_CONFIG_FILE} \
		--build-arg MANIFEST_FILE=${MANIFEST_FILE} \
		-t iso:${FINAL_TAG} .
	@DOCKER_BUILDKIT=1 docker run --rm -v $(PWD)/build:/mnt \
		iso:${FINAL_TAG} \
		--config-dir . \
		--debug build-iso \
		-o /mnt \
		-n watson-${FINAL_TAG} dir:rootfs
		#--overlay-rootfs overlay \

	@echo "INFO: ISO available at build/watson-${FINAL_TAG}.iso"

.PHONY: build_all
build_all: build iso