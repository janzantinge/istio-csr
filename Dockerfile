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

# Build the istio-csr binary
FROM docker.io/library/golang:1.17 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source files
COPY Makefile Makefile
COPY cmd/ cmd/
COPY pkg/ pkg/

# Build
RUN make build

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static@sha256:be5d77c62dbe7fedfb0a4e5ec2f91078080800ab1f18358e5f31fcc8faa023c4
LABEL description="istio certificate agent to serve certificate signing requests via cert-manager"
||||||| parent of b9d8cd1 (Add delve.)
FROM gcr.io/distroless/static@sha256:3cd546c0b3ddcc8cae673ed078b59067e22dea676c66bd5ca8d302aef2c6e845
LABEL description="istio certificate agent to serve certificate signing requests via cert-manager"

RUN git clone https://github.com/go-delve/delve; \
	cd delve; \
	go build ./cmd/dlv

WORKDIR /

#FROM gcr.io/distroless/static@sha256:3cd546c0b3ddcc8cae673ed078b59067e22dea676c66bd5ca8d302aef2c6e845
FROM ubuntu:bionic
LABEL description="istio certificate agent to serve certificate signing requests via cert-manager"

USER 1001
COPY --from=builder /workspace/bin/cert-manager-istio-csr /usr/bin/cert-manager-istio-csr

COPY ./bin/cert-manager-istio-csr-linux /usr/bin/cert-manager-istio-csr
COPY --from=0 /build/delve/dlv /usr/bin/dlv

ENTRYPOINT ["/usr/bin/cert-manager-istio-csr"]
