# ============================================================================
# cctl — CodeChecker Control
# Main Makefile
# ============================================================================

PLATFORM   ?= linux/arm64 # or linux/amd64
IMAGE_NAME ?= cctl
IMAGE_TAG  ?= ubuntu24.04
IMAGE      ?= $(IMAGE_NAME):$(IMAGE_TAG)
DOCKERFILE ?= docker/Dockerfile
DOCKER     ?= docker

.PHONY: image export import help clean

all: help

help:
	@echo "Targets:"
	@echo "  image   Build the CodeChecker Docker image"
	@echo "  export  Export the CodeChecker Docker image"
	@echo "  import  Import the CodeChecker Docker image"
	@echo "  clean   Remove the Docker image"

image:
	$(DOCKER) build \
	  --platform $(PLATFORM) \
	  -f $(DOCKERFILE) \
	  -t $(IMAGE) \
	  .

export:
	$(DOCKER) save $(IMAGE) | gzip > $(IMAGE).tar.gz

import:
	$(DOCKER) load < $(IMAGE).tar.gz

clean:
	docker rmi -f $(IMAGE) 2>/dev/null || true
