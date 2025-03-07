# Copyright 2021 The cert-manager Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BINDIR ?= $(CURDIR)/bin
ARCH   ?= $(shell go env GOARCH)
ISTIO_VERSION ?= 1.9.1
K8S_VERSION ?= 1.20.0
HELM_VERSION ?= 3.4.1

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	OS := linux
endif
ifeq ($(UNAME_S),Darwin)
	OS := darwin
endif

help:  ## display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: help test build verify image clean all demo docker e2e depend

test: lint ## test cert-manager-istio-csr
	go test $$(go list ./pkg/... ./cmd/...)

lint:
	./hack/verify-boilerplate.sh

build: ## build cert-manager-istio-csr
	mkdir -p $(BINDIR)
	CGO_ENABLED=0 go build -o ./bin/cert-manager-istio-csr  ./cmd/.

verify: test build ## tests and builds cert-manager-istio-csr

build_image_binary: ## builds image binary
	GOARCH=$(ARCH) GOOS=linux CGO_ENABLED=0 go build -o ./bin/cert-manager-istio-csr-linux  ./cmd/.

image: build_image_binary ## build docker image from binary
	docker build -t quay.io/jetstack/cert-manager-istio-csr:v0.1.2 .

clean: ## clean up created files
	rm -rf \
		$(BINDIR) \
		_artifacts

all: test build docker ## runs test, build and docker

demo: depend build test build_image_binary ## create kind cluster and deploy demo
	./hack/demo/deploy-demo.sh $(K8S_VERSION) $(ISTIO_VERSION)
	$(BINDIR)/kubectl label namespace default istio-injection=enabled

e2e: demo ## build demo cluster and runs end to end tests
	./hack/run-e2e.sh
	./hack/demo/destroy-demo.sh

depend: $(BINDIR)/istioctl-$(ISTIO_VERSION) $(BINDIR)/ginkgo $(BINDIR)/kubectl $(BINDIR)/kind $(BINDIR)/helm

$(BINDIR)/istioctl-$(ISTIO_VERSION):
	mkdir -p $(BINDIR)
	curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$(ISTIO_VERSION) sh -
	mv istio-$(ISTIO_VERSION)/bin/istioctl $(BINDIR)/istioctl-$(ISTIO_VERSION)-tmp
	rm -r istio-$(ISTIO_VERSION)
	mv $(BINDIR)/istioctl-$(ISTIO_VERSION)-tmp $(BINDIR)/istioctl-$(ISTIO_VERSION)

$(BINDIR)/ginkgo:
	go build -o $(BINDIR)/ginkgo github.com/onsi/ginkgo/ginkgo

$(BINDIR)/kind:
	go build -o $(BINDIR)/kind sigs.k8s.io/kind

$(BINDIR)/helm:
	curl -o $(BINDIR)/helm.tar.gz -LO "https://get.helm.sh/helm-v$(HELM_VERSION)-$(OS)-$(ARCH).tar.gz"
	tar -C $(BINDIR) -xzf $(BINDIR)/helm.tar.gz
	cp $(BINDIR)/$(OS)-$(ARCH)/helm $(BINDIR)/helm
	rm -r $(BINDIR)/$(OS)-$(ARCH) $(BINDIR)/helm.tar.gz

$(BINDIR)/kubectl:
	curl -o ./bin/kubectl -LO "https://storage.googleapis.com/kubernetes-release/release/$(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$(OS)/$(ARCH)/kubectl"
	chmod +x ./bin/kubectl
