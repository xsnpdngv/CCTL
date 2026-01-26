# ============================================================================
# cctl — CodeChecker Control
# Main Makefile
# ============================================================================

PLATFORM   ?= linux/arm64 # or linux/amd64
IMAGE_NAME ?= cctl
IMAGE_TAG  ?= ubuntu24.04
IMAGE_BASE ?= $(IMAGE_NAME)-base:$(IMAGE_TAG)
IMAGE      ?= $(IMAGE_NAME):$(IMAGE_TAG)
DOCKERFILE_BASE  ?= docker/Dockerfile.base
DOCKERFILE_FINAL ?= docker/Dockerfile.final

DOCKER     ?= docker

.PHONY: image image-base export import help clean

all: help

help:
	@echo "Targets:"
	@echo "  image   Build the CodeChecker Docker image"
	@echo "  export  Export the CodeChecker Docker image"
	@echo "  import  Import the CodeChecker Docker image"
	@echo "  clean   Remove the Docker image"

image-base:
	$(DOCKER) build \
	  --platform $(PLATFORM) \
	  -f $(DOCKERFILE_BASE) \
	  -t $(IMAGE_BASE) \
	  .

image: image-base
	$(DOCKER) build \
	  --platform $(PLATFORM) \
	  -f $(DOCKERFILE_FINAL) \
	  -t $(IMAGE) \
	  .

export:
	$(DOCKER) save $(IMAGE) | gzip > $(IMAGE).tar.gz

import:
	$(DOCKER) load < $(IMAGE).tar.gz

clean:
	docker rmi -f $(IMAGE) $(IMAGE_BASE) 2>/dev/null || true
