.DEFAULT_GOAL:=help

.EXPORT_ALL_VARIABLES:


NAME     := secret-sync-operator
REGISTRY ?= docker.io/veraxnet
ARCH ?= $(shell go env GOARCH)
MULTI_ARCH_IMAGE = $(REGISTRY)/$(NAME)-${ARCH}
TAG ?= master
DOCKER ?= docker
PKG = github.com/menta2l/$(NAME)
REPO_INFO ?= $(shell git config --get remote.origin.url)
GIT_COMMIT ?= git-$(shell git rev-parse --short HEAD)
GOBUILD_FLAGS := -v
LDFLAGS := -s -w -extldflags -static
BUILD_TAGS := -tags netgo -installsuffix netgo

export GO111MODULE=on
export CGO_ENABLED=0

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: push
push: .push-$(ARCH) ## Publish image for a particular arch.

# internal task
.PHONY: .push-$(ARCH)
.push-$(ARCH):
	$(DOCKER) push $(MULTI_ARCH_IMAGE):$(TAG)
.PHONY: clean-container
clean-container: ## Removes local image
	@$(DOCKER) rmi -f $(MULTI_ARCH_IMAGE):$(TAG) || true

.PHONY: container
container: clean-container .container-$(ARCH) ## Build image for a particular arch.

# internal task to build image for a particular arch.
.PHONY: .container-$(ARCH)
.container-$(ARCH):
	echo "Building docker image..."
	$(DOCKER) build --no-cache --pull -t $(MULTI_ARCH_IMAGE):$(TAG) -f ./build/Dockerfile .

.PHONY: build
build: ## Build secret-sync-operator.
	go build \
  	-ldflags "${LDFLAGS} \
	-X ${PKG}/version.RELEASE=${TAG} \
	-X ${PKG}/version.COMMIT=${GIT_COMMIT} \
	-X ${PKG}/version.REPO=${REPO_INFO}" \
	${BUILD_TAGS} \
	-o "build/bin/${ARCH}/${NAME}" "./cmd/manager"

